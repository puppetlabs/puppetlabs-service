# run a test task
require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'service task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def module_path
    RSpec.configuration.module_path
  end

  def config
    { 'modulepath' => module_path }
  end

  def inventory
    hosts_to_inventory.merge('features' => ['puppet-agent'])
  end

  def run(params)
    run_task('service', 'default', params, config: config, inventory: inventory)
  end

  osfamily_fact = fact('osfamily')

  package_to_use = ''
  before(:all) do
    if osfamily_fact != 'windows'
      if osfamily_fact == 'RedHat' && fact('operatingsystemrelease') < '6'
        run('action' => 'stop', 'name' => 'syslog')
      end
      package_to_use = 'rsyslog'
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
      run('action' => 'start', 'name' => package_to_use)
    end
  end

  describe 'enable action' do
    it 'enable/status a service' do
      result = run('action' => 'enable', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|enabled})

      result = run('action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['enabled']).to eq('true')
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = run('action' => 'restart', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('restarted')

      result = run('action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('running')
      expect(result[0]['result']['enabled']).to eq('true')
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = run('action' => 'stop', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|stopped})

      # Debian can give incorrect status
      if osfamily_fact != 'Debian'
        result = run('action' => 'status', 'name' => package_to_use)
        expect(result[0]['status']).to eq('success')
        expect(result[0]['result']['status']).to eq('stopped')
        expect(result[0]['result']['enabled']).to eq('true')
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = run('action' => 'start', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|started})

      # Debian can give incorrect status
      if osfamily_fact != 'Debian'
        result = run('action' => 'status', 'name' => package_to_use)
        expect(result[0]['status']).to eq('success')
        expect(result[0]['result']['status']).to eq('running')
        expect(result[0]['result']['enabled']).to eq('true')
      end
    end
  end

  describe 'disable action' do
    it 'disable/status a service' do
      result = run('action' => 'disable', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('disabled')

      result = run('action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['enabled']).to eq('false')
    end
  end
end
