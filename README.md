
# service

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
     * [Requirements](#requirements)
4. [Usage](#usage)
     * [Default task](#default-task)
     * [Linux task](#linux-task)
     * [Windows task](#windows-task)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Overview

Module provides services tasks.

## Module Description

The service module contains two kinds of tasks. The default task: that uses the puppet agent on the target node to manage and inspect the state of services. The linux task: that manipulates services on a linux derivative without a puppet agent installed on the target node.

## Setup

### Requirements
This module is compatible with Puppet Enterprise and Puppet Bolt.

* To run tasks with Puppet Enterprise, PE 2018.1 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must be Puppet agents.
* To run tasks with Puppet Bolt, Bolt 1.0 or later must be installed on the machine from which you are running task commands. Machines receiving task requests must have SSH or WinRM services enabled.

## Usage

* To view the available actions and parameters, on the command line, run `puppet task show service`
* To view the completed list of services that are supported see the Puppet [services](https://docs.puppet.com/puppet/latest/types/service.html) documentation.
* To run a service task, use the task command, specifying the action and the name of the service.
* To show help for the task CLI, run `puppet task run --help` or `bolt task run --help`

### Default task

* With PE on the command line, run `puppet task run service action=<ACTION> name=<SERVICE_NAME>`.
* With Bolt on the command line, run `bolt task run service action=<ACTION> name=<SERVICE_NAME>`.

For example, to check the status of the Apache httpd service, run:

* With PE, run `puppet task run service action=status name=httpd --nodes neptune`
* With Bolt, run `bolt task run service action=status name=httpd --nodes neptune --modulepath ~/modules`

### Linux task

* With PE on the command line, run `puppet task run service::linux action=<ACTION> name=<SERVICE_NAME>`.
* With Bolt on the command line, run `bolt task run service::linux action=<ACTION> name=<SERVICE_NAME>`.

For example, to check the status of the Apache httpd service, run:

* With PE, run `puppet task run service::linux action=status name=httpd --nodes neptune`
* With Bolt, run `bolt task run service::linux action=status name=httpd --nodes neptune --modulepath ~/modules`

You can also run tasks in the PE console. See PE task documentation for complete information.

### Windows task

* With PE on the command line, run `puppet task run service::windows action=<ACTION> name=<SERVICE_NAME>`.
* With Bolt on the command line, run `bolt task run service::windows action=<ACTION> name=<SERVICE_NAME>`.

For example, to check the status of the lmhosts service, run:

* With PE, run `puppet task run service::windows action=status name=lmhosts --nodes neptune`
* With Bolt, run `bolt task run service::windows action=status name=lmhosts --nodes neptune --modulepath ~/modules`

You can also run tasks in the PE console. See PE task documentation for complete information.

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-service/blob/master/REFERENCE.md).

## Limitations

To run acceptance tests against Windows machines, ensure that the `BEAKER_password` environment variable has been set to the password of the Administrator user of the target machine.

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-service/blob/master/metadata.json)

## Development

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. To contribute to Puppet projects, see our [module contribution guide.](https://github.com/puppetlabs/puppetlabs-service/blob/master/CONTRIBUTING.md)