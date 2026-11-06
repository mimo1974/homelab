variable "name" {
  type        = string
  description = "VM and hostname."
}

variable "arch" {
  type        = string
  description = "Guest architecture: x86_64 or aarch64."
  validation {
    condition     = contains(["x86_64", "aarch64"], var.arch)
    error_message = "arch must be x86_64 or aarch64."
  }
}

variable "image_url" {
  type        = string
  description = "Ubuntu cloud image URL matching arch."
}

variable "vcpu" {
  type = number
}

variable "memory_mib" {
  type = number
}

variable "disk_gb" {
  type = number
}

variable "ip_address" {
  type = string
}

variable "prefix" {
  type    = number
  default = 24
}

variable "gateway" {
  type = string
}

variable "dns_servers" {
  type = list(string)
}

variable "mac_address" {
  type        = string
  description = "Fixed MAC, used to rename the NIC to eth0 inside the guest."
}

variable "bridge" {
  type        = string
  description = "Host bridge the VM attaches to (e.g. br0)."
  default     = "br0"
}

variable "ssh_public_key" {
  type = string
}

variable "user" {
  type    = string
  default = "ubuntu"
}

variable "pool_path" {
  type    = string
  default = "/var/lib/libvirt/images"
}
