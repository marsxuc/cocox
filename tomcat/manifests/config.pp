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
  $http_port = $::tomcat::http_port
  $https_port = $::tocmat::https_port
  $session_manager = $::tomcat::session_manager
  $app_base = $::tomcat::app_base

  File {
    ensure => 'file',
    owner  => 'tomcat',
    group  => 'tomcat',
    mode   => '0444',
    notify => Class['tomcat::service'],
  }

  file { "${install_dir}/tomcat/conf/context.xml":
#    source => 'puppet:///modules/tomcat/context.xml',
    content => template('tomcat/context.xml.erb')
  }

  if $session_manager {
    file { "${install_dir}/tomcat/lib/asm-3.2.jar":
      source => "puppet:///modules/tomcat/lib/asm-3.2.jar",
    }
    file { "${install_dir}/tomcat/lib/couchbase-client-1.1.4.jar":
      source => "puppet:///modules/tomcat/lib/couchbase-client-1.1.4.jar",
    }
    file { "${install_dir}/tomcat/lib/kryo-1.04.jar":
      source => "puppet:///modules/tomcat/lib/kryo-1.04.jar",
    }
    file { "${install_dir}/tomcat/lib/kryo-serializers-0.11.jar":
      source => "puppet:///modules/tomcat/lib/kryo-serializers-0.11.jar",
    }
    file { "${install_dir}/tomcat/lib/memcached-session-manager-1.8.3.jar":
      source => "puppet:///modules/tomcat/lib/memcached-session-manager-1.8.3.jar",
    }
    file { "${install_dir}/tomcat/lib/memcached-session-manager-tc7-1.8.3.jar":
      source => "puppet:///modules/tomcat/lib/memcached-session-manager-tc7-1.8.3.jar",
    }
    file { "${install_dir}/tomcat/lib/minlog-1.2.jar":
      source => "puppet:///modules/tomcat/lib/minlog-1.2.jar",
    }
    file { "${install_dir}/tomcat/lib/msm-kryo-serializer-1.8.3.jar":
      source => "puppet:///modules/tomcat/lib/msm-kryo-serializer-1.8.3.jar",
    }
    file { "${install_dir}/tomcat/lib/reflectasm-1.01.jar":
      source => "puppet:///modules/tomcat/lib/reflectasm-1.01.jar",
    }
    file { "${install_dir}/tomcat/lib/spymemcached-2.8.12.jar":
      source => "puppet:///modules/tomcat/lib/spymemcached-2.8.12.jar",
    }
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

  file { "${install_dir}/tomcat/conf/tomcat-users.xml":
    mode    => '0440',
    content => template('tomcat/tomcat-users.xml.erb'),
  }

  file { "${install_dir}/tomcat/bin/setenv.sh":
    mode    => '0544',
    content => template('tomcat/setenv.sh.erb'),
  }

#  file { "${install_dir}/tomcat/conf/logging.properties":
#    source => 'puppet:///modules/tomcat/logging.properties',
#  }

#  file { "${install_dir}/tomcat/bin/web.xml":
#    source => 'puppet:///modules/tomcat/web.xml',
#  }

#  file { "${install_dir}/tomcat/conf/catalina.policy":
#    source => 'puppet:///modules/tomcat/catalina.policy',
#  }

  $sites_mode = $::disposition ? {
    /(dev|vagrant)/ => '0777',
    default         => '0775',
  }

  file { "${::tomcat::real_dir}":
    ensure => directory,
    owner  => tomcat,
    group  => tomcat,
    mode   => $sites_mode,
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

}
