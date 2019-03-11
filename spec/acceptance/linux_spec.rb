# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  package_to_use = 'rsyslog'
  before(:all) do
    if os[:family] == 'redhat' && os[:release].to_i < 6
      task_run('service::linux', 'action' => 'stop', 'name' => 'syslog')
    end
    apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=inactive|stop})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=active|running})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=active|running})
    end
  end

  describe 'status action' do
    it "status #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'status', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=active|running})
      expect(result[0]['result']).to include('enabled')
    end
  end
end
