munin Cookbook CHANGELOG
========================
This file is used to list changes made in each version of the munin cookbook.

3.0.0 (2020-09-24)
------------------
- Migrate away from using chef_nginx to nginx cookbook

2.1.0 (2020-08-31)
------------------
- Chef 16 Fixes

v1.4.3
------
- Added server_list attribute to contain a list of IP addresses of Munin servers (thanks [docwhat](https://github.com/docwhat))

v1.4.2
------
- Loosened dependencies on other cookbooks (thanks [kesor](https://github.com/kesor))
- Switched to ChefSpec 3.1 and added more tests (thanks [kampfschlaefer](https://github.com/kampfschlaefer) + [sethvargo](https://github.com/sethvargo)/[btm](https://github.com/btm))
- Provided /etc/munin/munin-conf.d for additional configuration (thanks [kampfschlaefer](https://github.com/kampfschlaefer))
- Extended multi environment monitoring to optionally just include certain chef environments via an array (thanks [kampfschlaefer](https://github.com/kampfschlaefer))

v1.4.0
------
### Bug
- **[COOK-3581](https://tickets.opscode.com/browse/COOK-3581)** - Ensure munin-node is started before enabling the service
- **[COOK-3224](https://tickets.opscode.com/browse/COOK-3224)** - Fix crashe in client recipe (comparison of Chef::Node with Chef::Node failed)
- **[COOK-2881](https://tickets.opscode.com/browse/COOK-2881)** - Use correct log dir on EPEL

### New Feature
- **[COOK-3471](https://tickets.opscode.com/browse/COOK-3471)** - Add initial Chef solo support

v1.3.2
------
### Bug
- [COOK-2965] - munin cookbook has foodcritic failures

v1.3.0
------
- [COOK-2518] - Multi Environment
- [COOK-2662] - `munin::server_apache2` fatal due to attribute precendence

v1.2.0
------
- [COOK-2103] - Name the munin-hosts by fqdn instead of pure hostname
- [COOK-2182] - FC043 - prefer new notification syntax in munin
  cookbook
- [COOK-2137] - SmartOS support for Munin
- [COOK-2140] - nginx template `server_name` incorrect

v1.1.2
------
- [COOK-1600] - add an attribute for setting the listen port.
- [COOK-1750] - readme typo fix

v1.1.0
------
- [COOK-1122] - amazon platform support
- [COOK-1143] - munin_plugin() should accept an optional cookbook parameter
- [COOK-1205] - Add NGINX support to munin
- [COOK-1517] - attributes for `max_processes`, `max_graph_jobs`, and `max_cgi_graph_jobs`

v1.0.2
------
- [COOK-920] - FreeBSD support

v1.0.0
------
- [COOK-923] - account for empty node search results
- [COOK-500] - sort server list from search
- [COOK-501] - add support for RHEL platforms
- [COOK-918] - updates required for latest `mod_auth_openid` and add htauth basic option.

v0.99.0
------
- Use Chef 0.10's `node.chef_environment` instead of `node['app_environment']`.
