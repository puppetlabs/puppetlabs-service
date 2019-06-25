# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => RSpec.configuration.module_path }
  end

  let(:bolt_inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  package_to_use = ''
  before(:all) do
    options = { inventory: hosts_to_inventory.merge('features' => ['puppet-agent']) }
    if os[:family] != 'windows'
      if os[:family] == 'redhat' && os[:release].to_i < 6
        params = { 'action' => 'stop', 'name' => 'syslog' }
        run_task('service', 'default', params, options)
      end
      package_to_use = 'rsyslog'
      apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
      params = { 'action' => 'start', 'name' => package_to_use }
      run_task('service', 'default', params, options)
    end
  end

  describe 'enable action' do
    it 'enable/status a service' do
      result = run_task('service', 'default', 'action' => 'enable', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|enabled})

      result = run_task('service', 'default', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('enable' => 'true')
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = run_task('service', 'default', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'restarted')

      result = run_task('service', 'default', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'running')
      expect(result[0]['result']).to include('enable' => 'true')
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = run_task('service', 'default', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|stopped})

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(os[:family])
        result = run_task('service', 'default', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]).to include('status' => 'success')
        expect(result[0]['result']).to include('status' => 'stopped')
        expect(result[0]['result']).to include('enable' => 'true')
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = run_task('service', 'default', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{in_sync|started})

      # Debian can give incorrect status
      if os[:family] != 'debian'
        result = run_task('service', 'default', 'action' => 'status', 'name' => package_to_use)
        expect(result[0]).to include('status' => 'success')
        expect(result[0]['result']).to include('status' => 'running')
        expect(result[0]['result']).to include('enable' => 'true')
      end
    end
  end

  describe 'disable action' do
    it 'disable/status a service' do
      result = run_task('service', 'default', 'action' => 'disable', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'disabled')

      result = run_task('service', 'default', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('enable' => 'false')
    end
  end
end
