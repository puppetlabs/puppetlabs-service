# frozen_string_literal: true

# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  package_to_use = ''
  before(:all) do
    if os[:family] == 'windows'
      package_to_use = 'W32Time'
      params = { 'action' => 'start', 'name' => package_to_use }
      run_bolt_task('service', params)
    else
      package_to_use = if os[:family] == 'redhat'
                         'httpd'
                       else
                         'apache2'
                       end
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
    end
  end

  describe 'enable action', unless: (os[:family] == 'windows') do
    it 'enable/status a service' do
      result = run_bolt_task('service', 'action' => 'enable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|enabled|active})

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => %r{true|enabled}i)
    end
  end

  describe 'restart action' do
    it 'restart/status a service' do
      result = run_bolt_task('service', 'action' => 'restart', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{restarted|active}i)

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{running|Started|active}i)
      expect(result['result']).to include('enabled' => %r{true|manual|automatic|delayed|enabled}i)
    end
  end

  describe 'stop action' do
    it 'stop/status a service' do
      result = run_bolt_task('service', 'action' => 'stop', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|stopped|inactive}i)

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(os[:family])
        result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
        expect(result.exit_code).to eq(0)
        expect(result['result']).to include('status' => %r{stopped|inactive}i)
        expect(result['result']).to include('enabled' => %r{true|manual|automatic|delayed|enabled}i)
      end
    end
  end

  describe 'start action' do
    it 'start/status a service' do
      result = run_bolt_task('service', 'action' => 'start', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{in_sync|started|active}i)

      # Debian can give incorrect status
      unless ['debian', 'ubuntu'].include?(os[:family])
        result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
        expect(result.exit_code).to eq(0)
        expect(result['result']).to include('status' => %r{running|Started|active}i)
        expect(result['result']).to include('enabled' => %r{true|manual|automatic|delayed|enabled}i)
      end
    end
  end

  describe 'disable action', unless: (os[:family] == 'windows') do
    it 'disable/status a service' do
      result = run_bolt_task('service', 'action' => 'disable', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('status' => %r{disabled|active})

      result = run_bolt_task('service', 'action' => 'status', 'name' => package_to_use)
      expect(result.exit_code).to eq(0)
      expect(result['result']).to include('enabled' => %r{false|disabled})
    end
  end
end
