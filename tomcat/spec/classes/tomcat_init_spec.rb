require 'spec_helper'

describe 'tomcat', :type => :class do
  let(:facts) { { :disposition => 'prod', :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }

  it { should create_class('tomcat') }

end
