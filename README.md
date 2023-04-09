# ps2alerts-stack

![Ansible Linter](https://github.com/ps2alerts/stack/workflows/Ansible%20Linter/badge.svg) ![Yaml Linter](https://github.com/ps2alerts/stack/workflows/Yaml%20Lint/badge.svg) 

Powers the central services required to run the following projects:
 
* [PS2Alerts/api](https://github.com/PS2Alerts/api)
* [PS2Alerts/aggregator](https://github.com/PS2Alerts/aggregator)
* [PS2Alerts/website](https://github.com/PS2Alerts/website)

If you wish to contribute, please join our Discord located at: https://discord.gg/7xF65ap

# Getting Started

The PS2Alerts project utilises Kubernetes for its deployment and containerisation solution. It matches current infrastructure, and it solves a TON of headaches when it comes to getting code out to the world. Particularly SSL certificates. Fuck SSL certificate management. Locally however, for the sake of lowering local dev environment complexity and "things doing weird stuff" we're using Ansible to provision and maintain the local development environment. It will install not only the services required to run the application, but also a set of standardized commands shared across all developers.

**Linux Debian** and **Mac OSX Catalina** are the only supported operating systems for development. It can be done in Windows, but it's a hassle. If you feel the need to develop on Windows, [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install) will be much easier to set up. Mac OSX does work with `homebrew` filling some gaps. **Windows is not officially supported.**

# WSL setup guide

<details>
<summary> If you use windows </summary>

1. Install using [Powershell](https://apps.microsoft.com/store/detail/powershell/9MZ1SNWT0N5D?hl=en-gb&gl=GB) with admin rights enter:  `wsl --install`
2. Restart and ubuntu will be available as an app or in the [windows terminal](https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701?hl=en-gb&gl=GB)
3. When you first start ubuntu you will have to choose your username and password(this is your sudo password)
4. To check WSL version type `wsl -l -v` in **powershell**
5. For [Docker](https://docs.docker.com/desktop/install/windows-install/) you can install windows version and then have that be integrated with WSL by ticking this checkbox and applying wsl intergration in settings
![WSL image](/WSLimage.png)
Install ansible as given from the requirements and mongodb compass if you are working with data.
6. Then add these to your [hosts file ](c:\Windows\System32\Drivers\etc\hosts) to get to your markdown paste this `c:\Windows\System32\Drivers\etc\hosts` into explorer
```
127.0.0.1 dev.api.ps2alerts.com
127.0.0.1 dev.router.ps2alerts.com
127.0.0.1 dev.ps2alerts.com
127.0.0.1 dev.aggregator.ps2alerts.com
127.0.0.1 dev.aggregator-ps4eu.ps2alerts.com
127.0.0.1 dev.aggregator-ps4us.ps2alerts.com
```
7. To ensure that the project will run properly
[NVM install here](https://tecadmin.net/how-to-install-nvm-on-ubuntu-20-04/) then type `nvm install --lts` for a long term support version of node.js
Use this to get yarn via `npm install --global yarn`
Then `yarn install` in all of the repos that you cloned to ensure that you have the files necessary.
Then in the stack you can run `ps2alerts-init`
Followed by `ps2alerts-website-init` for the first time
And then `ps2alerts-website-dev` when you run this project again in the future
8. Checking the site is working
Go to `http://localhost:8080` to check that traefik is showing the services are running properly Then `dev.ps2alerts.com` and you will get a https warning but you can click on advanced on Firefox/edge and continue. Note due to not having ssl you won't have any data but you can see that the site itself is working.
9. To get https follow the [Generating SSL Certificates](#adding-certificates-for-local-dev-https-access) steps.
</details>

## Requirements

* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-ansible-on-ubuntu)
* [Docker](https://docs.docker.com/get-docker) (including [post install steps for Linux](https://docs.docker.com/engine/install/linux-postinstall/))
* A terminal program / PowerShell. For Linux I recommend [Terminator](https://gnometerminator.blogspot.com/p/introduction.html).
* A good IDE. I recommend [PHPStorm](https://www.jetbrains.com/phpstorm/) (paid) / [IntelliJ IDEA](https://www.jetbrains.com/idea/) (free).
* [MongoDB Compass](https://www.mongodb.com/products/compass) - if you're going to be interacting with data 

## Installation

Ensure you have git cloned all 4 projects in the organisation down to your local machine. You need to have them all as siblings, e.g:

```
/path/to/your/code/folder/ps2alerts
-- aggregator
-- api
-- stack
-- website
```

Run command `ansible-playbook init.yml -K` and provide your sudo password. Ansible will ensure you have the correct commands etc. 

### Houston, we are a go! :rocket:

Simply execute `ps2alerts-init` in your terminal to begin! This will go off to each project and install all it's dependencies for each project. Grab a snickers and once it's done, we're good to go.

Once the project has fully initialized, you can start the project from now on using `ps2alerts-start`!

We have designed the API project to initialize the database for you. See "How to get data collection going" section below.

## Adding certificates for local dev HTTPS access

If you want to access the dev environment over HTTPS (Say, because Chrome forces it and the main domain uses [HSTS](https://www.acunetix.com/blog/articles/what-is-hsts-why-use-it/)), you'll need to follow some additional steps:
<details>
    <summary>Click to expand certificate instructions</summary>

The following instructions are based on Mac (alternatives for Linux are listed). YMMV without Mac.

1. The certificates must be generated and placed in the `~/ps2alerts/certs` directory. To generate **local** self-signed certs, we're going to use `mkcert`. [Visit here for more context](https://www.andrewdixon.co.uk/2020/03/14/using-https-certificates-with-traefik-and-docker-for-a-development-environment/).
    - `cd ~/ps2alerts/certs`
    - `brew install mkcert nss` (nss is for Firefox, you can omit it if you don't use Firefox). [Further install methods](https://github.com/FiloSottile/mkcert)
    - `mkcert -install` (this will install the root certificate into your system, you will be prompted for your user password)
    - `mkcert -cert-file dev.ps2alerts.com.pem -key-file dev.ps2alerts.com-key.pem dev.ps2alerts.com dev.api.ps2alerts.com dev.aggregator.ps2alerts.com dev.aggregator-ps4eu.ps2alerts.com dev.aggregator-ps4us.ps2alerts.com`
2. Restart the stack with `ps2alerts-stack-restart` if you're already running it and start it again with `ps2alerts-stack-start` to apply the rest of the certificate changes.
</details>

# How to get data collection going

1) `ps2alerts-start`
2) `ps2alerts-aggregator-msg`
3) Choose an open continent etc
4) Open rabbit or run `ps2alerts-aggregator-msg` and see it doing things
5) Now you have data!

### Connecting to Mongodb

We are using MongoDB as our data document storage solution. In order to connect to Mongo for local development work, open up the Mongo Compass client and put the following in the connection string:

`mongodb://root:foobar@localhost:27017`

### RabbitMQ

The project utilises [RabbitMQ](https://www.rabbitmq.com/) ([MQs 101](https://www.youtube.com/watch?v=oUJbuFMyBDk)) for both storage of incoming data to be consumed by the API, and for administration of the aggregator. Once you have started the stack, you can access the dev environment version of RabbitMQ by going to the following URL: 

http://localhost:15672/#/

Using credentials: `guest` | `guest`

There, you can see the channels and queues created by us, and is provisioned via the Ansible script. We are currently creating an exchange (for future purposes) but are directly asserting and binding queues in our applications for now. On local dev, we don't use a vhost, on production we do as it's a shared service.

Below describes our queue topics:

* **aggregatorAdmin-<env>** - Administrative messages manually triggered by developers, e.g. `instance metagame start 10 8` to start a metagame instance on Miller, Esamir. To inject messages into your local environment, run `ps2alerts-aggregator-msg`.
* **api-queue-<env>** - Messages to be consumed by the API and persisted, one queue per environment
* **api-queue-delay-46min-<env>** - In order to figure out brackets, all GlobalAggregator messages must be delayed until the end of the alert, this is the 46 minute alert version.
* **api-queue-delay-91min-<env>** - Ditto - 91 minute version

#### Rabbit won't start

Chances are Rabbit is toppling due to a massive message backlog. To fix this, simply wipe the data partition for Rabbit's volume in Docker. On Mac, this is `rm -rf ~/ps2alerts/mq/*`, should be similar for linux. Restart Rabbit.
