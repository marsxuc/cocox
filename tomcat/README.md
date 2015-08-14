What is it?
===========

**rewrite based on evenup-tomcat (v0.12.0)**

A puppet module to install and configure tomcat and manage applications and
their config.  This module supports tomcat vhosts, managing WARs, and
configuration located within a decompressed war.  This module also includes
an init script for RHEL based systems.


Usage:
------

Generic tomcat install
<pre>
  class { 'tomcat': }
</pre>

Installing a WAR from artifactory:
<pre>
  tomcat::war{ 'jenkins':
    app        => 'jenkins',
    war_source => 'puppet:///modules/tomcat/jenkins.war',
    contexts   => [{base=>"jenkins",path=>"",reloadable=>"true"}],
  }
  
  tomcat::war{ 'ht':
    contexts => [{base=>"ht",path=>"/ht",reloadable=>"true"}],
    version  => '1.2.3',
  }
</pre>

Configuring an application:
<pre>
  tomcat::app_config { 'memcache.properties':
    app           => 'ht',
    file          => 'WEB-INF/classes/memcache.properties',
    content       => template('tomcat/common/memcache.properties'),
  }
  tomcat::app_config { 'jenkins_properties':
    app           => 'jenkins',
    file          => 'WEB-INF/classes/properties/jenkins.properties',
    content       => template('jenkins/jenkins.properties.erb'),
    reload_tomcat => true,
  }
</pre>


Known Issues:
-------------
* Only tested on CentOS 6 and Tomcat 7
* Only one default vhost (localhost) which define in server.xml

TODO:
____
[ ] Expose more configuration options
[x] Allow sites directory to be outside of $install_dir
[ ] 部署多个tomcat程序

## Authors

* xuchang <mailto:marsxuc@qq.com>