#
class tomcat::params {

  $install_dir     = '/usr/share'
  $log_dir         = '/var/log/tomcat'
  $sites_dir       = '/usr/share/tomcat/sites'
  $version         = '7.0.57'
  $auto_upgrade    = false
  $static_url      = undef
  $admin_pass      = 'changeme'
  $java_opts       = '-XX:+DoEscapeAnalysis -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalMode -XX:PermSize=128m -XX:MaxPermSize=128m -Xms512m -Xmx512m'
  $env_vars        = []
  $manage_service  = true
  $header_fragment = 'tomcat/server.xml.header'
  $footer_fragment = 'tomcat/server.xml.footer'

}
