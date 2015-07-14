# == Class: tomcat::config
#
# This class configures tomcat.  It should not be called directly.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class tomcat::config {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $install_dir = $::tomcat::install_dir
  $admin_pass = $::tomcat::admin_pass
  $java_opts = $::tomcat::java_opts
  $env_vars = $::tomcat::env_vars

  File {
    ensure => 'file',
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0444',
    notify => Class['tomcat::service'],
  }

  file { "${install_dir}/tomcat/conf/catalina.policy":
    source => 'puppet:///modules/tomcat/catalina.policy',
  }

  file { "${install_dir}/tomcat/conf/context.xml":
    source => 'puppet:///modules/tomcat/context.xml',
  }

  file { "${install_dir}/tomcat/conf/logging.properties":
    source => 'puppet:///modules/tomcat/logging.properties',
  }

  file { "${install_dir}/tomcat/conf/tomcat-users.xml":
    mode    => '0440',
    content => template('tomcat/tomcat-users.xml.erb'),
  }

  file { "${install_dir}/tomcat/bin/setenv.sh":
    mode    => '0544',
    content => template('tomcat/setenv.sh.erb'),
  }

  file { "${install_dir}/tomcat/bin/web.xml":
    source => 'puppet:///modules/tomcat/web.xml',
  }

  file { "${install_dir}/tomcat/conf/Catalina":
    ensure  => directory,
    mode    => '0555',
    purge   => true,
    recurse => true,
    force   => true,
  }

  file { "${install_dir}/tomcat/conf/Catalina/localhost":
    ensure  => directory,
    mode    => '0555',
    purge   => true,
    recurse => true,
  }

  concat{
    "${install_dir}/tomcat/conf/server.xml":
      owner  => tomcat,
      group  => tomcat,
      mode   => '0444',
      notify => Class['tomcat::service'],
  }

  concat::fragment{ 'server_xml_header':
    target  => "${install_dir}/tomcat/conf/server.xml",
    content => template($::tomcat::header_fragment),
    order   => '01',
  }

  concat::fragment{ 'server_xml_footer':
    target  => "${install_dir}/tomcat/conf/server.xml",
    content => template($::tomcat::footer_fragment),
    order   => '99',
  }

}
