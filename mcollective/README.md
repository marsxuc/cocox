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
#   String. MQ Server's version
#   Default: undef
#
# [*mco_plugins*]
#
#   Array. The Plugins to be installed.(these plugins is default to be installed:puppet, service)
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
