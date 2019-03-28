# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def bolt_config
    { 'modulepath' => RSpec.configuration.module_path }
  end

  let(:bolt_inventory) { hosts_to_inventory.merge('features' => ['puppet-agent']) }

  package_to_use = 'rsyslog'
  before(:all) do
    if os[:family] == 'redhat' && os[:release].to_i < 6
      options = { inventory: hosts_to_inventory.merge('features' => ['puppet-agent']) }
      params = { 'action' => 'stop', 'name' => 'syslog' }
      run_task('service::linux', 'default', params, options)
    end
    apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_task('service::linux', 'default', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=inactive|stop})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run_task('service::linux', 'default', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=active|running})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run_task('service::linux', 'default', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]).to include('status' => 'success')
      expect(result[0]['result']).to include('status' => %r{ActiveState=active|running})
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
      expect(result[0]['result']['_error']).to include('kind' => 'bash-error')
      expect(result[0]['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_task('service', 'default', params)
      expect(result[0]).to include('status' => 'failure')
      expect(result[0]['result']).to include('status' => 'failure')
      expect(result[0]['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result[0]['result']['_error']).to include('kind' => 'bash-error')
      expect(result[0]['result']['_error']).to include('details')
    end
  end
end
