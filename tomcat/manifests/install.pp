# == Class: tomcat::install
#
# This class installs tomcat.  It should not be called directly.
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class tomcat::install {

  if $caller_module_name != $module_name {
    fail("Use of private class ${name} by ${caller_module_name}")
  }

  $install_dir = $::tomcat::install_dir

  $sites_mode = $::disposition ? {
    'dev'     => '0777',
    'vagrant' => '0777',
    default   => '0775',
  }

  if !defined(Package['unzip']) {
    package { 'unzip': ensure => 'installed' }
  }

  group { 'tomcat':
    ensure => 'present',
    system => true,
  }

  user { 'tomcat':
    ensure     => present,
    comment    => 'Tomcat Service User',
    system     => true,
    gid        => 'tomcat',
    home       => "${install_dir}/tomcat",
    shell      => '/bin/bash',
    managehome => false,
    require    => Group['tomcat'];
  }

  file { '/etc/init.d/tomcat':
    ensure  => file,
    mode    => '0555',
    owner   => root,
    group   => root,
    content => template('tomcat/tomcat.init.erb'),
  }

  exec { 'fetch_tomcat':
    command   => "/usr/bin/curl -o apache-tomcat-${::tomcat::version}.tar.gz ${::tomcat::real_url}/apache-tomcat-${::tomcat::version}.tar.gz",
    cwd       => '/tmp',
    creates   => "/tmp/apache-tomcat-${::tomcat::version}.tar.gz",
    path      => '/usr/bin/:/bin',
    logoutput => on_failure,
    unless    => "/usr/bin/test -d ${install_dir}/apache-tomcat-${::tomcat::version}",
  }

  exec { 'extract_tomcat':
    command   => "/bin/tar -xzf /tmp/apache-tomcat-${::tomcat::version}.tar.gz -C ${install_dir} && /bin/chown -R tomcat:tomcat ${install_dir}/apache-tomcat-${::tomcat::version} && rm -rf ${install_dir}/apache-tomcat-${::tomcat::version}/logs",
    cwd       => $install_dir,
    creates   => "${install_dir}/apache-tomcat-${::tomcat::version}",
    path      => '/bin/:/usr/bin/',
    require   => [Exec['fetch_tomcat'], User['tomcat']],
    logoutput => on_failure,
  }

  file { "${$install_dir}/tomcat":
    ensure  => 'link',
    target  => "${install_dir}/apache-tomcat-${::tomcat::version}",
    require => Exec['extract_tomcat'],
    replace => $::tomcat::auto_upgrade,
    notify  => Class['tomcat::service'],
  }

  file { $::tomcat::sites_dir:
    ensure => directory,
    owner  => tomcat,
    group  => tomcat,
    mode   => $sites_mode,
  }

  file { "${::tomcat::sites_dir}/logs":
    ensure => link,
    target => $::tomcat::log_dir,
  }

  file { $::tomcat::log_dir:
    ensure => directory,
    mode   => '0644',
    owner  => tomcat,
    group  => tomcat,
  }

  file { "${install_dir}/tomcat/logs":
    ensure  => link,
    target  => $::tomcat::log_dir,
    require => [File[$::tomcat::log_dir], Exec['extract_tomcat']],
  }

  # Remove the default tomcat apps
  file { [  "${install_dir}/tomcat/webapps/docs",
            "${install_dir}/tomcat/webapps/examples",
            "${install_dir}/tomcat/webapps/ROOT",
            "${install_dir}/tomcat/webapps/manager",
            "${install_dir}/tomcat/webapps/host-manager" ]:
    ensure  => absent,
    recurse => true,
    purge   => true,
    force   => true,
  }
}
