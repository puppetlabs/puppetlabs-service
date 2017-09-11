# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  before(:all) do
    apply_manifest('package { "ntp": ensure => present, }')
    sleep(6)
  end
  describe 'stop action' do
    it 'stop/status a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'stop', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : in_sync}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : stopped}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'start action' do
    it 'start/status a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'start', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : started}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'restart action' do
    it 'restart/status a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'restart', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : restarted}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'enable action' do
    it 'enable/status a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'enable', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : enabled}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : true}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'disable action' do
    it 'enable/status a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'disable', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : disabled}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
end
