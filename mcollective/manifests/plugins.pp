class mcollective::plugins {

  $mco_plugins_real = $mcollective::mco_plugins_real

  package { $mco_plugins_real:
    ensure  => installed,
    notify  => Service[mcollective],
  }
}
