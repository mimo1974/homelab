resource "proxmox_download_file" "image" {
  node_name    = var.node_name
  datastore_id = var.file_datastore
  content_type = "import"
  file_name    = var.image_file_name
  url          = var.image_url
}

resource "proxmox_virtual_environment_file" "user_data" {
  node_name    = var.node_name
  datastore_id = var.file_datastore
  content_type = "snippets"

  source_raw {
    file_name = "${var.name}-user-data.yaml"
    data = templatefile("${path.module}/../../templates/user-data.yaml.tftpl", {
      hostname       = var.name
      user           = var.user
      ssh_public_key = var.ssh_public_key
    })
  }
}

resource "proxmox_virtual_environment_vm" "this" {
  name      = var.name
  node_name = var.node_name
  tags      = ["k3s", "terraform"]
  on_boot   = true

  agent {
    enabled = true
  }

  cpu {
    cores = var.vcpu
    type  = "host"
  }

  memory {
    dedicated = var.memory_mib
  }

  disk {
    datastore_id = var.disk_datastore
    import_from  = proxmox_download_file.image.id
    interface    = "virtio0"
    size         = var.disk_gb
    discard      = "on"
    iothread     = true
  }

  network_device {
    bridge = var.bridge
  }

  initialization {
    datastore_id = var.disk_datastore

    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.prefix}"
        gateway = var.gateway
      }
    }

    dns {
      servers = var.dns_servers
    }

    user_data_file_id = proxmox_virtual_environment_file.user_data.id
  }

  operating_system {
    type = "l26"
  }

  serial_device {}
}
