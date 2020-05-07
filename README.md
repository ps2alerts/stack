# ps2alerts-stack
Powers the central services required to run the following projects:
 
* ps2alerts-website 
* ps2alerts-api
* ps2alerts-ws

# Getting Started

The PS2Alerts project utilises Kubernetes for it's deployment and containerisation solution. It matches current infrastructure, and it solves a TON of headaches when it comes to getting code out to the world. Particularly SSL certificates. Fuck SSL certificate management.

You are **highly** recommended to use a Linux environment. I won't help you with issues to do between your environment and this one. It can be done in Windows, but it's a hassle. All the tools we use have a Windows version, thankfully, but it may need some modification to get it to work.

## Requirements

* [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [Virtual Box](https://www.virtualbox.org/wiki/Downloads) - Required for Minikube
* [Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube)
* Ansible - [Ubuntu / Debian](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu) - [Windows (good luck)](https://geekflare.com/ansible-installation-windows/) 
* [Docker](https://docs.docker.com/get-docker)
* A terminal program / PowerShell
* A good IDE. I recommend PHPStorm / IntelliJ IDEA