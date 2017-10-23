# Chef Jumpcloud
[![Build Status](https://travis-ci.org/usemarkup/chef-jumpcloud.svg?branch=master)](https://travis-ci.org/usemarkup/chef-jumpcloud)

Installs Jumpcloud for Centos 6 & 7

## Usage

Set the connect_key in the attributes and run the default recipe. The installer is delayed
so the hostname of the machine ideally should be set of the first run of the chef. 

Also if this recipe is used to build images (via Packer etc) set prepare_for_image to true

```ruby
default['jumpcloud']['connect_key'] = 'connect_key'
```

```json
  "run_list": [
    "recipe[jumpcloud]"
  ]
```

## Support

- CentOS 6.x
- CentOS 7.x

### Chef Support (tested)

- Chef 12.7+
- Chef 13.1
