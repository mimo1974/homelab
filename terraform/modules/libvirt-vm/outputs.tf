output "name" {
  value = libvirt_domain.this.name
}

output "ip_address" {
  value = var.ip_address
}
