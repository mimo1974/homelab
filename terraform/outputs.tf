output "vm_ips" {
  value = {
    evo = module.k3s_evo.ip_address
    i7  = module.k3s_i7.ip_address
    pi  = module.k3s_pi.ip_address
  }
}

# Use: terraform output -raw ansible_inventory > ../ansible/inventory/my-cluster/hosts.ini
output "ansible_inventory" {
  value = templatefile("${path.module}/templates/hosts.ini.tftpl", {
    servers = {
      "k3s-evo" = module.k3s_evo.ip_address
      "k3s-i7"  = module.k3s_i7.ip_address
      "k3s-pi"  = module.k3s_pi.ip_address
    }
  })
}
