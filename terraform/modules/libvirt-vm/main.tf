locals {
  machine = var.arch == "aarch64" ? "virt" : "q35"
}

resource "libvirt_pool" "this" {
  name = var.name
  type = "dir"
  target = {
    path = "${var.pool_path}/${var.name}"
  }
}

# Cloud image, downloaded once on the host side and used as backing store.
resource "libvirt_volume" "base" {
  name = "${var.name}-base.qcow2"
  pool = libvirt_pool.this.name
  create = {
    content = {
      url = var.image_url
    }
  }
}

resource "libvirt_volume" "disk" {
  name          = "${var.name}.qcow2"
  pool          = libvirt_pool.this.name
  capacity      = var.disk_gb
  capacity_unit = "GiB"
  target = {
    format = { type = "qcow2" }
  }
  backing_store = {
    path   = libvirt_volume.base.path
    format = { type = "qcow2" }
  }
}

resource "libvirt_cloudinit_disk" "this" {
  name = "${var.name}-cidata"
  user_data = templatefile("${path.module}/../../templates/user-data.yaml.tftpl", {
    hostname       = var.name
    user           = var.user
    ssh_public_key = var.ssh_public_key
  })
  meta_data = yamlencode({
    "instance-id"    = var.name
    "local-hostname" = var.name
  })
  network_config = templatefile("${path.module}/../../templates/network-config.yaml.tftpl", {
    mac         = var.mac_address
    address     = "${var.ip_address}/${var.prefix}"
    gateway     = var.gateway
    dns_servers = var.dns_servers
  })
}

resource "libvirt_volume" "cidata" {
  name = "${var.name}-cidata.iso"
  pool = libvirt_pool.this.name
  create = {
    content = {
      url = libvirt_cloudinit_disk.this.path
    }
  }
}

resource "libvirt_domain" "this" {
  name        = var.name
  type        = "kvm"
  memory      = var.memory_mib
  memory_unit = "MiB"
  vcpu        = var.vcpu
  autostart   = true
  running     = true

  os = {
    type         = "hvm"
    type_arch    = var.arch
    type_machine = local.machine
    firmware     = "efi"
  }

  features = {
    acpi = true
  }

  cpu = {
    mode = "host-passthrough"
  }

  devices = {
    disks = [
      {
        driver = { name = "qemu", type = "qcow2" }
        source = { volume = { pool = libvirt_pool.this.name, volume = libvirt_volume.disk.name } }
        target = { dev = "vda", bus = "virtio" }
        boot   = { order = 1 }
      },
      {
        # cloud-init NoCloud seed (label "cidata"), attached as a read-only virtio disk
        driver    = { name = "qemu", type = "raw" }
        source    = { volume = { pool = libvirt_pool.this.name, volume = libvirt_volume.cidata.name } }
        target    = { dev = "vdb", bus = "virtio" }
        read_only = true
      },
    ]
    # virtio-serial channel for qemu-guest-agent (reports IP, clean shutdown)
    channels = [
      {
        source = { unix = { mode = "bind" } }
        target = { virt_io = { name = "org.qemu.guest_agent.0" } }
      },
    ]
    interfaces = [
      {
        model  = { type = "virtio" }
        mac    = { address = var.mac_address }
        source = { bridge = { bridge = var.bridge } }
      },
    ]
  }
}
