terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

provider "libvirt" {
 uri = "qemu+ssh://robin@192.168.1.95/system?sshauth=privkey&no_verify=1"
}

resource "libvirt_volume" "volterra" {
 name   = "volterra-qcow2"
 pool   = "default"
 source = "/var/lib/libvirt/images/template/volterra.qcow2"
 format = "qcow2"
}

resource "libvirt_volume" "disk-image" {
  name           = "disk-image"
  base_volume_id = libvirt_volume.volterra.id
  pool           = "default"
  size           = 107374182400
}

resource "libvirt_domain" "volterra-domain" {
 name   = "volterra-domain"
 description = "F5 Distributed Cloud"
 memory = "16384"
 machine = "pc-q35-6.2"
 xml {
   xslt = file("machine.xsl")
 }
 vcpu = 4
 qemu_agent = true

 network_interface {
  macvtap = "enp109s0"
 }

 cpu {
  mode = "host-passthrough"
 }

 console {
   type        = "pty"
   target_port = "0"
   target_type = "serial"
 }

 console {
   type        = "pty"
   target_type = "virtio"
   target_port = "1"
 }

 disk {
   volume_id = libvirt_volume.disk-image.id
 }

 graphics {
   type        = "spice"
   listen_type = "address"
   autoport    = "true"
 }
}

