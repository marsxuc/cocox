### Module: mcollective
#
# * This module installs, configures mcollective server and installs plugins by yum.
# * Configures mcollective server contact with MQ through PSK encryption.
# * You must have a yum resource.
#
#
### Requirements
#
# module: puppetlabs-stdlib
#
#
### Parameters
#
# [*mco_psk*]
#
#   String. **You must define it in node file.** PSK encryption string. You must define it in node file.
#   Default: undef
#
# [*mco_host*]
#
#   String. **You must define it in node file.** IP address or hostname about MQ Servser.
#   Default: undef
#
# [*mco_port*]
#
#   String. MQ Server's listen port.
#   Default: 61613
#
# [*mco_user*]
#
#   String. MQ Server's username
#   Default: mcollective
#
# [*mco_passwd*]
#
#   String. MQ Server's password
#   Default: secret
#
# [*mco_version*]
#
#   String. Mco Server's version
#   Default: undef
#
# [*mco_plugins*]
#
#   Array. The Plugins to be installed.(plugins puppet, service were installed by default)
#   Default: undef
#
#
### Examples
#
# * Installation
#<pre>
#    class { mcollective:
#      mco_psk => psk_string,
#      mco_host => 10.0.0.1,
#    }
#</pre>
#
# * Add some mcollective plugins
#<pre>
#    class { mcollective:
#      mco_psk => psk_string,
#      mco_host => 10.0.0.1,
#      mco_plugins => ['mcollective-iptables-agent',
#                      'mcollective-iptables-common'],
#    }
#</pre>
#
#
### Authors
#
# * xuchang <mailto:marsxuc@qq.com>
class mcollective (
  $mco_psk     = undef,
  $mco_host    = undef,
  $mco_plugins = [],
  $mco_port    = '61613',
  $mco_user    = 'mcollective',
  $mco_passwd  = 'secret',
  $mco_version = undef,
) {

  if ! $mco_psk {
    fail ("You must define the psk value as parameter mco_psk")
  }

  if ! $mco_host {
    fail ("You must define the MQ service's ip address as parameter mco_host")
  }

  if ! is_array($mco_plugins) {
    fail ('$mco_plugins must be an array!')
  }

  $mco_plugins_default = ['mcollective-puppet-agent',
                          'mcollective-puppet-common',
                          'mcollective-service-agent',
                          'mcollective-service-common',]

  if $mco_plugins {
    $mco_plugins_real = concat($mco_plugins_default,$mco_plugins)
  } else {
    $mco_plugins_real = $mco_plugins_default
  }

  include mcollective::install, mcollective::config, mcollective::service, mcollective::plugins
}
