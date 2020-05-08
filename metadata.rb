name              'munin'
maintainer        'Jesse R. Adams'
maintainer_email  'jesse@techno-geeks.org'
license           'Apache-2.0'
description       'Installs and configures munin'
version           '1.4.4'

depends 'apache2', '>= 1.7'
depends 'chef_nginx', '>= 1.8'

supports 'arch'
supports 'centos'
supports 'debian'
supports 'fedora'
supports 'freebsd'
supports 'redhat'
supports 'scientific'
supports 'ubuntu'
