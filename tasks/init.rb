#!/opt/puppetlabs/puppet/bin/ruby

require 'puppet'

def start(provider)
  provider.start
end

def stop(provider)
  provider.stop
end

def restart(provider)
  provider.restart
end

def enable(provider)
  provider.enable unless provider.enabled?
end

def disable(provider)
  provider.disable if provider.enabled?
end

params = JSON.parse(STDIN.read)
name = params['name']
provider = params['provider']
action = params['action']

opts = { name: name }
opts[:provider] = provider if provider

begin
  provider = Puppet::Type.type(:service).new(opts).provider

  initialStatus = provider.status
  send(action, provider) if action != 'status'
  result = {
    name: name,
    action: action,
    initialStatus: initialStatus,
    status: provider.status,
    enabled: provider.enabled?,
  }
  puts result.to_json
  exit 0
rescue Puppet::Error => e
  puts({ status: 'failure',
         name: name,
         action: action,
         _error: { msg: "Unable to perform '#{action}' on '#{name}': " + e.message,
                   kind: 'puppet_error',
                   details: {} } }.to_json)
  exit 1
end
