% Light Application Platform - Infrastructure

# Introduction
The proposed infrastructure is based on [CoreOS](http://www.coreos.com) virtual machines (nodes) running
ubuntu based docker containers.

The development infrastructure runs on local hosts in the office, while the production runs on 
hosts placed in a data center or on hosted VMs.

We presume that a relatively static number of hosts is used. Therefore provisioning the hosts is
not automated. However, little modifications besides installing a few additional packages have to be
made to the hosts. All they do is running VMs.

Setting up VMs is triggered by hand, but automated using vagrant. 

Every deployment of the infrastructure utilizes a separate node. For testing and development 
purposes, it is possible to deploy multiple instances of the insfrastructure at the same time.
Using the non-productive deployments are isolated from the environment using the envronment 
configuration. 

# Deployment Overview
We assume you are working with a LAN behind a NAT router. A switch is attached to the router, to
which the hosts and the work stations are connected. For optimal speed, using gigabit ethernet
is suggested. The hosts run virtual machines, called nodes.

![](images/infra_deployment_overview.png)

To simplify the setup, we use a small number of fixed IPs together with self hosted dynamic DNS.

# Fixed IPs
The following table shows the fixed IPs:
  
192.168.0.1
  ~ NAT router
192.168.0.10
  ~ static IPs for hosts and infrastructure master nodes
192.168.0.30 ... 192.168.0.250
  ~ DHCP IP range

This setup gives us room for 220 dynamic IPs, which should be sufficient for a long time.

The hosts use fixed IPs to make them reachable even if DNS should go down. The nodes hosting the
infrastructure needs a fixed IP as well, since the DHCP server has to provide it's IP as DNS server. 

## DNS Scheme
We use the `.internal` top level domain for our DNS names. 

The following names are independent of an infrastructure deployment:

`xxx.host.internal`
  ~ denotes a host
`xxx.node.internal`
  ~ denotes a node
`<first name>-<last name>[-<specifier>].pc.internal`
  ~ denotes the work station of a user, with an optional specifier like `notebook`
 
 The following names are used for the productive infrastructure deployment 
 
`git.internal`
  ~ git server
`trac.internal:80`
  ~ Trac (issue management) server
`cd.internal:80`
  ~ continous deployment server
`ubuntu.cache.internal:3124`
  ~ apt package cache for ubuntu
`docker.internal:5000`
  ~ internal docker registry
`maven.internal`
  ~ maven repository
`artifact.internal`
  ~ artifact repositorys	
`backup.internal`
  ~ node storing backups
 
# Configuration

## Container Configuration
Containers are configured in their own git repository. Each container has it's own sub directory.
When working on the container configuration, a separate branch should be used. The `master` branch
is reserved for the currently productive version.

## Node (VM) Configuration
There are two kinds of nodes: master nodes and worker nodes. The master nodes have a 
fixed IP and are used to run an infrastructure deployment. The worker nodes have a dynamic
IP can be used to run any container.

The nodes are provisioned using vagrant. The configuration contains the configuration for all
hosts. The nodes are started manually using `vagrant up`. In additional, they are started after
a boot (for power loss).

The node configuration is stored in a separate git repository. Some parameters can be adjusted
for each node in a configuration file. If the script itself has to be modified, the use of
a separate branch is advised.

## Environment Configuration
The environment configuration is used to separate the productive infrastructure deployment from 
the test deployments. It is made available to all infrastructure containers using volume import.

The configuration is managed in a separate git repository. There is a sub directory per
environment.

# The Master Nodes
The master nodes have a `/data` directory which contains, in it's sub directories, the data of all
applications. The convention is that the respective data-sub directory is mapped to `/data` in
the container.

To start the infrastructure, the `start.sh` script is used. It first runs the `stop.sh` script. Then it runs the `startNoStop.sh` script 
which checks out the `master` branch of the `infra-docker` repository, reading directly from the `/data` directory and then runs 
the checked out `startImpl.sh` script.

The `stop.sh` script stops and removes all running infrastructure containers. Since the naming convention for infrastructure containers
is `infra_<name>`, this means just to stop all containers with an `infra_` prefix. 

The `startNoStop.sh` script does the following:
1. start the registry container
1. pull the new containers from the registry
1. start the new containers

The `start.sh` script only depends on the registry container beeing available. It can be used to start the infrastructure
after a restore as well as for deploying an infrastructure update.

## Restoring a Backup Snapshot
A snapshot restore is directed by the `restore.sh` script. 
First the `stop.sh` script is executed, which stops and removes the infrastructure containers. Then the snapshot is restored,
followed by `startNoStop.sh`

## Desaster Recovery
After a desaster, only a backup host remains available. The follwoing steps bring the infrastructure up again:

1. setup a fresh host
1. clone the `infra-node` git repository from the backup
1. start a master node
1. restore `/data`
1. run `start.sh`

## Development Process
Infrastructure development happens an a test node. Once the updated infrastructure passes the tests, it is deployed
to the production node.
 
![](images/infra_development_process.png)

To simplify the management of container images the following naming convention is used when pushing them to a registry:
 `infra/<commit hash>/<container name>`. However during a build and in the `Dockerfile`s the naming convention is 
 `infra/<container name>`

A new or existing test node is prepared for testing by 
1. fetch snapshot from production
1. restore snapshot

To test changes of the infrastructure, push them to the git repository of the test node and
run the `buildAndStart.sh` script. It will build the containers based on the current commit
of the master branch and then run `start.sh`. If something fails, just restore the last snaphshot
and start over.
  
If tests are successful, run `deployToProduction.sh`:

1. stop test registry
1. take prod snapshot
1. ssh prod -L5000:localhost:5000  
1. push images to prod registry
1. push git to prod
1. prod: `start.sh`

If a failure occurs, restore the last production snapshot

![](images/infra_scripts.png)

# The Worker Nodes
Worker nodes are connected to an infrastructure deployment by specifying the master node as initial `etcd` peer.
TODO: how?
NOTE:

    peers: "172.17.8.101:7001,172.17.8.102:7001"

# Initial Setup
To perform an initial setup, you need a seed machine. If you use your workstation as host, or perform the installation
directly on a host, the seed machine and your host are the same machine. Thus some copying steps can be skipped. However,
when using a seed machine gives the advantage that you can cache some downloads.

On the seed machine, `git` and `docker` are required.

## Host Setup
First, a host is needed to host our nodes. We will call it `office`. Install ubuntu server. 
Configure a fixed IP (192.168.0.10).
TODO: how to configure ubuntu server.

Then execute the install script. TODO: script!

Alternatively you can get started using your own workstation. Install Virtualbox and vagrant.

## Master Node Setup
On the host, do 
 
   git clone git://github.com/ruediste1/lap-infra.git

This clones the whole infrastructure configuration git repository. The file `vagrant/config.rb` 
contains all node configurations. When starting VMs, the hostname is read and used
to switch between node configurations.

First, we need to create an SSH key used to connect to the VM. Either use an existing or generate a
new one. Note that you will have to copy the private key to every host you are planning to use
the key. We call this key the `admin` key.

    ssh-keygen -f admin_rsa -P ""

Then we have to configure our master node. Open `vagrant/config.rb` and fix it's IP. Start the node
    
    vagrant up
    
By default, the repository is configured to start a single node only. If
you increase the number of nodes, additional nodes will use DHCP to retrieve their IP unless you
assign them an IP explicitly.

## Setup Containers
Now that your master node is running, log in using

    vagrant ssh

Create clone the `lap-infra` directory to `/data/lap-infra`.

    sudo mkdir -p /data/lap-infra
    sudo chown core:core /data/lap-infra
    cd /data/lap-infra
    git clone git://github.com/ruediste1/lap-infra.git .

Now you can build the containers
    
    cd /data/lap-infra/docker
    ./build.sh

Before starting the containers, the registry needs to be made available

    docker pull registry
    docker tag registry localhost:5000/registry
    
Now you are ready to start your infrstructure

    ./start.sh

**Hint:** For debugging or development of the getting started stuff, you can seed
the node with the registry container from the host. Run 

    docker pull registry
    docker tag registry localhost:5000/infra_registry
    docker pull ubuntu:14.04
    
once on the host to make the registry and ubuntu containers available. Then you can copy the containers
to the node by executing
 
    sudo docker save localhost:5000/infra_registry | vagrant ssh -- docker load
    sudo docker save ubuntu:14.04 | vagrant ssh -- docker load

in the vagrant directory.

This starts the complete infrastructure. Create the infrastructure git
repositories and you are done.

# OLD
On your seed machine, go to your git directory and do

    git clone git@github.com:ruediste1/infra-docker.git
    git clone git@github.com:ruediste1/infra-env.git
	cd infra-docker
	docker build -t dns dns/
	docker build -t environment environment/

Now go to the coreos-vagrant repository again and run (as root)

    docker save dns | ssh -i private_rsa core@192.168.0.11 docker load
    docker save environment | ssh -i private_rsa core@192.168.0.11 docker load
    
    docker tag registry:0.7.3 localhost:5000/registry
    sudo docker save localhost:5000/registry | ssh -i private_rsa core@192.168.0.10 docker load

## Environment Container 
  docker run --name env environment
  
## DNS Setup
Now that we are ready to get the DNS server running.

  docker run --volumes-from env -p 192.168.0.11:53:53/udp -p 192.168.0.11:53:53 -i -t --name dns dns
  
Add ddns to host.

configure dns to use 192.168.0.11

## Git Setup

## Backup Setup

# Containers

## Registry Container
We run a private docker container registry for reproducability and small desaster recovery times.
The registry container is an unmodified stock container. It's image is stored directly
under `/data` and can be loaded into docker with
 
    docker load -i /data/registry.container
       
and then started with

    docker run --name registry -p 5000:5000 -v /data/registry:/data -e SETTINGS_FLAVOR=local -e STORAGE_PATH=/data localhost:5000/registry
    
## DNS Container
The DNS container provides a DNS server, capable of dynamic DNS.

    docker run -p 192.168.0.10:53:53/udp -p 192.168.0.10:53:53 -i -t --name dns localhost:5000/dns
    
    dnssec-keygen -a HMAC-SHA256 -b 256 -n USER dnskey
    
## GIT Container
(Gitolite)[http://gitolite.com] is used as git server. It is a very small and simple
server, yet surprisingly easy to use and provides good access control.

 
# Setting up NGiNX
We use NGiNX as load balancer. The standard distribution does not come with a cookie based session
sticky module, but http://code.google.com/p/nginx-sticky-module can be used for that purpose.
 
Installing is accomplished by

    sudo apt-get install nginx

configure a sample cluster via

     sudo cp sample.nginx.conf /etc/nginx/conf.d/
     sudo service nginx restart
 