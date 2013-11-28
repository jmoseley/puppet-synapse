require 'spec_helper'

describe 'synapse' do
  context 'supported operating systems' do
    ['Debian', 'RedHat'].each do |osfamily|
      describe "synapse class without any parameters on #{osfamily}" do
        let(:params) {{ }}
        let(:facts) {{
          :osfamily => osfamily
        }}
        it { should include_class('synapse::params') }
        it { should contain_class('synapse::install') }
        it { should contain_class('synapse::config') }
        it { should contain_class('synapse::system_service') }
      end
    end
  end

  context 'when asked to install via gem' do
    let(:params) {{ :package_provider => 'gem', }}
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_package('synapse').with(
      :ensure   => '0.7.0',
      :provider => 'gem',
      :name     => 'synapse'
    ) }
  end

  context 'when given a specific package name and provider' do
    let(:params) {{ :package_ensure   => 'latest',
                    :package_provider => 'bla',
                    :package_name     => 'special-synapse'
    }}
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_package('synapse').with(
      :ensure   => 'latest',
      :provider => 'bla',
      :name     => 'special-synapse'
    ) }
  end

  context 'when not specified how to install' do
    let(:params) {{ }}
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_package('synapse').with(
      :ensure   => '0.7.0',
      :provider => nil,
      :name     => 'rubygem-synapse'
    ) }
  end
  
  # Config stuff
  context 'config by default' do
    let(:params) {{  }}
    let(:facts) {{ :osfamily => 'Debian',
                   :fqdn     => 'random_hostname'
    }}
    it { should contain_file('/etc/synapse/synapse.conf.json').with(
      :ensure   => 'present',
      :mode     => '0444'
    ) }
    it { should contain_file('/etc/synapse/synapse.conf.json').with_content(/"instance_id": "random_hostname"/) }
    it { should contain_file('/etc/synapse/synapse.conf.json').with_content(/"service_conf_dir": "\/etc\/synapse\/conf.d\/"/) }
    it { should contain_file('/etc/synapse/conf.d/').with(
      :ensure   => 'directory',
      :purge    => true
    ) }
  end

  context 'When alernate params are specified' do
    let(:params) {{ :config_file  => '/opt/bla.json',
                    :config_dir   => '/tmp/synapse.d/',
                    :purge_config => false
    }}
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_file('/opt/bla.json').with(
      :ensure   => 'present',
      :mode     => '0444'
    ) }
    it { should contain_file('/opt/bla.json').with_content(/"service_conf_dir": "\/tmp\/synapse.d\/"/) }
    it { should contain_file('/tmp/synapse.d/').with(
      :ensure   => 'directory',
      :purge    => false
    ) }
  end

  # Service Stuff
  context 'when requested not to run' do
    let(:params) {{ :service_ensure => 'stopped' }}
    let(:facts) {{ :osfamily => 'Debian' }}
    it { should contain_service('synapse').with(
      :ensure   => 'stopped'
    ) }
  end

  context 'unsupported operating system' do
    describe 'synapse class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta'
      }}

      it { expect { should }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
