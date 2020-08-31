#
# Cookbook:: munin
# Recipe:: server
#
# Copyright:: 2010-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

unless node['munin']['public_domain']
  if node['public_domain']
    case node.chef_environment
    when 'production'
      public_domain = node['public_domain']
    else
      if node['munin']['multi_environment_monitoring'] # rubocop:disable Metrics/BlockNesting
        public_domain = node['public_domain']
      else
        env = node.chef_environment =~ /_default/ ? 'default' : node.chef_environment # rubocop:disable Metrics/BlockNesting
        public_domain = "#{env}.#{node['public_domain']}"
      end
    end
  else
    public_domain = node['domain']
  end
  node.default['munin']['public_domain'] = "munin.#{public_domain}"
end

web_srv = node['munin']['web_server'].to_sym
case web_srv
when :apache
  include_recipe 'munin::server_apache'
  web_group = node['apache']['group']
when :nginx
  include_recipe 'munin::server_nginx'
  web_group = node['nginx']['group']
else
  raise 'Unsupported web server type provided for munin. Supported: apache or nginx'
end

include_recipe 'munin::client'

sysadmins = []
sysadmins = if Chef::Config[:solo]
              data_bag('users').map { |user| data_bag_item('users', user) }
            else
              search(:users, 'groups:sysadmin')
            end

if Chef::Config[:solo]
  munin_servers = [node]
else
  munin_servers = []
  if node['munin']['multi_environment_monitoring']
    if node['munin']['multi_environment_monitoring'].is_a?(Array)
      node['munin']['multi_environment_monitoring'].each do |searchenv|
        search(:node, "munin:[* TO *] AND chef_environment:#{searchenv} AND (platform_version:6* OR platform_version:7*)").each do |n|
          munin_servers << n
        end
      end
    else
      munin_servers = search(:node, 'munin:[* TO *]')
    end
  else
    munin_servers = search(:node, "munin:[* TO *] AND chef_environment:#{node.chef_environment}")
  end
end

if munin_servers.empty?
  Chef::Log.info 'No nodes returned from search, using this node so munin configuration has data'
  munin_servers = [node]
end

munin_servers.sort! { |a, b| a['fqdn'] <=> b['fqdn'] }

if platform?('freebsd')
  package 'munin-master'
else
  package 'munin'
end

case node['platform']
when 'arch'
  cron 'munin-graph-html' do
    command '/usr/bin/munin-cron'
    user    'munin'
    minute  '*/5'
  end
when 'freebsd'
  cron 'munin-graph-html' do
    command        '/usr/local/bin/munin-cron'
    user           'munin'
    minute         '*/5'
    ignore_failure true
  end
else
  cron_d 'munin-cron-1' do
    command "if [ ! -d /var/run/munin ];
      then /bin/bash -c 'perms=(`/usr/sbin/dpkg-statoverride --list /var/run/munin`);
      mkdir /var/run/munin;
      chown ${perms[0]:-munin}:${perms[1]:-root} /var/run/munin;
      chmod ${perms[2]:-0755} /var/run/munin'; fi
    "
    user 'root'
    predefined_value '@reboot'
  end
  cron_d 'munin-cron-2' do
    command 'if [ -x /usr/bin/munin-cron ]; then /usr/bin/munin-cron; fi'
    user 'munin'
    minute '*/5'
  end
  cron_d 'munin-cron-3' do
    command 'if [ -x /usr/share/munin/munin-limits ]; then /usr/share/munin/munin-limits; fi'
    user 'munin'
    minute '14'
    hour '10'
  end
end

template "#{node['munin']['basedir']}/munin.conf" do
  source 'munin.conf.erb'
  mode   '0644'
  variables(
    munin_nodes: munin_servers
  )
end

directory "#{node['munin']['basedir']}/munin-conf.d" do
  action :create
end

case node['munin']['server_auth_method']
when 'openid'
  if web_srv == :apache
    include_recipe 'apache2::mod_auth_openid'
  else
    raise 'OpenID is unsupported on non-apache installs'
  end
else
  template "#{node['munin']['basedir']}/htpasswd.users" do
    source 'htpasswd.users.erb'
    owner  'munin'
    group  web_group
    mode   '0644'
    variables(
      sysadmins: sysadmins
    )
  end
end

directory node['munin']['docroot'] do
  owner 'munin'
  group 'munin'
  mode  '0755'
end
