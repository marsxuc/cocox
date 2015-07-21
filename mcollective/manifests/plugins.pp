class mcollective::plugins {

  $mco_plugins = $mcollective::mco_plugins

  package { $mco_plugins:
    ensure  => installed,
    notify  => Service[mcollective],
  }
}
