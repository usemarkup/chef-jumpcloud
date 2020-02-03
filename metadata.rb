name 'jumpcloud'
license 'MIT Licence'
description 'Installs Jumpcloud'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.3'

maintainer 'Gavin Staniforth'
maintainer_email 'gavin@usemarkup.com'

source_url 'https://github.com/usemarkup/chef-jumpcloud'

supports 'centos'

chef_version '>= 13.0' if respond_to?(:chef_version)
