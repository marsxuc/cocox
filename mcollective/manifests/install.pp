class mcollective::install {

  if $mcollective::mco_version {
    $version = $mcollective::mco_version
  } else {
    $version = 'installed'
  }

  package { 'mcollective':
    ensure => $version,
  }
}
