# run a test task
require 'spec_helper_acceptance'

describe 'service task' do
  before(:all) do
    apply_manifest('package { "ntp": ensure => present, }')
    sleep(6)
  end
  describe 'stop' do
    it 'stop a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'stop', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : stopped}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : stopped}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'start' do
    it 'start a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'start', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : started}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'restart' do
    it 'restart a service' do
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'restart', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : restarted}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_puppet_task(task_name: 'service', params: { 'action' => 'status', 'service' => 'ntpd' })
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
end
