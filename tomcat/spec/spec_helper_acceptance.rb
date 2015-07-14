require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'

unless ENV['BEAKER_provision'] == 'no'
  hosts.each do |host|
    install_puppet
  end

  hosts.each do |host|
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    hosts.each do |host|
      # Install module and dependencies
      copy_module_to(host, :source => proj_root, :module_name => 'tomcat')
      on host, puppet('module','install', 'puppetlabs-java'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install', 'puppetlabs-concat'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install', 'puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module', 'install', 'nanliu-staging'), { :acceptable_exit_codes => [0,1] }

      # Disable ipv6
      shell('echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6')
      shell('echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6')
    end
  end
end
