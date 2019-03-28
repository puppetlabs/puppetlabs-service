# run a test task
require 'spec_helper_acceptance'

describe 'windows service task', if: os[:family] == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => RSpec.configuration.module_path }
  end

  let(:bolt_inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  package_to_use = 'Spooler'

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_task('service::windows', 'default', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Stopped')
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run_task('service::windows', 'default', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Started')
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run_task('service::windows', 'default', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Restarted')
    end
  end

  describe 'status action' do
    it "status #{package_to_use}" do
      result = run_task('service::windows', 'default', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Started')
      expect(result[0]['result']).to include('enabled')
    end
  end

  context 'when puppet-agent feature not available on target' do
    let(:bolt_inventory) { hosts_to_inventory }

    it 'enable action fails' do
      params = { 'action' => 'enable', 'name' => package_to_use }
      result = run_task('service', 'default', params)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'enable' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'powershell_error')
      expect(result[0]['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_task('service', 'default', params)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'powershell_error')
      expect(result[0]['result']['_error']).to include('details')
    end
  end
end
