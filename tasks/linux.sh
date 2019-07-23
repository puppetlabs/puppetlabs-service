#!/bin/bash

# example cli /opt/puppetlabs/puppet/bin/bolt  task run service::linux action=stop name=ntp --nodes localhost --modulepath /etc/ puppetlabs/code/modules --password puppet --user root

declare PT__installdir
source "$PT__installdir/service/files/common.sh"

# Verify service manager is available
service_managers=("systemctl" "service" "initctl")

for service in "${service_managers[@]}"; do
  if type "$service" &>/dev/null; then
    available_manager="$service"
    break
  fi
done

[[ $available_manager ]] || {
  validation_error "No service managers found"
}

# Verify only allowable actions are specified
case "$action" in
  "start"|"stop"|"restart"|"status");;
  *) validation_error "'${action}' action not supported for linux.sh"
esac

# For any service manager, check if the action is "status". If so, only run a status command
# Otherwise, run the requested action and follow up with a "status" command
case "$available_manager" in
  "systemctl")
    if [[ $action != "status" ]]; then
      "$service" "$action" "$name" || fail
    fi

    # `systemctl show` is the command to use in scripts.  Use it to get the pid, load, and active states
    # sample output: "MainPID=23377,LoadState=loaded,ActiveState=active"
    cmd_out="$("$service" "show" "$name" -p LoadState -p MainPID -p ActiveState --no-pager | paste -sd ',' -)"

    if [[ $action != "status" ]]; then
      success "{ \"status\": \"${cmd_out}\" }"
    else
      enabled_out="$("$service" "is-enabled" "$name")"
      success "{ \"status\": \"${cmd_out}\", \"enabled\": \"${enabled_out}\" }"
    fi
    ;;

  # These commands seem to only differ slightly in their invocation
  "service"|"initctl")
    if [[ $service == "service" ]]; then
      cmd=("$service" "$name" "$action")
      cmd_status=("$service" "$name" "status")
      # The chkconfig output has 'interesting' spacing/tabs, use word splitting to have single spaces
      word_split=($(chkconfig --list "$name"))
      enabled_out="${word_split[@]}"
    else
      cmd=("$service" "$action" "$name")
      cmd_status=("$service" "status" "$name")
      enabled_out="$("$service" "show-config" "$name")"
    fi

    if [[ $action != "status" ]]; then
      # service and initctl may return non-zero if the service is already started or stopped
      # If so, check for either "already running" or "Unknown instance" in the output before failing
      "${cmd[@]}" >/dev/null || {
        grep -q "Job is already running" "$_tmp" || grep -q "Unknown instance:" "$_tmp" || fail
      }

      cmd_out="$("${cmd_status[@]}")"
      success "{ \"status\": \"${cmd_out}\" }"
    fi

    # "status" is already pretty terse for these commands
    cmd_out="$("${cmd_status[@]}")"
    success "{ \"status\": \"${cmd_out}\", \"enabled\": \"${enabled_out}\" }"
esac
