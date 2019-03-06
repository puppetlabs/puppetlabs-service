# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  osfamily_fact = os[:family]

  package_to_use = ''
  before(:all) do
    if osfamily_fact != 'windows'
      if osfamily_fact == 'redhat' && os[:release].to_i < 6
        task_run('service', 'action' => 'stop', 'name' => 'syslog')
      end
      package_to_use = 'rsyslog'
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
      task_run('service', 'action' => 'start', 'name' => package_to_use)
    end
  end

  describe 'enable action' do
    it 'enable/status a service' do
      result = task_run('service', 'action' => 'enable', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|enabled})

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['enabled']).to eq('true')
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = task_run('service', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('restarted')

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('running')
      expect(result[0]['result']['enabled']).to eq('true')
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = task_run('service', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|stopped})

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(osfamily_fact)
        result = task_run('service', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]['status']).to eq('success')
        expect(result[0]['result']['status']).to eq('stopped')
        expect(result[0]['result']['enabled']).to eq('true')
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = task_run('service', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{in_sync|started})

      # Debian can give incorrect status
      if osfamily_fact != 'debian'
        result = task_run('service', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]['status']).to eq('success')
        expect(result[0]['result']['status']).to eq('running')
        expect(result[0]['result']['enabled']).to eq('true')
      end
    end
  end

  describe 'disable action' do
    it 'disable/status a service' do
      result = task_run('service', 'action' => 'disable', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to eq('disabled')

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['enabled']).to eq('false')
    end
  end
end
