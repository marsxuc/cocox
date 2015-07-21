# == Class: mcollective
#
# This class installs, configures mcollective server and installs plugins by yum.
# Mcollective server contact with MQ through PSK encryption.
# You must have a yum resource.
#
# == Parameters
#
# [*mco_psk*]
#   String. PSK encryption string. You must define it in node file.
#   Default: undef
#
# [*mco_host*]
#   String. IP address or hostname about MQ Servser. You must define it in node file.
#   Default: undef
#
# [*mco_port*]
#   String. MQ Server's listen port.
#   Default: 61613
#
# [*mco_user*]
#   String. MQ Server's username
#   Default: mcollective
#
# [*mco_passwd*]
#   String. MQ Server's password
#   Default: secret
#
# [*mco_version*]
#   String. MQ Server's version
#   Default: undef
#
# [*mco_plugins*]
#   Array. The Plugins to be installed.
#   Default: ['mcollective-puppet-agent',
#             'mcollective-puppet-common',
#             'mcollective-service-agent',
#             'mcollective-service-common',]
#
#
# === Examples
#
# * Installation
#    class { mcollective:
#      mco_psk => psk_string,
#      mco_host => MQ_Service_IP,
#    }
#
#
# === Authors
#
# * xuchang <mailto:marsxuc@qq.com>
#
class mcollective (
  $mco_psk     = undef,
  $mco_host    = undef,
  $mco_plugins = ['mcollective-puppet-agent',
                  'mcollective-puppet-common',
                  'mcollective-service-agent',
                  'mcollective-service-common',],
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

  include mcollective::install, mcollective::config, mcollective::service, mcollective::plugins
}
