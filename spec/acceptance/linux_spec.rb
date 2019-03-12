# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
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

  context 'when puppet-agent feature not available on target' do
    let(:config) { { 'modulepath' => RSpec.configuration.module_path } }
    let(:inventory) { hosts_to_inventory }

    it 'enable action fails' do
      params = { 'action' => 'enable', 'name' => package_to_use }
      result = run_task('service', 'default', params, config: config, inventory: inventory)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'enable' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'bash-error')
      expect(result[0]['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_task('service', 'default', params, config: config, inventory: inventory)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'bash-error')
      expect(result[0]['result']['_error']).to include('details')
    end
  end
end
