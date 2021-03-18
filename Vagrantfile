Vagrant.configure("2") do |config|
  config.vm.box = "hashicorp/bionic64"
  config.vm.synced_folder ".", "/vagrant", disabled: true
  config.vm.provider "virtualbox" do |vb|
    # vb.gui = true
    vb.name = "dotfiles"
    vb.memory = "2048"
    vb.cpus = 2
  end
end
