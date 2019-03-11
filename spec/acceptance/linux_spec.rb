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
    BoltSpec::Run.instance_methods(apply_manifest("package { \"#{package_to_use}\": ensure => present, }", 'default',
                                                  execute: true,
                                                  config: { 'modulepath' => RSpec.configuration.module_path },
                                                  inventory: hosts_to_inventory.merge('features' => ['puppet-agent'])))
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'stop', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{stop})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'start', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{start})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = task_run('service::linux', 'action' => 'restart', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{restart})
    end
  end
end
