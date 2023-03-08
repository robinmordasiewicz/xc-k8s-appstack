terraform {
  required_providers {
    libvirt = {
      source     = "dmacvicar/libvirt"
      version    = "0.7.1"
    }
  }
}

variable "hostnames" {
  description    = "Create these hosts"
  type           = list(string)
  default        = ["mains01", "mains02", "mains03"]
  #default        = ["mains01"]
  #default        = ["host01"]
}

provider "libvirt" {
  uri            = "qemu+ssh://robin@192.168.1.95/system?sshauth=privkey&no_verify=1"
}

resource "libvirt_volume" "volterra" {
  name           = "volterra-qcow2"
  pool           = "default"
  #source         = "/var/lib/libvirt/images/templates/xc-template.qcow2"
  source         = "/var/lib/libvirt/images/templates/vsb-ves-ce-certifiedhw-generic-production-centos-7.2009.27-202211040823.1667791030/vsb-ves-ce-certifiedhw-generic-production-centos-7.2009.27-202211040823.1667791030.qcow2"
  format         = "qcow2"
}

resource "libvirt_volume" "diskimage" {
  count          = length(var.hostnames)
  name           = var.hostnames[count.index]
  pool           = "default"
  size           = 107374182400
  base_volume_id = libvirt_volume.volterra.id
  format         = "qcow2"
}

resource "libvirt_cloudinit_disk" "cloudinit" {
  name           = "xc-cloudinit.iso"
  user_data      = templatefile("${path.module}/http/cloudinit.yml", {})
  pool           = "default"
}

resource "libvirt_domain" "volterradomain" {
  count          = length(var.hostnames)
  name           = var.hostnames[count.index]
  description    = "F5 Distributed Cloud"
  memory         = "16384"
  machine        = "pc-q35-6.2"

  xml {
    xslt         = file("machine.xsl")
  }
  vcpu           = 4
  qemu_agent     = true

  network_interface {
    macvtap      = "enp109s0"
#    wait_for_lease = true
  }
 
#  cloudinit = libvirt_cloudinit_disk.cloudinit.id

  cpu {
    mode         = "host-passthrough"
  }

  console {
    type         = "pty"
    target_port  = "0"
    target_type  = "serial"
  }

  console {
    type         = "pty"
    target_type  = "virtio"
    target_port  = "1"
  }

  disk {
    volume_id    = element(libvirt_volume.diskimage[*].id, count.index)
     #volume_id    = var.hostnames[count.index].id
  }

  graphics {
    type         = "spice"
    listen_type  = "address"
    autoport     = "true"
  }
}

output "name" {
  value = libvirt_domain.volterradomain[*].name
}

#output "ip_address" {
#  value = libvirt_domain.volterradomain[*].network_interface[0].addresses[0]
#}
