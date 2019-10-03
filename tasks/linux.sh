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
      "$service" "$action" "$name" 2>"$_tmp" || fail
    fi

    # `systemctl show` is the command to use in scripts.  Use it to get the pid, load, and active states
    # sample output: "MainPID=23377,LoadState=loaded,ActiveState=active"
    cmd_out="$("$service" "show" "$name" -p LoadState -p MainPID -p ActiveState --no-pager | paste -sd ',' -)"

    if [[ $action != "status" ]]; then
      success "{ \"status\": \"${cmd_out}\" }"
    else
      enabled_out="$("$service" "is-enabled" "$name" 2>&1)"
      success "{ \"status\": \"${cmd_out}\", \"enabled\": \"${enabled_out}\" }"
    fi
    ;;

  "initctl")
    cmd=("$service" "$action" "$name")
    cmd_status=("$service" "status" "$name")

    # The initctl show-config output has 'interesting' spacing/tabs, use word splitting to have single spaces
    word_split=($("$service" show-config "$name" 2>&1))
    enabled_out="${word_split[@]}"

    if [[ $action != "status" ]]; then
      # service and initctl may return non-zero if the service is already started or stopped
      # If so, check for either "already running" or "Unknown instance" or "is not running" in the output before failing
      "${cmd[@]}" &>"$_tmp" || {
        grep -q "already running" "$_tmp" || grep -q "Unknown instance:" "$_tmp" || grep -q "is not running" "$_tmp" || fail
      }

      cmd_out="$("${cmd_status[@]}" 2>&1)"
      success "{ \"status\": \"${cmd_out}\" }"
    fi

    # "status" is already pretty terse for these commands
    cmd_out="$("${cmd_status[@]}" 2>&1)"
    success "{ \"status\": \"${cmd_out}\", \"enabled\": \"${enabled_out}\" }"
    ;;

  "service")
    cmd=("$service" "$name" "$action")
    cmd_status=("$service" "$name" "status")

    # Several possibilities: chkconfig may be installed, the service may be a SysV job, or it may have been converted to Upstart
    # This is exactly why we have systemd now
    if type chkconfig &>/dev/null; then
      # The chkconfig output has 'interesting' spacing/tabs, use word splitting to have single spaces
      word_split=($(chkconfig --list "$name" 2>&1))
    else
      word_split=($("$service" "$name" "show-config"  2>&1))
    fi
    enabled_out="${word_split[@]}"

    if [[ $action != "status" ]]; then
      # service and initctl may return non-zero if the service is already started or stopped
      # If so, check for either "already running" or "Unknown instance" in the output before failing
      "${cmd[@]}" &>"$_tmp" || {
        grep -q "already running" "$_tmp" || grep -q "Unknown instance:" "$_tmp" || grep -q "is not running" "$_tmp" || fail
      }

      cmd_out="$("${cmd_status[@]}" 2>&1)"
      success "{ \"status\": \"${cmd_out}\" }"
    fi

    # "status" is already pretty terse for these commands
    cmd_out="$("${cmd_status[@]}" 2>&1)"
    success "{ \"status\": \"${cmd_out}\", \"enabled\": \"${enabled_out}\" }"
esac
