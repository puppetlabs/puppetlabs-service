# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  package_to_use = ''
  before(:all) do
    unless ENV['TARGET_HOST'] == 'localhost'
      inventory_hash = inventory_hash_from_inventory_file
      add_feature_to_node(inventory_hash, 'puppet-agent', ENV['TARGET_HOST'])
      write_to_inventory_file(inventory_hash, 'inventory.yaml')
    end
    if os[:family] != 'windows'
      if os[:family] == 'redhat' && os[:release].to_i < 6
        params = { 'action' => 'stop', 'name' => 'syslog' }
        run_bolt_task('service', params)
      end
      package_to_use = 'rsyslog'
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
      params = { 'action' => 'start', 'name' => package_to_use }
      run_bolt_task('service', params)
    end
  end

  describe 'enable action' do
    it 'enable/status a service' do
      result = run_bolt_task('service', 'action' => 'enable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|enabled})

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => 'true')
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = run_bolt_task('service', 'action' => 'restart', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'restarted')

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'running')
      expect(result['result']).to include('enabled' => 'true')
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = run_bolt_task('service', 'action' => 'stop', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|stopped})

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(os[:family])
        result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
        expect(result.exit_code).to eq(0)
        expect(result['result']).to include('status' => 'stopped')
        expect(result['result']).to include('enabled' => 'true')
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = run_bolt_task('service', 'action' => 'start', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|started})

      # Debian can give incorrect status
      if os[:family] != 'debian'
        result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
        expect(result.exit_code).to eq(0)
        expect(result['result']).to include('status' => 'running')
        expect(result['result']).to include('enabled' => 'true')
      end
    end
  end

  describe 'disable action' do
    it 'disable/status a service' do
      result = run_bolt_task('service', 'action' => 'disable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'disabled')

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => 'false')
    end
  end
end
