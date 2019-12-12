# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v1.2.0](https://github.com/puppetlabs/puppetlabs-service/tree/v1.2.0) (2019-12-12)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/v1.1.0...v1.2.0)

### Added

- \(FM-8695\) - Addition of Support for CentOS 8 [\#124](https://github.com/puppetlabs/puppetlabs-service/pull/124) ([david22swan](https://github.com/david22swan))

### Fixed

- \(MAINT\) Fix Case Statement Logic [\#117](https://github.com/puppetlabs/puppetlabs-service/pull/117) ([RandomNoun7](https://github.com/RandomNoun7))
- \(MODULES-9979\) Fix empty return values in Linux task [\#116](https://github.com/puppetlabs/puppetlabs-service/pull/116) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [v1.1.0](https://github.com/puppetlabs/puppetlabs-service/tree/v1.1.0) (2019-09-20)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/1.0.0...v1.1.0)

### Added

- \(FM-8212\) Convert to acceptance testing to litmus [\#103](https://github.com/puppetlabs/puppetlabs-service/pull/103) ([michaeltlombardi](https://github.com/michaeltlombardi))
- \(MODULES-9230\) Force Windows Service Action [\#99](https://github.com/puppetlabs/puppetlabs-service/pull/99) ([RandomNoun7](https://github.com/RandomNoun7))
- \(FM-8159\) Add Windows Server 2019 support [\#98](https://github.com/puppetlabs/puppetlabs-service/pull/98) ([eimlav](https://github.com/eimlav))
- \(FM-8047\) Add RedHat8 as supported OS [\#97](https://github.com/puppetlabs/puppetlabs-service/pull/97) ([michaeltlombardi](https://github.com/michaeltlombardi))

## [1.0.0](https://github.com/puppetlabs/puppetlabs-service/tree/1.0.0) (2019-04-24)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/v0.6.0...1.0.0)

### Changed

- pdksync - \(MODULES-8444\) - Raise lower Puppet bound [\#91](https://github.com/puppetlabs/puppetlabs-service/pull/91) ([david22swan](https://github.com/david22swan))

## [v0.6.0](https://github.com/puppetlabs/puppetlabs-service/tree/v0.6.0) (2019-04-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/0.5.0...v0.6.0)

### Added

- \(SEN-796\) Move extension metadata [\#86](https://github.com/puppetlabs/puppetlabs-service/pull/86) ([conormurraypuppet](https://github.com/conormurraypuppet))
- \(SEN-796\) Add discovery extension metadata [\#85](https://github.com/puppetlabs/puppetlabs-service/pull/85) ([conormurraypuppet](https://github.com/conormurraypuppet))
- \(BOLT-1103\) Unify output of task implementations [\#83](https://github.com/puppetlabs/puppetlabs-service/pull/83) ([donoghuc](https://github.com/donoghuc))

### Fixed

- \(MODULES-8717\) Fix dependency issue with BoltSpec [\#80](https://github.com/puppetlabs/puppetlabs-service/pull/80) ([eimlav](https://github.com/eimlav))

## [0.5.0](https://github.com/puppetlabs/puppetlabs-service/tree/0.5.0) (2019-01-09)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/0.4.0...0.5.0)

### Added

- \(MODULES-8391\) Enable implementations on the init task and hide others [\#61](https://github.com/puppetlabs/puppetlabs-service/pull/61) ([MikaelSmith](https://github.com/MikaelSmith))

### Fixed

- \(MODULES-8420\) Move to GEM\_BOLT pattern [\#65](https://github.com/puppetlabs/puppetlabs-service/pull/65) ([donoghuc](https://github.com/donoghuc))
- pdksync - \(FM-7655\) Fix rubygems-update for ruby \< 2.3 [\#62](https://github.com/puppetlabs/puppetlabs-service/pull/62) ([tphoney](https://github.com/tphoney))

## [0.4.0](https://github.com/puppetlabs/puppetlabs-service/tree/0.4.0) (2018-09-28)

[Full Changelog](https://github.com/puppetlabs/puppetlabs-service/compare/0.3.1...0.4.0)

### Added

- pdksync - \(MODULES-6805\) metadata.json shows support for puppet 6 [\#53](https://github.com/puppetlabs/puppetlabs-service/pull/53) ([tphoney](https://github.com/tphoney))
- \(FM-7264\) - Addition of support for ubuntu 18.04 [\#45](https://github.com/puppetlabs/puppetlabs-service/pull/45) ([david22swan](https://github.com/david22swan))
- \[FM-7059\] Addition of support for Debian 9 to service [\#44](https://github.com/puppetlabs/puppetlabs-service/pull/44) ([david22swan](https://github.com/david22swan))

### Fixed

- \(maint\) - Fix so that W32Time is running at start of test [\#47](https://github.com/puppetlabs/puppetlabs-service/pull/47) ([david22swan](https://github.com/david22swan))

## 0.3.1
### Summary
Fixes a bug with the service::linux agentless task failing on the PE orchestratior.

### Fixed
- Stray line breaking service::linux task

## Release 0.3.0
### Summary
This release adds the ability to manage services without the puppet-agent being installed on the remote host.

### Added
- Agentless windows service management
- Agentless linux service management
- Linux task service restart

## Release 0.2.0
### Summary
This release uses the PDK convert functionality which in return makes the module PDK compliant. It also includes a roll up of maintenance changes.

### Changed
- Update modules to modulepath [MODULES-5945](https://tickets.puppetlabs.com/browse/MODULES-5945).
- Test cleanup.
- Disable sysklogd on Linux to allow testing against rsyslog service.
- Modulesync maintenance.

## Release 0.1.3

### Fixed
- Readme updates.
- Service attribute is now name.

## Release 0.1.2

### Fixed
- Fixed locales project name.
- Fixed cli description.

## Release 0.1.1
This is the initial release of the service task.

## Features
- Provides the following actions start, stop, restart, enable, disable, status.
- Provider can optionally be specified.


\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*
