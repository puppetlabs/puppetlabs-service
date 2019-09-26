# run a test task
require 'spec_helper_acceptance'

describe 'windows service task', if: os[:family] == 'windows' do
  package_to_use = 'W32Time'

  before(:all) do
    # Ensure the service is enabled before interacting.
    run_bolt_task('service', 'action' => 'enable', 'name' => package_to_use)
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_bolt_task('service::windows', 'action' => 'stop', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'Stopped')
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run_bolt_task('service::windows', 'action' => 'start', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'Started')
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run_bolt_task('service::windows', 'action' => 'restart', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result.stdout).to match(%r{Restarted})
    end
  end

  describe 'status action' do
    it "status #{package_to_use}" do
      result = run_bolt_task('service::windows', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => 'Started')
      expect(result['result']).to include('enabled')
    end
  end

  context 'when puppet-agent feature not available on target' do
    before(:all) do
      target = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = remove_feature_from_node(inventory_hash_from_inventory_file, 'puppet-agent', target)
      write_to_inventory_file(inventory_hash, 'inventory.yaml')
    end

    it 'enable action fails' do
      params = { 'action' => 'enable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'enable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'powershell_error')
      expect(result['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'powershell_error')
      expect(result['result']['_error']).to include('details')
    end
  end
end
