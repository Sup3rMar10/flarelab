# Win10 eval ISO -> VirtualBox -> FLARE-VM -> Vagrant box. Lab/concept only.
packer {
  required_plugins {
    virtualbox = { version = ">= 1.0.5", source = "github.com/hashicorp/virtualbox" }
    vagrant    = { version = ">= 1.1.0", source = "github.com/hashicorp/vagrant" }
  }
}

variable "iso_url" { default = "iso/win10_eval.iso" } # download Win10 Enterprise eval manually
variable "iso_checksum" { default = "none" }          # set sha256:... for real use

source "virtualbox-iso" "flare" {
  vm_name              = "flare-build"
  guest_os_type        = "Windows10_64"
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  cpus                 = 4
  memory               = 8192
  disk_size            = 122880
  headless             = true
  guest_additions_mode = "disable" # no shared folders / clipboard integration
  floppy_files         = ["answer/Autounattend.xml", "answer/winrm.ps1"]
  boot_wait            = "2s"
  boot_command         = ["<enter><wait2><enter><wait2><enter>"] # "press any key" prompt
  communicator         = "winrm"
  winrm_username       = "vagrant"
  winrm_password       = "vagrant"
  winrm_timeout        = "3h"
  shutdown_command     = "shutdown /s /t 5 /f /d p:4:1"
  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--clipboard-mode", "disabled"],
    ["modifyvm", "{{.Name}}", "--draganddrop", "disabled"],
  ]
}

build {
  sources = ["source.virtualbox-iso.flare"]

  provisioner "powershell" { script = "scripts/harden.ps1" }
  provisioner "windows-restart" {}
  provisioner "file" {
    source      = "config.xml"
    destination = "C:/Windows/Temp/config.xml"
  }
  provisioner "powershell" {
    script            = "scripts/flare-install.ps1" # needs internet at build time only
    elevated_user     = "vagrant"
    elevated_password = "vagrant"
    valid_exit_codes  = [0, 3010]
  }
  provisioner "windows-restart" {}

  post-processor "vagrant" {
    output = "builds/flarevictim.box"
  }
}
