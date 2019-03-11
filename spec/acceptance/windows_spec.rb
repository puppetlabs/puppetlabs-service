# run a test task
require 'spec_helper_acceptance'

describe 'windows service task', if: fact('osfamily') == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  let(:module_path) { RSpec.configuration.module_path }
  let(:config) { { 'modulepath' => module_path } }
  let(:inventory) { hosts_to_inventory }

  def run(params)
    run_task('service::windows', 'default', params, config: config, inventory: inventory)
  end

  package_to_use = 'Spooler'

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run('action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{Stopped})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run('action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{started})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run('action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{restarted})
    end
  end

  describe 'status action' do
    it "status #{package_to_use}" do
      result = run('action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{started})
      expect(result[0]['result']).to include('enabled' => 'Automatic')
    end
  end
end
