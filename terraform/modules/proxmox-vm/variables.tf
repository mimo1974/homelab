variable "name" {
  type = string
}

variable "node_name" {
  type        = string
  description = "Proxmox node name (as shown in the web UI)."
}

variable "image_url" {
  type        = string
  description = "Ubuntu cloud image URL (amd64)."
}

variable "image_file_name" {
  type        = string
  description = "Name on the datastore. Must end in .qcow2 for content type import."
  default     = "ubuntu-24.04-noble-amd64.qcow2"
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

variable "bridge" {
  type    = string
  default = "vmbr0"
}

variable "disk_datastore" {
  type        = string
  description = "Datastore for the VM disk and cloud-init drive."
  default     = "local-lvm"
}

variable "file_datastore" {
  type        = string
  description = "Datastore with content types 'import' and 'snippets' enabled."
  default     = "local"
}

variable "ssh_public_key" {
  type = string
}

variable "user" {
  type    = string
  default = "ubuntu"
}
