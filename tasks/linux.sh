inux.sh: line 19: local: can only be used in a function
#!/bin/bash

action="$PT_action"
name="$PT_name"
service_managers[0]="systemctl"
service_managers[1]="service"
service_managers[2]="initctl"

# example cli /opt/puppetlabs/puppet/bin/bolt  task run service::linux action=stop name=ntp --nodes localhost --modulepath /etc/puppetlabs/code/modules --password puppet --user root

check_command_exists() {
  (which "$1") > /dev/null 2>&1
  command_exists=$?
  return $command_exists
}

for service_manager in "${service_managers[@]}"
do
  check_command_exists "$service_manager"
  command_exists=$?
  if [ $command_exists -eq 0 ]; then
    command_line="$service_manager $action $name"
    if [ $service_manager == "service" ]; then
      command_line="$service_manager $name $action"
    fi
    output=$($command_line 2>&1)
    status_from_command=$?
    # set up our status and exit code
    if [ $status_from_command -eq 0 ]; then
      echo "{ \"status\": \"$name $action\" }"
      exit 0
    else
      # initd is special, starting an already started service is an error
      if [[ $service_manager == "service" && "$output" == *"Job is already running"* ]]; then
        echo "{ \"status\": \"$name $action\" }"
        exit 0
      fi
      echo "{ \"status\": \"unable to run command '$command_line'\" }"
      exit $status_from_command
    fi
  fi
done

echo "{ \"status\": \"No service managers found\" }"
exit 255
