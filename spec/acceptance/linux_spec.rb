# run a test task
require 'spec_helper_acceptance'
require 'beaker-task_helper/inventory'
require 'bolt_spec/run'

describe 'linux service task', unless: fact('osfamily') == 'windows' do
  include Beaker::TaskHelper::Inventory
  include BoltSpec::Run

  def module_path
    RSpec.configuration.module_path
  end

  def config
    { 'modulepath' => module_path }
  end

  def inventory
    hosts_to_inventory
  end

  def run(params)
    run_task('service::linux', 'default', params, config: config, inventory: inventory)
  end

  package_to_use = 'rsyslog'
  before(:all) do
    if fact('osfamily') == 'RedHat' && fact('operatingsystemrelease') < '6'
      run('action' => 'stop', 'name' => 'syslog')
    end
    apply_manifest_on(default, "package { \"#{package_to_use}\": ensure => present, }")
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run('action' => 'stop', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{stop})
    end
  end

  describe 'start action' do
    it "start #{package_to_use}" do
      result = run('action' => 'start', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{start})
    end
  end

  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run('action' => 'restart', 'name' => package_to_use)
      expect(result[0]['status']).to eq('success')
      expect(result[0]['result']['status']).to match(%r{restart})
    end
  end
end
