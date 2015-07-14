# == Class: tomcat
#
# This class installs and configures tomcat from source
#
#
# === Parameters
#
# [*install_dir*]
#   String.  Where should tomcat be unpacked (/tomcat is appended)
#   Default: /usr/share
#
# [*log_dir*]
#   String.  Location logs should be written
#   Default: /var/log/tomcat
#
# [*sites_sub_dir*]
#   String.  Where should sites be installed
#   Default: sites
#
# [*version*]
#   String.  Version of tomcat to be installed
#   Default: 7.0.57
#
# [*auto_upgrade*]
#   Boolean.  Whether puppet will update the symlink for newer versions of tomcat
#   Default: false
#
# [*static_url*]
#   String.  URL to download tomcat from
#   Default: '' (apache mirror)
#
# [*admin_pass*]
#   String.  Password to set for the admin user
#   Default: changeme
#
# [*java_opts*]
#   String.  Java options to pass to tomcat
#   Default: -XX:+DoEscapeAnalysis -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:PermSize=128m -XX:MaxPermSize=128m -Xms512m -Xmx512m
#
# [*env_vars*]
#   Array.  Additional environment variables to pass to Tomcat, in the form KEY=VALUE
#   Default: []
#
# [*mange_service*]
#   Boolean.  Whether puppet should manage the service
#   Default: true
#
# [*header_fragment*]
#   String.  Path to a template to be evaluated inside tomcat::config, which will generate the server.xml header.
#   Default: false
#
# [*footer_fragment*]
#   String.  Path to a template to be evaluated inside tomcat::config, which will generate the server.xml footer.
#   Default: false
#
#
# === Examples
#
# * Installation:
#     class { 'tomcat': }
#
# * Installation (custom server.xml header):
#     class { 'tomcat':
#       header_fragment => 'my_custom_module/server.xml.header.erb',
#     }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class tomcat(
  $install_dir     = $::tomcat::params::install_dir,
  $log_dir         = $::tomcat::params::log_dir,
  $sites_dir       = $::tomcat::params::sites_dir,
  $version         = $::tomcat::params::version,
  $auto_upgrade    = $::tomcat::params::auto_upgrade,
  $static_url      = $::tomcat::params::static_url,
  $admin_pass      = $::tomcat::params::admin_pass,
  $java_opts       = $::tomcat::params::java_opts,
  $env_vars        = $::tomcat::params::env_vars,
  $manage_service  = $::tomcat::params::manage_service,
  $header_fragment = $::tomcat::params::header_fragment,
  $footer_fragment = $::tomcat::params::footer_fragment,
) inherits tomcat::params {

  include ::java

  if $static_url {
    $real_url = $static_url
  } else {
    $real_url = "http://download.nextag.com/apache/tomcat/tomcat-7/v${version}/bin"
  }

  anchor { '::tomcat::begin': } ->
  class { '::tomcat::install': } ->
  class { '::tomcat::config': } ->
  class { '::tomcat::service': } ->
  anchor { '::tomcat::end': }

}
