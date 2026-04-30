# puppetlabs-service: Local Dev Guide

This file orients any Claude session (or human contributor) on how to work in this repo without re-exploring it from scratch.

---

## Module Overview

`puppetlabs-service` is a Puppet task module. It exposes a single Bolt task (`tasks/init.rb`) that manages system services — start, stop, restart, status, enable, disable — by delegating to the Puppet service provider.

There are no Puppet classes, manifests, or defined types. All logic lives in `tasks/init.rb`.

---

## Prerequisites

- Ruby (managed via Puppet's bundler environment or your system Ruby)
- Bundler: `gem install bundler`
- Docker (required for acceptance tests only)

Install Ruby dependencies:

```sh
bundle install
```

---

## Unit Tests

Run unit specs only (once `spec/unit/` exists):

```sh
bundle exec rspec spec/unit
```

Run all specs (requires Docker/Litmus for acceptance tests — see below):

```sh
bundle exec rspec
```

**Current state:** There is no `spec/unit/` directory yet. Running bare `bundle exec rspec` will load `spec/acceptance/` which requires a Litmus inventory and Docker. Until unit specs are added in S02, use `bundle exec rspec spec/unit` once that directory exists, or skip the acceptance tests explicitly:

```sh
bundle exec rspec --exclude-pattern "spec/acceptance/**/*_spec.rb"
```

With no matching specs this exits 0: `0 examples, 0 failures`.

The spec helper is at `spec/spec_helper.rb` (PDK-managed, do not edit) and `spec/spec_helper_local.rb` (project-local overrides, safe to edit).

---

## Coverage Tooling

Run specs with SimpleCov coverage enabled:

```sh
COVERAGE=yes bundle exec rspec
```

### Known broken state (pre-S02 fix)

As of the initial commit, `COVERAGE=yes` is broken for two reasons:

1. **Wrong `track_files` path** — `spec/spec_helper_local.rb` calls `track_files 'lib/**/*.rb'`, but this module has no `lib/` directory. The correct path is `tasks/**/*.rb`.
2. **Missing `simplecov` gem** — `spec/spec_helper_local.rb` requires `simplecov`, but the gem is absent from `Gemfile`.
3. **Broken `require 'codecov'`** — `spec/spec_helper_local.rb` also requires `codecov` and references `SimpleCov::Formatter::Codecov`, but `codecov` is not in the `Gemfile` and has no active CI integration. This causes a `LoadError` at runtime.

Milestone S02 fixes all three issues: adds `simplecov` to the Gemfile, changes `track_files` to `tasks/**/*.rb`, and removes the `codecov` formatter references. Do not revert those fixes.

---

## Acceptance Tests

Acceptance tests use [Litmus](https://github.com/puppetlabs/puppet_litmus) and require Docker.

Run the full parallel acceptance suite:

```sh
bundle exec rake litmus:acceptance:parallel
```

This provisions Docker containers, runs the tests against them, and tears them down. It will not work without Docker running locally.

---

## CI Pipeline

CI is defined in `.github/workflows/ci.yml`. It triggers on:

- `pull_request` targeting `main`
- `workflow_dispatch` (manual trigger)

### Jobs

**Spec** (runs first):

```yaml
uses: puppetlabs/cat-github-actions/.github/workflows/module_ci.yml@main
with:
  runs_on: ubuntu-24.04
```

Runs puppet-lint and RSpec on Ubuntu 24.04.

**Acceptance** (runs after Spec passes):

```yaml
uses: puppetlabs/cat-github-actions/.github/workflows/module_acceptance.yml@main
with:
  flags: "--nightly --platform-exclude centos-7 --platform-exclude oraclelinux-7 --platform-exclude scientific-7 --platform-exclude almalinux-8"
```

Uses nightly Puppet builds. Excludes: `centos-7`, `oraclelinux-7`, `scientific-7`, `almalinux-8` (incompatible OSes).

---

## Git Workflow

- **No direct pushes to `main`.** All changes (including GSD scaffolding) go to a feature branch.
- Branch locally, push to the same remote branch name, open a PR for review.
- Merge only after CI passes and review is complete.

```sh
git checkout -b your-feature-branch
# ... make changes ...
git push -u origin your-feature-branch
# Open PR via GitHub UI or gh CLI
```

---

## tasks/init.rb Structure

The task file uses the Puppet Ruby shebang and must not be changed:

```ruby
#!/opt/puppetlabs/puppet/bin/ruby
```

Six action functions are defined at the top level: `start`, `stop`, `restart`, `status`, `enable`, `disable`. They are dispatched from a script-level block via `send(action, provider)` after reading JSON from `$stdin`.

When writing specs for this file, stub `$stdin` and `JSON.parse` before `require`-ing the file to prevent the script-level block from running during spec load. The six functions are then directly callable with an RSpec double.

---

## spec_helper_local.rb

`spec/spec_helper_local.rb` is the correct target for coverage configuration changes. Do **not** modify `spec/spec_helper.rb` — it is PDK-managed (see the sync comment on line 75) and will be overwritten by PDK updates.

---

## Gemfile Notes

`Gemfile` supports multiple gem sources:

- `GEM_SOURCE` — override the default RubyGems source
- `GEM_SOURCE_PUPPETCORE` — PuppetCore private gem registry (set automatically when `PUPPET_FORGE_TOKEN` is present)
- `PUPPET_GEM_VERSION`, `FACTER_GEM_VERSION`, `HIERA_GEM_VERSION` — pin specific versions

The `:system_tests` group contains Litmus and serverspec. The `:development` group contains RSpec, lint, and coverage gems.
