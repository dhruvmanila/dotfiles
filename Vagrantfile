# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

  config.vm.define "macos" do |macos|

    # This includes Homebrew and xcode command line tools.
    macos.vm.box = "yzgyyang/macOS-10.14"

    # No need to mount the default synced folder as Vagrant is not able to mount
    # VirtualBox shared folders on BSD-based guests. BDS-based guests do not
    # support the VirtualBox filesystem at this time.
    macos.vm.synced_folder ".", "/vagrant", disabled: true

    macos.vm.provider "virtualbox" do |vb|
      # vb.gui = true
      vb.name = "dotfiles-testing"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end

  # Maybe use this to mess around in zsh?
  config.vm.define "cmacos" do |cmacos|

    # Clean macOS with no softwares pre-installed
    cmacos.vm.box = "ramsey/macos-catalina"

    # No need to mount the default synced folder as Vagrant is not able to mount
    # VirtualBox shared folders on BSD-based guests. BDS-based guests do not
    # support the VirtualBox filesystem at this time.
    cmacos.vm.synced_folder ".", "/vagrant", disabled: true

    cmacos.vm.provider "virtualbox" do |vb|
      # vb.gui = true
      vb.name = "clean-macos"
      vb.memory = "2048"
      vb.cpus = 2
    end
  end
end
