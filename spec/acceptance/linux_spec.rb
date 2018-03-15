# run a test task
require 'spec_helper_acceptance'
# bolt regexes
# expect_multiple_regexes(result: result, regexes: [%r{"status":"(stopped|in_sync)"}, %r{Ran on 1 node}])
# expect_multiple_regexes(result: result, regexes: [%r{"status":"stopped"}, %r{"enabled":"false"}, %r{Ran on 1 node}])

describe 'linux service task', unless: fact_on(default, 'osfamily') == 'windows' do
  package_to_use = ''
  before(:all) do
    if fact_on(default, 'osfamily') == 'RedHat' && fact_on(default, 'operatingsystemrelease') < '6'
      run_task(task_name: 'service::linux', params: 'action=stop name=syslog')
    end
    package_to_use = 'rsyslog'
    apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
  end
  describe 'stop action' do
    it "stop #{package_to_use}" do
      result = run_task(task_name: 'service::linux', params: "action=stop name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*(stop)}, %r{#{task_summary_line}}])
    end
  end
  describe 'start action' do
    it "start #{package_to_use}" do
      result = run_task(task_name: 'service::linux', params: "action=start name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*(start)}, %r{#{task_summary_line}}])
    end
  end
  describe 'restart action' do
    it "restart #{package_to_use}" do
      result = run_task(task_name: 'service::linux', params: "action=restart name=#{package_to_use}")
      expect_multiple_regexes(result: result, regexes: [%r{status.*(restart)}, %r{#{task_summary_line}}])
    end
  end
end
