locals {
  # Locally administered MACs, derived from the last IP octet so they stay stable.
  mac = {
    for k, ip in var.vm_ips :
    k => format("52:54:00:6b:33:%02x", tonumber(element(split(".", ip), 3)))
  }
}

module "k3s_evo" {
  source    = "./modules/libvirt-vm"
  providers = { libvirt = libvirt.evo }

  name           = "k3s-evo"
  arch           = "x86_64"
  image_url      = var.ubuntu_image_amd64
  vcpu           = var.vm_specs.evo.vcpu
  memory_mib     = var.vm_specs.evo.memory_mib
  disk_gb        = var.vm_specs.evo.disk_gb
  ip_address     = var.vm_ips.evo
  prefix         = var.prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
  mac_address    = local.mac.evo
  bridge         = var.bridge_libvirt
  ssh_public_key = var.ssh_public_key
  user           = var.vm_user
}

module "k3s_pi" {
  source    = "./modules/libvirt-vm"
  providers = { libvirt = libvirt.pi }

  name           = "k3s-pi"
  arch           = "aarch64"
  image_url      = var.ubuntu_image_arm64
  vcpu           = var.vm_specs.pi.vcpu
  memory_mib     = var.vm_specs.pi.memory_mib
  disk_gb        = var.vm_specs.pi.disk_gb
  ip_address     = var.vm_ips.pi
  prefix         = var.prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
  mac_address    = local.mac.pi
  bridge         = var.bridge_libvirt
  ssh_public_key = var.ssh_public_key
  user           = var.vm_user
}

module "k3s_i7" {
  source = "./modules/proxmox-vm"

  name           = "k3s-i7"
  node_name      = var.proxmox_node_name
  image_url      = var.ubuntu_image_amd64
  vcpu           = var.vm_specs.i7.vcpu
  memory_mib     = var.vm_specs.i7.memory_mib
  disk_gb        = var.vm_specs.i7.disk_gb
  ip_address     = var.vm_ips.i7
  prefix         = var.prefix
  gateway        = var.gateway
  dns_servers    = var.dns_servers
  bridge         = var.bridge_proxmox
  disk_datastore = var.proxmox_disk_datastore
  file_datastore = var.proxmox_file_datastore
  ssh_public_key = var.ssh_public_key
  user           = var.vm_user
}
