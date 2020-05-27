# Provisioning Compute Resources

Kubernetes requires a set of machines to host the Kubernetes control plane and the worker nodes where containers are ultimately run. In this lab you will provision the compute resources required for running a secure and highly available Kubernetes cluster.

## Networking

The Kubernetes [networking model](https://kubernetes.io/docs/concepts/cluster-administration/networking/#kubernetes-model) assumes a flat network in which containers and nodes can communicate with each other. In cases where this is not desired [network policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/) can limit how groups of containers are allowed to communicate with each other and external network endpoints.

Each machine uses two network interface, one for access the Internet with type "NAT", the other for Kubernetes internal communication with type "Host-only Adapter".

> A floating IP, managed by [Corosync and Pacemaker](https://clusterlabs.org/) will be used to expose the Kubernetes API Servers to remote clients.

Setup the floating IP:

```
TODO: commands for the cluster setup
```

> output

```

```
NOTE: Don't use this in production! Use a external loadbalancer or make sure you setup [fencing](https://clusterlabs.org/pacemaker/doc/deprecated/en-US/Pacemaker/1.1-plugin/html/Clusters_from_Scratch/ch09.html) correctly in your cluster.

## Compute Instances using vagrant

The compute instances in this lab will be provisioned using [Ubuntu Server](https://www.ubuntu.com/server) 18.04, which has good support for the [containerd container runtime](https://github.com/containerd/containerd). Each compute instance will be provisioned with a fixed private IP address to simplify the Kubernetes bootstrapping process.

The Vagrantfile contains the configuration of the lab setup. Below I will explain how the file is build and at the end we will create all the machines.

### Kubernetes Controllers

The following lines describe the compute instances which will host the Kubernetes control plane:

```ruby
  (0..2).each do |i|
    config.vm.define "controller-#{i}" do |node|
      node.vm.hostname = "controller-#{i}"
      node.vm.network "private_network", ip: "192.168.100.1#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "controller-#{i}"
        vb.cpus = 2
        vb.memory = 2048
      end
      node.vm.provision "shell", path: "cluster.sh"
    end
  end
```

### Kubernetes Workers

The following lines describe the three compute instances which will host the Kubernetes worker nodes:

```ruby
  (0..2).each do |i|
    config.vm.define "worker-#{i}" do |node|
      node.vm.hostname = "worker-#{i}"
      node.vm.network "private_network", ip: "192.168.100.2#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provider "virtualbox" do |vb|
        vb.name = "worker-#{i}"
      end
    end
  end
```

### Deploy the machines

Install the machines on your computer/lab:

```
vagrant up
```

To verify that all machines installed correctly:
```
vagrant status
```
> Output

```
Current machine states:

controller-0              running (virtualbox)
controller-1              running (virtualbox)
controller-2              running (virtualbox)
worker-0                  running (virtualbox)
worker-1                  running (virtualbox)
worker-2                  running (virtualbox)

This environment represents multiple VMs. The VMs are all listed
above with their current state. For more information about a specific
VM, run `vagrant status NAME`.
```

## Configuring floating IP
TODO: setup instruction cluster setup
```
sudo pcs cluster auth controller-0 controller-1 controller-2 -u hacluster -p just-for-learning --force
```
> output
```
controller-0: Authorized
controller-2: Authorized
controller-1: Authorized
```

```
sudo pcs cluster setup --name controller controller-0 controller-1 controller-2 -u hacluster -p just-for-learning --force
```
> Output
```
Destroying cluster on nodes: controller-0, controller-1, controller-2...
controller-0: Stopping Cluster (pacemaker)...
controller-2: Stopping Cluster (pacemaker)...
controller-1: Stopping Cluster (pacemaker)...
controller-2: Successfully destroyed cluster
controller-0: Successfully destroyed cluster
controller-1: Successfully destroyed cluster

Sending 'pacemaker_remote authkey' to 'controller-0', 'controller-1', 'controller-2'
controller-0: successful distribution of the file 'pacemaker_remote authkey'
controller-1: successful distribution of the file 'pacemaker_remote authkey'
controller-2: successful distribution of the file 'pacemaker_remote authkey'
Sending cluster config files to the nodes...
controller-0: Succeeded
controller-1: Succeeded
controller-2: Succeeded

Synchronizing pcsd certificates on nodes controller-0, controller-1, controller-2...
controller-0: Success
controller-2: Success
controller-1: Success
Restarting pcsd on the nodes in order to reload the certificates...
controller-0: Success
controller-1: Success
controller-2: Success
```

```
sudo pcs cluster enable --all
controller-0: Cluster Enabled
controller-1: Cluster Enabled
controller-2: Cluster Enabled
```
> Output
```
sudo pcs cluster start --all
controller-0: Starting Cluster...
controller-1: Starting Cluster...
controller-2: Starting Cluster...
```
> Output
```
sudo pcs property set stonith-enabled=false
sudo pcs resource create floating_ip ocf:heartbeat:IPaddr2 ip=192.168.100.100 cidr_netmask=24 op monitor interval=30s
```
Verify by pinging from the client or any of the six machines:
```
ping -c3 192.168.100.100
PING 192.168.100.100 (192.168.100.100): 56 data bytes
64 bytes from 192.168.100.100: icmp_seq=0 ttl=64 time=0.398 ms
64 bytes from 192.168.100.100: icmp_seq=1 ttl=64 time=0.520 ms
64 bytes from 192.168.100.100: icmp_seq=2 ttl=64 time=0.326 ms

--- 192.168.100.100 ping statistics ---
3 packets transmitted, 3 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.326/0.415/0.520/0.080 ms
```


Next: [Provisioning a CA and Generating TLS Certificates](04-certificate-authority.md)
