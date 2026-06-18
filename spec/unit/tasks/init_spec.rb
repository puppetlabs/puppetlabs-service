# frozen_string_literal: true

require 'spec_helper'

# tasks/init.rb is a script, not a library. When require'd it runs the
# dispatch block at the bottom (lines 52-72). We intercept that execution
# at file-load time using plain Ruby method redefinition rather than RSpec
# mocks (which are not active outside the per-test lifecycle).

# ---------------------------------------------------------------------------
# Pre-require scaffolding (runs once at RSpec file-load time)
# ---------------------------------------------------------------------------

# 1. Prevent $stdin.read from blocking.
$stdin.define_singleton_method(:read) do |*|
  '{"name":"noop","action":"status"}'
end

# 2. Return a deterministic params hash from JSON.parse so the dispatch block
#    gets known values (action: "status", provider: nil). Capture the original
#    method object so we can restore it without breaking module_function.
original_json_parse = JSON.method(:parse)
JSON.define_singleton_method(:parse) do |*|
  { 'name' => 'noop', 'action' => 'status', 'provider' => nil }
end

# 3. Build a minimal Puppet::Type stand-in so the dispatch block's
#    Puppet::Type.type(:service).new(opts).provider call succeeds harmlessly.
noop_provider_obj = Object.new.tap do |p|
  p.define_singleton_method(:status)   { :running }
  p.define_singleton_method(:enabled?) { 'true' }
end
noop_instance_obj = Object.new.tap do |i|
  i.define_singleton_method(:provider) { noop_provider_obj }
end
noop_svc_type_obj = Object.new.tap do |t|
  t.define_singleton_method(:new) { |*| noop_instance_obj }
end
noop_puppet_type_mod = Module.new do
  define_singleton_method(:type) { |*| noop_svc_type_obj }
end

original_puppet_type = Puppet::Type
Puppet.send(:remove_const, :Type) # rubocop:disable RSpec/RemoveConst
Puppet.const_set(:Type, noop_puppet_type_mod)

# 4. Stub Kernel#exit so the dispatch block's `exit 0` does not kill RSpec.
module KernelExitStub
  def exit(*) = nil # swallow exit during file load
end
Object.prepend(KernelExitStub)

# 5. Require the task file — the dispatch block now runs harmlessly.
require_relative '../../../tasks/init'

# 6. Restore exit — use define_method to avoid Lint/DuplicateMethods cop.
KernelExitStub.define_method(:exit) { |*args| super(*args) }

# 7. Restore Puppet::Type.
Puppet.send(:remove_const, :Type) # rubocop:disable RSpec/RemoveConst
Puppet.const_set(:Type, original_puppet_type)

# 8. Restore $stdin.read (remove the singleton method so the original is used).
$stdin.singleton_class.remove_method(:read)

# 9. Restore JSON.parse via the saved UnboundMethod — this avoids the
#    module_function copy-removal problem that `remove_method` would cause.
orig_json_parse = original_json_parse
JSON.define_singleton_method(:parse) do |*args, **kwargs, &blk|
  orig_json_parse.call(*args, **kwargs, &blk)
end

# ---------------------------------------------------------------------------
# Specs
# ---------------------------------------------------------------------------

describe 'tasks/init.rb' do
  let(:provider) { double('provider') } # rubocop:disable RSpec/VerifiedDoubles

  # -------------------------------------------------------------------------
  # start
  # -------------------------------------------------------------------------
  describe '#start' do
    context 'when service is already running' do
      before(:each) { allow(provider).to receive(:status).and_return(:running) }

      it 'returns in_sync without calling provider.start' do
        expect(start(provider)).to eq({ status: 'in_sync' })
      end
    end

    context 'when service is stopped' do
      before(:each) do
        allow(provider).to receive(:status).and_return(:stopped)
        allow(provider).to receive(:start)
      end

      it 'starts the service and returns started' do
        expect(start(provider)).to eq({ status: 'started' })
      end
    end
  end

  # -------------------------------------------------------------------------
  # stop
  # -------------------------------------------------------------------------
  describe '#stop' do
    context 'when service is already stopped' do
      before(:each) { allow(provider).to receive(:status).and_return(:stopped) }

      it 'returns in_sync without calling provider.stop' do
        expect(stop(provider)).to eq({ status: 'in_sync' })
      end
    end

    context 'when service is running' do
      before(:each) do
        allow(provider).to receive(:status).and_return(:running)
        allow(provider).to receive(:stop)
      end

      it 'stops the service and returns stopped' do
        expect(stop(provider)).to eq({ status: 'stopped' })
      end
    end
  end

  # -------------------------------------------------------------------------
  # restart
  # -------------------------------------------------------------------------
  describe '#restart' do
    before(:each) { allow(provider).to receive(:restart) }

    it 'restarts the service and returns restarted' do
      expect(restart(provider)).to eq({ status: 'restarted' })
    end
  end

  # -------------------------------------------------------------------------
  # status
  # -------------------------------------------------------------------------
  describe '#status' do
    before(:each) do
      allow(provider).to receive_messages(status: :running, enabled?: 'true')
    end

    it 'returns status and enabled? from the provider' do
      expect(status(provider)).to eq({ status: :running, enabled: 'true' })
    end
  end

  # -------------------------------------------------------------------------
  # enable
  # -------------------------------------------------------------------------
  describe '#enable' do
    context 'when service is already enabled (enabled? returns "true")' do
      before(:each) { allow(provider).to receive(:enabled?).and_return('true') }

      it 'returns in_sync without calling provider.enable' do
        expect(enable(provider)).to eq({ status: 'in_sync' })
      end
    end

    context 'when service is disabled (enabled? returns "false")' do
      before(:each) do
        allow(provider).to receive(:enabled?).and_return('false')
        allow(provider).to receive(:enable)
      end

      it 'enables the service and returns enabled' do
        expect(enable(provider)).to eq({ status: 'enabled' })
      end
    end
  end

  # -------------------------------------------------------------------------
  # disable
  # -------------------------------------------------------------------------
  describe '#disable' do
    context 'when service is enabled (enabled? returns "true")' do
      before(:each) do
        allow(provider).to receive(:enabled?).and_return('true')
        allow(provider).to receive(:disable)
      end

      it 'disables the service and returns disabled' do
        expect(disable(provider)).to eq({ status: 'disabled' })
      end
    end

    context 'when service is already disabled (enabled? returns "false")' do
      before(:each) { allow(provider).to receive(:enabled?).and_return('false') }

      it 'returns in_sync without calling provider.disable' do
        expect(disable(provider)).to eq({ status: 'in_sync' })
      end
    end
  end
end
