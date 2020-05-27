# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/bionic64"
  config.vm.box_check_update = false
  config.vm.provider "virtualbox" do |vb|
    vb.cpus = 1
    vb.memory = 512
  end

  (0..2).each do |i|
    config.vm.define "controller-#{i}" do |node|
      node.vm.hostname = "controller-#{i}"
      node.vm.network "private_network", ip: "192.168.100.1#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provision :hosts, :add_localhost_hostnames => false
      node.vm.provider "virtualbox" do |vb|
        vb.name = "controller-#{i}"
        vb.cpus = 2
        vb.memory = 2048
      end
      node.vm.provision "shell", path: "cluster.sh"
    end
  end

  (0..2).each do |i|
    config.vm.define "worker-#{i}" do |node|
      node.vm.hostname = "worker-#{i}"
      node.vm.network "private_network", ip: "192.168.100.2#{i}"
      node.vm.provision :hosts, :sync_hosts => true
      node.vm.provision :hosts, :add_localhost_hostnames => false
      node.vm.provider "virtualbox" do |vb|
        vb.name = "worker-#{i}"
      end
    end
  end
end
