require 'spec_helper'

describe 'tomcat::app_config', :type => :define do
  let(:title) { 'tomcat_config' }
  let(:facts) { { :disposition => 'prod', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :concat_basedir => '/var/lib/puppet/concat', :id => '0', :path => '/tmp', :kernel => 'Linux' } }

  context 'no reload' do
    let(:params) { {
      :site     => 'mysite',
      :app      => 'myapp',
      :file     => 'config.properties',
      :content  => 'disabled=true',
    } }

    it { should contain_file('/usr/share/tomcat/sites/mysite/myapp/config.properties').with_notify('') }
  end

  context 'reload' do
    let(:params) { {
      :site           => 'mysite',
      :app            => 'myapp',
      :file           => 'config.properties',
      :content        => 'disabled: true',
      :reload_tomcat  => true,
    } }

    it { should contain_file('/usr/share/tomcat/sites/mysite/myapp/config.properties').with_notify('Class[Tomcat::Service]')}
  end

end
