# EVO T1 (CachyOS, KVM/libvirt) and Pi 5 (Ubuntu, KVM/libvirt): libvirt over SSH.
provider "libvirt" {
  alias = "evo"
  uri   = "qemu+ssh://${var.libvirt_ssh_user}@${var.evo_host}/system"
}

provider "libvirt" {
  alias = "pi"
  uri   = "qemu+ssh://${var.libvirt_ssh_user}@${var.pi_host}/system"
}

# i7 (Proxmox VE 9): API token. SSH is needed by the provider for snippet/import uploads.
provider "proxmox" {
  endpoint  = "https://${var.i7_host}:8006/"
  api_token = var.proxmox_api_token
  insecure  = true # self-signed cert

  ssh {
    username    = "root"
    private_key = file(pathexpand(var.ssh_private_key_path))
  }
}
