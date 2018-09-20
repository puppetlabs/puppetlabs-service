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
