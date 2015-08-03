class mcollective::service {

  service { 'mcollective':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class["mcollective::config"]
  }
}
