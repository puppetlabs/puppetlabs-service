# run a test task
require 'spec_helper_acceptance'
# bolt regexes
# expect_multiple_regexes(result: result, regexes: [%r{"status":"(stopped|in_sync)"}, %r{Ran on 1 node}])
# expect_multiple_regexes(result: result, regexes: [%r{"status":"stopped"}, %r{"enabled":"false"}, %r{Ran on 1 node}])
describe 'service task' do
  package_to_use = ''
  before(:all) do
    if fact_on(default, 'osfamily') != 'windows'
      package_to_use = 'rsyslog'
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
    end
  end
  describe 'enable action' do
    it 'enable/status a service' do
      result = run_task(task_name: 'service', params: "action=enable name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*(in_sync|enabled)}, %r{#{task_summary_line}}])
      result = run_task(task_name: 'service', params: "action=status name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'stop action' do
    it 'stop/status a service' do
      result = run_task(task_name: 'service', params: "action=stop name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*(in_sync|stopped)}, %r{#{task_summary_line}}])
      result = run_task(task_name: 'service', params: "action=status name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*stopped}, %r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'start action' do
    it 'start/status a service' do
      result = run_task(task_name: 'service', params: "action=start name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*started}, %r{#{task_summary_line}}])
      result = run_task(task_name: 'service', params: "action=status name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*running}, %r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'restart action' do
    it 'restart/status a service' do
      result = run_task(task_name: 'service', params: "action=restart name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*restarted}, %r{#{task_summary_line}}])
      result = run_task(task_name: 'service', params: "action=status name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*running}, %r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'disable action' do
    it 'enable/status a service' do
      result = run_task(task_name: 'service', params: "action=disable name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*disabled}, %r{#{task_summary_line}}])
      result = run_task(task_name: 'service', params: "action=status name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*running}, %r{enabled.*false}, %r{#{task_summary_line}}])
    end
  end
end
