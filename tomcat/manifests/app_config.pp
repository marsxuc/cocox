# == Define tomcat:;app_config
#
# This define will install a configuration file within an unpacked war.  Some
# applications do not have search paths outside of themselves which makes
# upgrading (and maintaining config) a harder problem.
#
#
# === Parameters
#
# [*app*]
#   String.  Name of the app
#
# [*file*]
#   String.  Relative path to the file WITHIN the unpacked war (not full path)
#
# [*content*]
#   String.  Contents of the file
#
# [*reload_tomcat*]
#   Boolean.  When the config changes, should tomcat be restarted?
#   Default: false
#
# [*replace*]
#   Boolean.  If the file already exists should it be replaced
#   Default: true
#
#
# === Examples
#
# * Add config file to Jenkins:
#     tomcat::app_config { 'jenkins_properties':
#       app           => 'ROOT',
#       file          => 'WEB-INF/classes/properties/jenkins.properties',
#       content       => template('jenkins/jenkins.properties.erb'),
#       reload_tomcat => true,
#     }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define tomcat::app_config(
  $app,
  $file,
  $content,
  $reload_tomcat = false,
  $replace = true,
){

  include ::tomcat
#ͨ��foreman-proxy����puppet master��,parameters��ͨ��hiera�������.
#����foreman��֧��define������,����ֻ��ͨ��manifests�ļ�������,����hiera�����parameters�޷�����define.
#������Ҫ�޸�ģ��,ʹ֮����foreman��ͨ��hiera�����parameters��ֵ.
  $class_conf = hiera_hash('classes')
  $install_dir = $class_conf['tomcat']['install_dir']
  $sites_dir = $class_conf['tomcat']['sites_dir']
#���ʹ��manifests����parameters,��ȡ������2�е�ע��,��ע������3��.
#  $install_dir = $::tomcat::install_dir
#  $sites_dir = $::tomcat::sites_dir

  if $sites_dir == 'webapps'{
    $real_dir = "$install_dir/tomcat/webapps"
  } else {
    $real_dir = $sites_dir
  }

  $real_notify = $reload_tomcat ? {
    /true|True|'true'|1/ => Class['tomcat::service'],
    default              => undef,
  }

  if $real_notify {
    File {
      notify => $real_notify,
    }
  }

  file {
    "${real_dir}/${app}/${file}":
      ensure  => file,
      owner   => tomcat,
      group   => tomcat,
      mode    => '0440',
      content => $content,
      replace => $replace,
  }
}
