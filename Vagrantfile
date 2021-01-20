# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  # This includes Homebrew and xcode command line tools.
  config.vm.box = "yzgyyang/macOS-10.14"

  # No need to mount the default synced folder as Vagrant is not able to mount
  # VirtualBox shared folders on BSD-based guests. BDS-based guests do not
  # support the VirtualBox filesystem at this time.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration:
  config.vm.provider "virtualbox" do |vb|

    # Display the VirtualBox GUI when booting the machine
    vb.gui = true

    vb.name = "dotfiles-testing"

    # Customize the amount of memory on the VM:
    vb.memory = "2048"

    # Customize the number of cpus on the VM:
    vb.cpus = 2
  end
end
