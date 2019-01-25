#!/bin/bash

# TODO: "jq-ify" this

# example cli /opt/puppetlabs/puppet/bin/bolt  task run service::linux action=stop name=ntp --nodes localhost --modulepath /etc/puppetlabs/code/modules --password puppet --user root

# Exit with an error message and error code, defaulting to 1
fail() {
  # Print a message: entry if there were anything printed to stderr
  if [[ -s $_tmp ]]; then
    echo "{ \"status\": \"error\", \"message\": \"$(<$_tmp)\" }"
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

case "$available_manager" in
  # systemd commands don't output anything on success, so follow up with a status command
  # use the is-active subcommand for concise information
  "systemctl")
    if [[ $action != "status" ]]; then
      "$s" "$action" "$name" || fail
    fi
    cmd_out="$("$s" "is-active" "$name")" || fail
    success "{ \"status\": \"$cmd_out\" }"
    ;;

  # service and initd may return non-zero if the service is already started
  "service")
    cmd_out=$("$s" "$name" "$action")
    ret=$?

    if grep -q "Job is already running" "$_tmp"; then
      success '{ "status": "active" }'
    elif (( $ret != 0 )); then
      fail
    else
      success "{ \"status\": \"${cmd_out#* }\" }"
    fi
    ;;

  "initctl")
    cmd_out="$("$s" "$action" "$name")"
    ret=$?

    if grep -q "Job is already running" "$_tmp"; then
      success '{ "status": "active" }'
    elif (( $ret != 0 )); then
      fail
    else
      success "{ \"status\": \"${cmd_out#* }\" }"
    fi
esac
