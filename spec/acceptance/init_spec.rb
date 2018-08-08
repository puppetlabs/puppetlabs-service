# run a test task
require 'spec_helper_acceptance'
# bolt regexes
# expect_multiple_regexes(result: result, regexes: [%r{"status":"(stopped|in_sync)"}, %r{Ran on 1 node}])
# expect_multiple_regexes(result: result, regexes: [%r{"status":"stopped"}, %r{"enabled":"false"}, %r{Ran on 1 node}])

def run_and_expect(params, regex_hash)
  expect_multiple_regexes(result: run_task(task_name: 'service', params: params), regexes: regex_hash)
end

describe 'service task' do
  package_to_use = ''
  before(:all) do
    if fact_on(default, 'osfamily') != 'windows'
      if fact_on(default, 'osfamily') == 'RedHat' && fact_on(default, 'operatingsystemrelease') < '6'
        run_task(task_name: 'service', params: 'action=stop name=syslog')
      end
      package_to_use = 'rsyslog'
      apply_manifest("package { \"#{package_to_use}\": ensure => present, }")
    else
      package_to_use = 'W32Time'
      run_and_expect("action=start name=#{package_to_use}", [%r{status.*(in_sync|started)}, %r{#{task_summary_line}}])
    end
  end
  describe 'enable action' do
    it 'enable/status a service' do
      run_and_expect("action=enable name=#{package_to_use}",
                     [%r{status.*(in_sync|enabled)}, %r{#{task_summary_line}}])
      run_and_expect("action=status name=#{package_to_use}",
                     [%r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'restart action' do
    it 'restart/status a service' do
      run_and_expect("action=restart name=#{package_to_use}",
                     [%r{status.*restarted}, %r{#{task_summary_line}}])
      run_and_expect("action=status name=#{package_to_use}",
                     [%r{status.*running}, %r{enabled.*true}, %r{#{task_summary_line}}])
    end
  end
  describe 'stop action' do
    it 'stop/status a service' do
      run_and_expect("action=stop name=#{package_to_use}", [%r{status.*(in_sync|stopped)}, %r{#{task_summary_line}}])
      # Debian can give incorrect status
      if fact_on(default, 'osfamily') != 'Debian'
        run_and_expect("action=status name=#{package_to_use}", [%r{status.*stopped}, %r{enabled.*true}, %r{#{task_summary_line}}])
      end
    end
  end
  describe 'start action' do
    it 'start/status a service' do
      run_and_expect("action=start name=#{package_to_use}", [%r{status.*(in_sync|started)}, %r{#{task_summary_line}}])
      # Debian can give incorrect status
      if fact_on(default, 'osfamily') != 'Debian'
        run_and_expect("action=status name=#{package_to_use}", [%r{status.*running}, %r{enabled.*true}, %r{#{task_summary_line}}])
      end
    end
  end
  describe 'disable action' do
    it 'disable/status a service' do
      run_and_expect("action=disable name=#{package_to_use}",
                     [%r{status.*disabled}, %r{#{task_summary_line}}])
      run_and_expect("action=status name=#{package_to_use}",
                     [%r{enabled.*false}, %r{#{task_summary_line}}])
    end
  end
end
