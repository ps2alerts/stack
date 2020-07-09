# ps2alerts-stack

![Ansible Linter](https://github.com/ps2alerts/stack/workflows/Ansible%20Linter/badge.svg) ![Yaml Linter](https://github.com/ps2alerts/stack/workflows/Yaml%20Lint/badge.svg) 

Powers the central services required to run the following projects:
 
* [PS2Alerts/api](https://github.com/PS2Alerts/api)
* [PS2Alerts/websocket](https://github.com/PS2Alerts/websocket)
* [PS2Alerts/website](https://github.com/PS2Alerts/website)

THIS PROJECT IS UNDERGOING A VAST RE-REWITE. If you wish to contribute, please join our Discord located at: https://discord.gg/7xF65ap

# Getting Started

The PS2Alerts project utilises Kubernetes for its deployment and containerisation solution. It matches current infrastructure, and it solves a TON of headaches when it comes to getting code out to the world. Particularly SSL certificates. Fuck SSL certificate management.

**Linux Debian** is the only supported operating system for development. I won't help you with issues to do with your environment if you're running anything other than Linux. It can be done in Windows, but it's a hassle. All the tools we use have a Windows version, thankfully, but it may need some modification to get it to work.

## Requirements

* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Virtual Box](https://www.virtualbox.org/wiki/Downloads) - Required for Minikube
* [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
* [Docker](https://docs.docker.com/get-docker)
* A terminal program / PowerShell. For Linux I recommend [Terminator](https://gnometerminator.blogspot.com/p/introduction.html).
* A good IDE. I recommend [PHPStorm](https://www.jetbrains.com/phpstorm/) (paid) / [IntelliJ IDEA](https://www.jetbrains.com/idea/) (free).

## Installation

Ensure you have git cloned all 4 projects in the organisation down to your local machine. You need to have them all as siblings, e.g:

```
/path/to/your/code/folder/ps2alerts
-- api
-- stack
-- website
-- websocket
```

Run command `sudo ansible-playbook init.yml` and Ansible will ensure you have the correct commands etc.


### Houston, we are a go! :rocket:

Simply execute `ps2alerts-start` in your terminal to begin!

Once the stack has started, if this is for the first time, you'll need to import the database sample. To do this, execute `ps2alerts-dev-db`. 
