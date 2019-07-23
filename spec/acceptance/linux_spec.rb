# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
  package_to_use = 'rsyslog'
  before(:all) do
    if os[:family] == 'redhat' && os[:release].to_i < 6
      params = { 'action' => 'stop', 'name' => 'syslog' }
      run_bolt_task('service::linux', params)
    end
    apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'stop', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{ActiveState=inactive|stop})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'start', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{ActiveState=active|running})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'restart', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{ActiveState=active|running})
    end
  end

  context 'when puppet-agent feature not available on target' do
    before(:all) do
      unless ENV['TARGET_HOST'] == 'localhost'
        inventory_hash = inventory_hash_from_inventory_file
        inventory_hash = remove_feature_from_node(inventory_hash, 'puppet-agent', ENV['TARGET_HOST'])
        write_to_inventory_file(inventory_hash, 'inventory.yaml')
      end
    end

    it 'enable action fails' do
      skip('Cannot mock inventory features during localhost acceptance testing') if ENV['TARGET_HOST'] == 'localhost'
      params = { 'action' => 'enable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'enable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'bash-error')
      expect(result['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      skip('Cannot mock inventory features during localhost acceptance testing') if ENV['TARGET_HOST'] == 'localhost'
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'bash-error')
      expect(result['result']['_error']).to include('details')
    end
  end
end
