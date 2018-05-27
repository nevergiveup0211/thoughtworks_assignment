# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu1404"
  config.vm.network "forwarded_port", guest: 80, host: 80, host_ip: "127.0.0.1"
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install git -y
    git clone https://github.com/krishnaghatti/thoughtworks_assignment.git
  SHELL
end
