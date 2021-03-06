# ps2alerts-stack

![Ansible Linter](https://github.com/ps2alerts/stack/workflows/Ansible%20Linter/badge.svg) ![Yaml Linter](https://github.com/ps2alerts/stack/workflows/Yaml%20Lint/badge.svg) 

Powers the central services required to run the following projects:
 
* [PS2Alerts/api](https://github.com/PS2Alerts/api)
* [PS2Alerts/aggregator](https://github.com/PS2Alerts/aggregator)
* [PS2Alerts/website](https://github.com/PS2Alerts/website)

If you wish to contribute, please join our Discord located at: https://discord.gg/7xF65ap

# Getting Started

The PS2Alerts project utilises Kubernetes for its deployment and containerisation solution. It matches current infrastructure, and it solves a TON of headaches when it comes to getting code out to the world. Particularly SSL certificates. Fuck SSL certificate management. Locally however, for the sake of lowering local dev environment complexity and "things doing weird stuff" we're using Ansible to provision and maintain the local development environment. It will install not only the services required to run the application, but also a set of standardized commands shared across all developers.

**Linux Debian** and **Mac OSX Catalina** are the only supported operating systems for development. It can be done in Windows, but it's a hassle. Mac OSX does work with `homebrew` filling some gaps. **Windows is not officially supported.**

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

Simply execute `ps2alerts-start` in your terminal to begin!

We have designed the aggregator project (potentially moved to API) to initialize the database for you, it also triggers an "instance" of your choosing via code so you're able to immediately start tracking data.

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

Using credentials: `user` | `bitnami`

There, you can see the channels and queues created by us, and is provisioned via the Ansible script. We are currently creating an exchange (for future purposes) but are directly asserting and binding queues in our applications for now. On local dev, we don't use a vhost, on production we do as it's a shared service.

Below describes our queue topics:

* **aggregatorAdmin-<env>** - Administrative messages manually triggered by developers, e.g. `instance metagame start 10 8` to start a metagame instance on Miller, Esamir. To inject messages into your local environment, run `ps2alerts-aggregator-msg`.
* **api-queue-<env>** - Messages to be consumed by the API and persisted, one queue per environment
* **api-queue-delay-46min-<env>** - In order to figure out brackets, all GlobalAggregator messages must be delayed until the end of the alert, this is the 46 minute alert version.
* **api-queue-delay-91min-<env>** - Ditto - 91 minute version

#### Rabbit won't start

Chances are Rabbit is toppling due to a massive message backlog. To fix this, simply wipe the data partition for Rabbit's volume in Docker. On Mac, this is `rm -rf ~/ps2alerts/mq/*`, should be similar for linux.
