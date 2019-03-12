# run a test task
require 'spec_helper_acceptance'

describe 'windows service task', if: os[:family] == 'windows' do
  package_to_use = 'Spooler'
  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = task_run('service::windows', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Stopped')
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = task_run('service::windows', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Started')
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = task_run('service::windows', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Restarted')
    end
  end

  describe 'status action' do
    it "status #{package_to_use}" do
      result = task_run('service::windows', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => 'Started')
      expect(result[0]['result']).to include('enabled')
    end
  end
end
