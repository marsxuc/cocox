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
#   Values: artifactory  (more welcome)
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
#
# === Examples
#
# * Install a war:
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
  $source,
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

  $link_name = "${app}.war"

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
        before       => File["${::tomcat::sites_dir}/${site}/${link_name}"],
      }
    }
    'http': {
      staging::file { $filename:
        source => $war_source,
        target => "${::tomcat::sites_dir}/${site}/${filename}",
        before => File["${::tomcat::sites_dir}/${site}/${link_name}"],
      }
    }
    default: {
      fail('No war source specified')
    }
  }

  file { "${tomcat::sites_dir}/${site}/${link_name}":
    ensure => link,
    target => "${tomcat::sites_dir}/${site}/${filename}",
    notify => Exec["clean_${tomcat::sites_dir}/${site}/${app}"],
  }

  exec { "clean_${tomcat::sites_dir}/${site}/${app}":
    command     => "rm -rf ${app} ; mkdir ${app} ; unzip ${app}.war -d ${app}/",
    cwd         => "${tomcat::sites_dir}/${site}",
    path        => '/usr/bin:/bin',
    user        => tomcat,
    group       => tomcat,
    logoutput   => on_failure,
    refreshonly => true,
    notify      => Class['tomcat::service'],
  }
}
