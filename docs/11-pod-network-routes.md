# Provisioning Pod Network Routes

Pods scheduled to a node receive an IP address from the node's Pod CIDR range. At this point pods can not communicate with other pods running on different nodes due to missing network routes.

In this lab you will create a route for each worker node that maps the node's Pod CIDR range to the node's internal IP address.

> There are [other ways](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-achieve-this) to implement the Kubernetes networking model.

## Prerequisites

The commands in this lab must be run on each controller instance: `worker-0`, `worker-1`, and `worker-2`. Login to each controller instance using the `vagrant ssh` command. Example:

```
vagrant ssh worker-0
```

### Running commands in parallel with tmux

[tmux](https://github.com/tmux/tmux/wiki) can be used to run commands on multiple compute instances at the same time. See the [Running commands in parallel with tmux](01-prerequisites.md#running-commands-in-parallel-with-tmux) section in the Prerequisites lab.

## The Routing Table

In this section you will gather the information required to create routes in the worker nodes.


## Routes
Retrieve the current POD cidr and internal ip:
```
POD_CIDR="10.200.$(uname -n | awk -F- '{print $2}').0/24"
INTERNAL_IP=$(ip -4 --oneline addr | grep -v secondary | grep -oP '(192\.168\.100\.[0-9]{1,3})(?=/)')
```
Create network routes for each worker instance:

```
{
cp /etc/netplan/50-vagrant.yaml .
cat >> 50-vagrant.yaml <<EOF
      routes:
EOF
for i in 0 1 2; do
cat >> 50-vagrant.yaml <<EOF
      - to: 10.200.${i}.0/24
        via: 192.168.100.2${i}
EOF
done
sed -i "/to: ${POD_CIDR}/d" 50-vagrant.yaml
sed -i "/via: ${INTERNAL_IP}/d" 50-vagrant.yaml
sudo cp 50-vagrant.yaml /etc/netplan/
sudo netplan apply
}
```

List the routes on all worker nodes:

```
route
```

> output

```
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         _gateway        0.0.0.0         UG    100    0        0 enp0s3
10.0.2.0        0.0.0.0         255.255.255.0   U     0      0        0 enp0s3
_gateway        0.0.0.0         255.255.255.255 UH    100    0        0 enp0s3
10.200.1.0      worker-1        255.255.255.0   UG    0      0        0 enp0s8
10.200.2.0      worker-2        255.255.255.0   UG    0      0        0 enp0s8
192.168.100.0   0.0.0.0         255.255.255.0   U     0      0        0 enp0s8
```

Next: [Deploying the DNS Cluster Add-on](12-dns-addon.md)
