# run a test task
require 'spec_helper_acceptance'

describe 'linux service task', unless: os[:family] == 'windows' do
  package_to_use = if os[:family] == 'redhat'
                     'httpd'
                   else
                     'apache2'
                   end

  temp_inventory_file = "#{ENV['TARGET_HOST']}.yaml"

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

  context 'when a service does not exist' do
    let(:non_existent_service) { 'foo' }

    it 'reports useful information for status' do
      params = { 'action' => 'restart', 'name' => 'foo' }
      result = run_bolt_task('service::linux', params, expect_failures: true)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{#{non_existent_service}})
      expect(result['result']['_error']).to include('kind' => 'bash-error')
      expect(result['result']['_error']).to include('details')
    end
  end

  context 'when puppet-agent feature not available on target' do
    before(:all) do
      target = targeting_localhost? ? 'litmus_localhost' : ENV['TARGET_HOST']
      inventory_hash = remove_feature_from_node(inventory_hash_from_inventory_file, 'puppet-agent', target)
      write_to_inventory_file(inventory_hash, temp_inventory_file)
    end

    after(:all) do
      File.delete(temp_inventory_file) if File.exist?(temp_inventory_file)
    end

    it 'enable action fails' do
      params = { 'action' => 'enable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true, inventory_file: temp_inventory_file)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'enable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'bash-error')
      expect(result['result']['_error']).to include('details')
    end

    it 'disable action fails' do
      params = { 'action' => 'disable', 'name' => package_to_use }
      result = run_bolt_task('service', params, expect_failures: true, inventory_file: temp_inventory_file)
      expect(result['result']).to include('status' => 'failure')
      expect(result['result']['_error']).to include('msg' => %r{'disable' action not supported})
      expect(result['result']['_error']).to include('kind' => 'bash-error')
      expect(result['result']['_error']).to include('details')
    end
  end
end
