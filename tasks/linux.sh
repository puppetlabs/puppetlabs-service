#!/bin/bash

# example cli /opt/puppetlabs/puppet/bin/bolt  task run service::linux action=stop name=ntp --nodes localhost --modulepath /etc/ puppetlabs/code/modules --password puppet --user root

# Exit with an error message and error code, defaulting to 1
fail() {
  # Print a message: entry if there were anything printed to stderr
  if [[ -s $_tmp ]]; then
    # Hack to try and output valid json by replacing newlines with spaces.
    echo "{ \"status\": \"error\", \"message\": \"$(tr '\n' ' ' <$_tmp)\" }"
  else
    echo '{ "status": "error" }'
  fi

  exit ${2:-1}
}

success() {
  echo "$1"
  exit 0
}

# Keep stderr in a temp file.  Easier than `tee` or capturing process substitutions
_tmp="$(mktemp)"
exec 2>"$_tmp"

action="$PT_action"
name="$PT_name"
service_managers=("systemctl" "service" "initctl")

for s in "${service_managers[@]}"; do
  if type "$s" &>/dev/null; then
    available_manager="$s"
    break
  fi
done

[[ $available_manager ]] || {
  echo '{ "status": "No service managers found" }'
  exit 255
}

# For any service manager, check if the action is "status". If so, only run a status command
# Otherwise, run the requested action and follow up with a "status" command
case "$available_manager" in
  "systemctl")
    if [[ $action != "status" ]]; then
      "$s" "$action" "$name" || fail
    fi

    # `systemctl show` is the command to use in scripts.  Use it to get the pid, load, and active states
    # sample output: "MainPID=23377,LoadState=loaded,ActiveState=active"
    cmd_out="$("$s" "show" "$name" -p LoadState -p MainPID -p ActiveState --no-pager | paste -sd ',' -)"
    success "{ \"status\": \"${cmd_out}\" }"
    ;;

  # These commands seem to only differ slightly in their invocation
  "service"|"initctl")
    if [[ $s == "service" ]]; then
      cmd=("$s" "$name" "$action")
      cmd_status=("$s" "$name" "status")
    else
      cmd=("$s" "$action" "$name")
      cmd_status=("$s" "status" "$name")
    fi

    if [[ $action != "status" ]]; then
      # service and initctl may return non-zero if the service is already started or stopped
      # If so, check for either "already running" or "Unknown instance" in the output before failing
      "${cmd[@]}" >/dev/null || {
        grep -q "Job is already running" "$_tmp" || grep -q "Unknown instance:" "$_tmp" || fail
      }

    fi

    # "status" is already pretty terse for these commands
    cmd_out="$("${cmd_status[@]}")"
    success "{ \"status\": \"${cmd_out}\" }"
esac
