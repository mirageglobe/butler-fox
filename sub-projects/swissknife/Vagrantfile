# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"

  # Sync the current directory to /home/vagrant/swissknife
  config.vm.synced_folder ".", "/home/vagrant/swissknife"

  config.vm.provider "virtualbox" do |vb|
    vb.memory = "1024"
    vb.cpus = 1
  end

  # Provisioning: Install Make and run swissknife setup
  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get install -y make
    
    # Run setup as the vagrant user (not root)
    sudo -u vagrant bash -c "cd /home/vagrant/swissknife && make ensure-swissknife"
    
    echo "=================================================="
    echo "Swissknife test environment ready!"
    echo "SSH in with: vagrant ssh"
    echo "Tools are in: ~/.swissknife/bin"
    echo "=================================================="
  SHELL
end
