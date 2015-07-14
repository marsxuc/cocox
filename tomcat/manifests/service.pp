# == Class: tomcat::service
#
# This class manages the tomcat service.  It should not be called directly
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class tomcat::service {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  if $::tomcat::manage_service {
    service { 'tomcat':
      ensure  => running,
      enable  => true,
      require => Class['java'],
    }
  }
}
