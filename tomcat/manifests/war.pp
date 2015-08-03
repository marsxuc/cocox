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

#  if !defined(Tomcat::Vhost[$site]) {
#    fail("You must include the tomcat site before adding WARs to it.  tomcat::vhost {'${site}': } needed at a minimum")
#  }

  $install_dir = $::tomcat::install_dir

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
        notify => Exec["clean_${tomcat::real_dir}/${app}"]
      }
    }
    'http': {
      staging::file { $filename:
        source => $real_war_source,
        target => "${::tomcat::real_dir}/${filename}",
#        before => File["${::tomcat::sites_dir}/${site}/${link_name}"],
        notify => Exec["clean_${tomcat::real_dir}/${app}"]
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

  exec { "clean_${tomcat::real_dir}/${app}":
    command     => "rm -rf ${app} ; mkdir ${app} ; unzip ${filename} -d ${app}/",
    cwd         => "${tomcat::real_dir}",
    path        => '/usr/bin:/bin',
    user        => tomcat,
    group       => tomcat,
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['tomcat::service'],
  }
}
