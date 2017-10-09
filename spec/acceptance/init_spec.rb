# run a test task
require 'spec_helper_acceptance'
# bolt regexes
# expect_multiple_regexes(result: result, regexes: [%r{"status":"(stopped|in_sync)"}, %r{Ran on 1 node}])
# expect_multiple_regexes(result: result, regexes: [%r{"status":"stopped"}, %r{"enabled":"false"}, %r{Ran on 1 node}])
describe 'service task' do
  before(:all) do
    apply_manifest('package { "ntp": ensure => present, }')
  end
  describe 'stop action' do
    it 'stop/status a service' do
      result = run_task(task_name: 'service', params: 'action=stop name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : (in_sync|stopped)}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_task(task_name: 'service', params: 'action=status name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : stopped}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'start action' do
    it 'start/status a service' do
      result = run_task(task_name: 'service', params: 'action=start name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : started}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_task(task_name: 'service', params: 'action=status name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'restart action' do
    it 'restart/status a service' do
      result = run_task(task_name: 'service', params: 'action=restart name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : restarted}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_task(task_name: 'service', params: 'action=status name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'enable action' do
    it 'enable/status a service' do
      result = run_task(task_name: 'service', params: 'action=enable name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : enabled}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_task(task_name: 'service', params: 'action=status name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : true}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
  describe 'disable action' do
    it 'enable/status a service' do
      result = run_task(task_name: 'service', params: 'action=disable name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : disabled}, %r{Job completed. 1/1 nodes succeeded}])
      result = run_task(task_name: 'service', params: 'action=status name=ntpd')
      expect_multiple_regexes(result: result, regexes: [%r{status : running}, %r{enabled : false}, %r{Job completed. 1/1 nodes succeeded}])
    end
  end
end
