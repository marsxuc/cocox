require 'spec_helper_acceptance'

describe 'acli classes' do

  context 'install/configure' do
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'tomcat': }
      tomcat::vhost { 'www': }
      tomcat::war { 'sample': app => 'sample', site => 'www', source => 'http', war_source => 'https://tomcat.apache.org/tomcat-7.0-doc/appdev/sample/sample.war', version => '1' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe service('tomcat') do
      it { should be_running }
      it { should be_enabled }
    end

    describe port(8009) do
      it { should be_listening }
    end

  end

end
