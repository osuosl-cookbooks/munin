resource_name :munin_plugin
provides :munin_plugin

default_action :create

property :plugin, String, name_property: true
property :plugin_config, String, default: '/etc/munin/plugins'
property :plugin_dir, String, default: '/usr/share/munin/plugins'
property :create_file, [true, false], default: false
property :cookbook, String, default: 'munin'

action :create do
  if new_resource.create_file
    cookbook_file "#{new_resource.plugin_dir}/#{new_resource.plugin}" do
      cookbook new_resource.cookbook
      source "plugins/#{new_resource.plugin}"
      owner 'root'
      group 'munin'
      mode '0755'
    end
  end
  link "#{new_resource.plugin_config}/#{new_resource.name}" do
    to "#{new_resource.plugin_dir}/#{new_resource.plugin}"
    notifies :restart, 'service[munin-node]'
  end
end

action :delete do
  file "#{new_resource.plugin_dir}/#{new_resource.plugin}" do
    action :delete
  end
  link "#{new_resource.plugin_config}/#{new_resource.name}" do
    to "#{new_resource.plugin_dir}/#{new_resource.plugin}"
    action :delete
    notifies :restart, 'service[munin-node]'
  end
end
