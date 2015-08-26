# == Define: tomcat::war
#
# This define is intended to ensure a specific version of a war is installed
# in the correct path and linked to.
#
#
# === Parameters
#
# [*app*]
#   String.  Name of the application
#   Default: $name
#
# [*version*]
#   String.  What version of the application should be installed
#   Default: undef
#
# [*war_source*]
#   String.  Used when fetching from a http source, such as puppet:///modules/tomcat/${app}.war
#   Values:  http(s):// puppet:// ftp:// s3:// local
#   Default: puppet:///modules/tomcat/${filename}
#
# [*contexts*]
#   Array of Hashes.  Contexts to install in server.xml.
#   Allowed keys: base, path, reloadable
#
# [*source*]
#   String.  Source repository type for the application
#   Values:  http(default) artifactory  (more welcome)
#
# [*project*]
#   String.  Used when fetching from an artifact store such as artifactory
#   Default: ''
#
# [*path*]
#   String.  Additional path needed when fetching the application
#   Default: ''
#
# === Examples
#
# * Install a war:
#     tomcat::war{ 'ht':
#       contexts => [{path=>"",base=>"ht",reloadable=>"true"}],
#     }
#  
#     tomcat::war{ 'jenkins':
#       app     => 'ROOT',
#       source  => 'artifactory',
#       project => 'Jenkins',
#       version => '1.2.3',
#     }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define tomcat::war (
  $app         = $name,
  $source     = 'http',
  $project    = undef,
  $path       = undef,
  $version    = undef,
  $war_source = undef,
  $contexts,
) {
  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

#通过foreman-proxy代理puppet master后,parameters是通过hiera来管理的.
#但是foreman不支持define的申明,所以只能通过manifests文件来申明,这样hiera管理的parameters无法传入define.
#所以需要修改模块,使之沿用foreman中通过hiera管理的parameters的值.
  $class_conf = hiera_hash('classes')
  $install_dir = $class_conf['tomcat']['install_dir']
  $sites_dir = $class_conf['tomcat']['sites_dir']
#如果使用manifests管理parameters,请取消以下2行的注释,并注释上面3行.
#  $install_dir = $::tomcat::install_dir
#  $sites_dir = $::tomcat::sites_dir

  if $sites_dir == 'webapps'{
    $real_dir = "$install_dir/tomcat/webapps"
  } else {
    $real_dir = $sites_dir
  }

concat::fragment{ "server_xml_${name}":
    target  => "${install_dir}/tomcat/conf/server.xml",
    content => template('tomcat/war.xml'),
    order   => 10,
  }

#  if ! $app {
#    $app = $name
#  }

  if $version {
    $filename = "${app}-${version}.war"
  } else {
    $filename = "${app}.war"
  }

  if $war_source {
    $real_war_source = $war_source
  } else {
    $real_war_source = "puppet:///modules/tomcat/${filename}"
  }

#  $link_name = "${app}.war"

  case $source {
    'artifactory':  {
      artifactory::fetch_artifact { $name:
        project      => $project,
        version      => $version,
        format       => 'war',
        path         => $path,
        install_path => "${::tomcat::sites_dir}",
        filename     => $filename,
        require      => File[$::tomcat::sites_dir],
#        before       => File["${::tomcat::sites_dir}/${site}/${link_name}"],
        notify => Exec["clean_${real_dir}/${app}"]
      }
    }
    'http': {
      staging::file { $filename:
        source => $real_war_source,
        target => "${real_dir}/${filename}",
#        before => File["${::tomcat::sites_dir}/${site}/${link_name}"],
        notify => Exec["clean_${real_dir}/${app}"]
      }
    }
    default: {
      fail('No war source specified')
    }
  }

##  sometimes, File["${::tomcat::sites_dir}/${site}/${link_name}"] has the same source name with
##  File["$target_file"] in Define[staging::file] at staging module.
#  file { "${tomcat::sites_dir}/${site}/${link_name}":
#    ensure => link,
#    target => "${tomcat::sites_dir}/${site}/${filename}",
#    notify => Exec["clean_${tomcat::sites_dir}/${site}/${app}"],
#  }

  exec { "clean_${real_dir}/${app}":
    command     => "rm -rf ${app} ; mkdir ${app} ; unzip ${filename} -d ${app}/ ; rm -f ${filename}",
    cwd         => "${real_dir}",
    path        => '/usr/bin:/bin',
    user        => tomcat,
    group       => tomcat,
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['tomcat::service'],
  }
}

