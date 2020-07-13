# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
  package_to_use = if os[:family] == 'redhat'
                     'httpd'
                   else
                     'apache2'
                   end

  before(:all) do
    apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
  end

  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'stop', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      # The additional complexity in this matcher is to support Ubuntu 14.04
      # For some reason it returns `service` instead of `systemctl` information.
      expect(result['result']).to include('status' => %r{(ActiveState=(inactive|stop)| is (not running|stopped))})
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
  
  describe 'enable action' do
    it "enable #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'enable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => 'enabled')
    end
  end

  describe 'disable action' do
    it "disable #{package_to_use}" do
      result = run_bolt_task('service::linux', 'action' => 'disable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => 'disabled')
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

    it 'does not use the ruby task' do
      result = run_bolt_task('service', 'action' => 'restart', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{ActiveState=active|running})
    end
  end
end
