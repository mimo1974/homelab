# ---- hosts ----
variable "evo_host" {
  type    = string
  default = "192.168.1.250"
}

variable "i7_host" {
  type    = string
  default = "192.168.1.245"
}

variable "pi_host" {
  type    = string
  default = "192.168.1.244"
}

variable "libvirt_ssh_user" {
  type    = string
  default = "mimo"
}

variable "proxmox_api_token" {
  type        = string
  sensitive   = true
  description = "Format: user@realm!tokenid=secret"
}

variable "ssh_private_key_path" {
  type        = string
  default     = "~/.ssh/id_rsa"
  description = "Private key the Proxmox provider uses for SSH to root@i7 (snippet and image uploads)."
}

variable "proxmox_node_name" {
  type        = string
  default     = "pve01"
  description = "Node name shown in the Proxmox UI."
}

variable "proxmox_disk_datastore" {
  type    = string
  default = "local-lvm"
}

variable "proxmox_file_datastore" {
  type    = string
  default = "local"
}

# ---- network ----
variable "gateway" {
  type    = string
  default = "192.168.1.248"
}

variable "dns_servers" {
  type    = list(string)
  default = ["1.1.1.1"]
}

variable "prefix" {
  type    = number
  default = 24
}

variable "bridge_libvirt" {
  type    = string
  default = "br0"
}

variable "bridge_proxmox" {
  type    = string
  default = "vmbr0"
}

# ---- VMs ----
variable "vm_ips" {
  type = object({
    evo = string
    i7  = string
    pi  = string
  })
  description = "Static IPs of the three K3s server VMs (not decided yet)."
}

variable "vm_specs" {
  type = object({
    evo = object({ vcpu = number, memory_mib = number, disk_gb = number })
    i7  = object({ vcpu = number, memory_mib = number, disk_gb = number })
    pi  = object({ vcpu = number, memory_mib = number, disk_gb = number })
  })
  default = {
    evo = { vcpu = 4, memory_mib = 16384, disk_gb = 60 }
    i7  = { vcpu = 4, memory_mib = 16384, disk_gb = 60 }
    pi  = { vcpu = 3, memory_mib = 6144, disk_gb = 60 }
  }
}

variable "ssh_public_key" {
  type        = string
  description = "Public key installed for the VM user."
}

variable "vm_user" {
  type    = string
  default = "ubuntu"
}

variable "ubuntu_image_amd64" {
  type    = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "ubuntu_image_arm64" {
  type    = string
  default = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-arm64.img"
}
