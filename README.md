
# service

#### Table of Contents

1. [Description](#description)
2. [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Getting help - Some Helpful commands](#getting-help)

## Description

This module provides the service task. This task allows you to manage and inspect the state of services, including starting, stopping, enabling, and disabling services.

## Requirements

This module requires Puppet Enterprise 2017.3 or later to be installed on the machine from which you are running task commands (the controller node). Machines receiving task requests must be Puppet agents.

## Usage

To run a service task, use the task command, specifying the action and the name of the service.

1. On the command line, run `puppet task service <ACTION> <SERVICE_NAME>`.

For example, to check the status of the Apache httpd service, run `puppet task service status httpd`

You can also run tasks in the PE console. See PE task documentation for complete information.

## Reference

To view the available actions and parameters, on the command line, run `puppet task show service` or see the service module page on the [Forge](https://forge.puppet.com/puppetlabs/service/tasks).

For a complete list of services that are supported see the Puppet [services](https://docs.puppet.com/puppet/latest/types/service.html) documentation.

## Getting Help

To display help for the service task, run `puppet task show service`

To show help for the task CLI, run `puppet task run --help`

