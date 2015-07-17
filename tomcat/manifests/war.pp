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
#
# [*site*]
#   String.  What site is this app installed in
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
# [*version*]
#   String.  What version of the application should be installed
#   Default: ''
#
# [*war_source*]
#   String.  Used when fetching from a http source, such as puppet:///modules/tomcat/${app}.war
#   Values:  http(s):// puppet:// ftp:// s3:// local
#
# === Examples
#
# * Install a war:
#     tomcat::war{ 'ht':
#       app        => 'ht',
#       war_source => 'puppet:///modules/tomcat/ht.war',
#       site       => 'www',
#     }
#  
#     tomcat::war{ 'jenkins':
#       app     => 'ROOT',
#       source  => 'artifactory',
#       project => 'Jenkins',
#       site    => 'www',
#       version => '1.2.3',
#     }
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
define tomcat::war (
  $app,
  $site,
  $source     = 'http',
  $project    = undef,
  $path       = undef,
  $version    = undef,
  $war_source = undef,
) {

  if !defined(Class['tomcat']) {
    fail('You must include the tomcat base class before using any tomcat defined resources')
  }

  if !defined(Tomcat::Vhost[$site]) {
    fail("You must include the tomcat site before adding WARs to it.  tomcat::vhost {'${site}': } needed at a minimum")
  }

  if $version {
    $filename = "${app}.war-${version}"
  } else {
    $filename = "${app}.war"
  }

#  $link_name = "${app}.war"

  case $source {
    'artifactory':  {
      artifactory::fetch_artifact { $name:
        project      => $project,
        version      => $version,
        format       => 'war',
        path         => $path,
        install_path => "${::tomcat::sites_dir}/${site}",
        filename     => $filename,
        require      => File[$::tomcat::sites_dir],
#        before       => File["${::tomcat::sites_dir}/${site}/${link_name}"],
        notify => Exec["clean_${tomcat::sites_dir}/${site}/${app}"]
      }
    }
    'http': {
      staging::file { $filename:
        source => $war_source,
        target => "${::tomcat::sites_dir}/${site}/${filename}",
#        before => File["${::tomcat::sites_dir}/${site}/${link_name}"],
        notify => Exec["clean_${tomcat::sites_dir}/${site}/${app}"]
      }
    }
    default: {
      fail('No war source specified')
    }
  }

#  sometimes File["${::tomcat::sites_dir}/${site}/${link_name}"] has the same source name with
#  File["$target_file"] in Define[staging::file]
#  file { "${tomcat::sites_dir}/${site}/${link_name}":
#    ensure => link,
#    target => "${tomcat::sites_dir}/${site}/${filename}",
#    notify => Exec["clean_${tomcat::sites_dir}/${site}/${app}"],
#  }

  exec { "clean_${tomcat::sites_dir}/${site}/${app}":
    command     => "rm -rf ${app} ; mkdir ${app} ; unzip ${filename} -d ${app}/",
    cwd         => "${tomcat::sites_dir}/${site}",
    path        => '/usr/bin:/bin',
    user        => tomcat,
    group       => tomcat,
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['tomcat::service'],
  }
}
