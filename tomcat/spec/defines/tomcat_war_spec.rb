require 'spec_helper'

describe 'tomcat::war', :type => :define do
  let(:pre_condition) { ['class { "tomcat": }', 'tomcat::vhost { "mysite": }'] }
  let(:title) { 'mywar' }
  let(:facts) { { :concat_basedir => '/var/lib/puppet/concat', :disposition => 'prod', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }

  context 'artifactory source' do
    let(:params) { {
      :app      => 'myapp',
      :project  => 'myproject',
      :site     => 'mysite',
      :source   => 'artifactory',
      :version  => '1.2.3',
    } }

    it { should contain_artifactory__fetch_artifact('mywar').with(
      :version  => '1.2.3',
      :filename => 'myapp.war-1.2.3'
    )}

    it { should contain_file('/usr/share/tomcat/sites/mysite/myapp.war').with(
     :ensure  => 'link',
     :target  => '/usr/share/tomcat/sites/mysite/myapp.war-1.2.3'
    ) }

    it { should contain_exec('clean_/usr/share/tomcat/sites/mysite/myapp').with(
      :command  => 'rm -rf myapp ; mkdir myapp ; unzip myapp.war -d myapp/',
      :cwd      => '/usr/share/tomcat/sites/mysite'
    ) }
  end

  context 'invalid source' do
    let(:params) { {
      :app    => 'myapp',
      :site   => 'mysite',
      :source => 'invalid',
    } }

    it { expect { should raise_error(Puppet::Error) } }
  end

end
