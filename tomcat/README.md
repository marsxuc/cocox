What is it?
===========

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


Adding a virtual host:
<pre>
  # Tomcat vhost
  tomcat::vhost { 'www':
    aliases  => [ 'www', 'www.mycompany.com', "www.${::fqdn}" ],
    contexts => { 'base' => 'ROOT', 'path' => '' },
  }
</pre>


Installing a WAR from artifactory:
<pre>
  tomcat::war{ 'jenkins':
    app     => 'ROOT',
    source  => 'artifactory',
    project => 'Jenkins',
    site    => 'www',
    version => '1.2.3',
  }
</pre>


Configuring an application:
<pre>
  tomcat::app_config { 'jenkins_properties':
    site          => 'www',
    app           => 'ROOT',
    file          => 'WEB-INF/classes/properties/jenkins.properties',
    content       => template('jenkins/jenkins.properties.erb'),
    reload_tomcat => true,
    }
</pre>


Known Issues:
-------------
Only tested on CentOS 6 and Tomcat 7

TODO:
____
[ ] Expose more configuration options
[ ] Allow sites directory to be outside of $install_dir
[ ] Generic config cleanup


License:
_______

Released under the Apache 2.0 licence


Contribute:
-----------
* Fork it
* Create a topic branch
* Improve/fix (with spec tests)
* Push new topic branch
* Submit a PR
