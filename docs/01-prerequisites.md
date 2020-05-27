# Prerequisites

## Vagrant

This tutorial leverages [Vagrant](https://vagrantup.com/) to streamline provisioning of the compute infrastructure required to bootstrap a Kubernetes cluster from the ground up on your local computer.

## Install vagrant

To install vagrant please follow the instructions for your operating system at the [Vagrant website](https://www.vagrantup.com/intro/getting-started/install.html).

## Running Commands in Parallel with tmux

[tmux](https://github.com/tmux/tmux/wiki) can be used to run commands on multiple compute instances at the same time. Labs in this tutorial may require running the same commands across multiple compute instances, in those cases consider using tmux and splitting a window into multiple panes with synchronize-panes enabled to speed up the provisioning process.

> The use of tmux is optional and not required to complete this tutorial.

![tmux screenshot](images/tmux-screenshot.png)

> Enable synchronize-panes by pressing `ctrl+b` followed by `shift+:`. Next type `set synchronize-panes on` at the prompt. To disable synchronization: `set synchronize-panes off`.

Next: [Installing the Client Tools](02-client-tools.md)
