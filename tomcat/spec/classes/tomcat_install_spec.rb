require 'spec_helper'

describe 'tomcat', :type => :class do
  let(:facts) { { :disposition => 'prod', :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }
  let(:params) { {
    :install_dir  => '/install_path',
    :log_dir      => '/mylogs',
    :sites_dir    => '/data/sites',
    :version      => '7.0.20',
    :auto_upgrade => false,
    :static_url   => 'http://mysite/tomcat.tar.gz',
  } }

  it { should create_class('tomcat::install') }
  it { should contain_user('tomcat').with_system(true) }
  it { should contain_group('tomcat').with_system(true) }
  it { should contain_file('/etc/init.d/tomcat').with_mode('0555') }
  it { should contain_exec('fetch_tomcat') }
  it { should contain_exec('extract_tomcat') }
  it { should contain_file('/install_path/tomcat').with_replace(false) }
  it { should contain_file('/mylogs').with(
    'owner' => 'tomcat',
    'group' => 'tomcat'
  ) }
  it { should contain_file('/data/sites/logs').with(
    'ensure'  => 'link',
    'target'  => '/mylogs'
  ) }
  it { should contain_file('/install_path/tomcat/logs').with(
    'ensure'  => 'link',
    'target'  => '/mylogs'
  ) }
  [ '/install_path/tomcat/webapps/docs', '/install_path/tomcat/webapps/examples', '/install_path/tomcat/webapps/ROOT',
    '/install_path/tomcat/webapps/manager', '/install_path/tomcat/webapps/host-manager'].each do |default_app|
      it { should contain_file(default_app).with_ensure('absent') }
  end

  context "when on a prod machine" do
    let(:facts) { { :disposition => 'prod', :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }
    it { should contain_file('/data/sites').with_mode('0775') }
  end

  context "when on a dev machine" do
    let(:facts) { { :disposition => 'dev', :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }
    it { should contain_file('/data/sites').with_mode('0777') }
  end

  context "when on a vagrant machine" do
    let(:facts) { { :disposition => 'vagrant', :concat_basedir => '/var/lib/puppet/concat', :osfamily => 'RedHat', :operatingsystem => 'CentOS', :operatingsystemrelease => '7.0', :id => '0', :path => '/tmp', :kernel => 'Linux' } }
    it { should contain_file('/data/sites').with_mode('0777') }
  end

  context "when upgrading" do
    let(:params) { {
      :install_dir  => '/install_path',
      :log_dir      => '/mylogs',
      :sites_dir    => '/data/sites',
      :version      => '7.0.20',
      :auto_upgrade => true,
      :static_url   => 'http://mysite/tomcat.tar.gz',
    } }

    it { should contain_file('/install_path/tomcat').with_replace(true) }
  end

end
