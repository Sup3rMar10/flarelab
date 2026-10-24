# Isolated host-only lab: INetSim gateway + FLARE victim. No synced folders/clipboard/DnD.
Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.define "gw" do |gw|
    gw.vm.box = "ubuntu/jammy64"
    gw.vm.hostname = "gw"
    gw.vm.network "private_network", ip: "192.168.56.10"
    gw.vm.provider "virtualbox" do |v|
      v.name = "flare-gw"
      v.memory = 1024
      v.cpus = 1
      v.customize ["modifyvm", :id, "--clipboard-mode", "disabled", "--draganddrop", "disabled"]
    end
    gw.vm.provision "shell", path: "gateway/provision.sh"
  end

  config.vm.define "victim" do |w|
    w.vm.box = "flarevictim"
    w.vm.box_url = "packer/builds/flarevictim.box"
    w.vm.guest = :windows
    w.vm.communicator = "winrm"
    w.winrm.username = "vagrant"
    w.winrm.password = "vagrant"
    w.vm.boot_timeout = 900
    w.vm.network "private_network", ip: "192.168.56.20"
    w.vm.provider "virtualbox" do |v|
      v.name = "flare-victim"
      v.gui = false
      v.memory = 4096
      v.cpus = 2
      v.customize ["modifyvm", :id, "--clipboard-mode", "disabled", "--draganddrop", "disabled"]
      # empty DVD slot used by scripts/drop-sample.sh
      v.customize ["storageattach", :id, "--storagectl", "SATA Controller", "--port", 1,
                   "--device", 0, "--type", "dvddrive", "--medium", "emptydrive"]
    end
    # route + DNS via the fake gateway
    w.vm.provision "shell", privileged: true, inline: <<-PS
      $i = (Get-NetIPAddress -IPAddress 192.168.56.20).InterfaceIndex
      New-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex $i -NextHop 192.168.56.10 -ErrorAction SilentlyContinue
      Set-DnsClientServerAddress -InterfaceIndex $i -ServerAddresses 192.168.56.10
    PS
    # unplug the NAT NIC (vagrant's WinRM path) once provisioned -> host-only only
    w.trigger.after :up do |t|
      t.info = "Unplugging NAT adapter"
      t.run = { inline: "VBoxManage controlvm flare-victim setlinkstate1 off" }
    end
  end
end
