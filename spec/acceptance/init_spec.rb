# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  package_to_use = ''
  before(:all) do
    if os[:family] != 'windows'
      if os[:family] == 'redhat' && os[:release].to_i < 6
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
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|enabled})

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('enabled' => 'true')
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = task_run('service', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'restarted')

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'running')
      expect(result[0]['result']).to include('enabled' => 'true')
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = task_run('service', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|stopped})

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(os[:family])
        result = task_run('service', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]).to include('status' => 'success')
        expect(result[0]['result']).to include('status' => 'stopped')
        expect(result[0]['result']).to include('enabled' => 'true')
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = task_run('service', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|started})

      # Debian can give incorrect status
      if os[:family] != 'debian'
        result = task_run('service', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]).to include('status' => 'success')
        expect(result[0]['result']).to include('status' => 'running')
        expect(result[0]['result']).to include('enabled' => 'true')
      end
    end
  end

  describe 'disable action' do
    it 'disable/status a service' do
      result = task_run('service', 'action' => 'disable', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'disabled')

      result = task_run('service', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('enabled' => 'false')
    end
  end
end
