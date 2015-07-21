class mcollective::config {

  file { '/etc/mcollective/server.cfg':
    ensure  => file,
    mode    => '644',
    content => template('mcollective/server.cfg.erb'),
    require => Class["mcollective::install"],
    notify  => Class["mcollective::service"],
  }
}
