# Host prerequisites (one-time, before `terraform apply`)

Terraform runs on the Mac and reaches all three hosts over the network. Every VM
must sit on a **bridge on the LAN** (not libvirt NAT), so kube-vip's ARP VIP and
node-to-node traffic work. Do the bridge steps from the GL.iNet Comet console,
because the IP moves from the NIC to the bridge and the SSH session can drop.

## EVO T1 (CachyOS, 192.168.1.250)

Verified on 2026-11-05: SSH key login as `mimo` works, user shell is fish,
libvirt is not installed, no `br0`, LAN NIC is `enp44s0`, `mimo` is not in the
`libvirt` group.

```sh
sudo pacman -Syu                                   # full update first, never a lone -Sy
sudo pacman -S --needed libvirt qemu-base edk2-ovmf
sudo systemctl enable --now libvirtd.socket
sudo usermod -aG libvirt mimo        # log out/in afterwards
```

Bridge (NetworkManager; verified 2026-11-06: the Ethernet profile is `LAN`,
gateway 192.168.1.248, DNS 1.1.1.1; a `br0` profile with the same IP already
exists, but `enp44s0` is not attached to it yet, so only the last two commands
are still needed):

```sh
sudo nmcli con add type bridge ifname br0 con-name br0 stp no \
  ipv4.method manual ipv4.addresses 192.168.1.250/24 \
  ipv4.gateway 192.168.1.248 ipv4.dns 1.1.1.1
sudo nmcli con add type bridge-slave ifname enp44s0 master br0
sudo nmcli con down "LAN"; sudo nmcli con up br0
```

Check: `virsh -c qemu:///system list --all` and `ip -br addr show br0`.

## Pi 5 (Ubuntu Server 64-bit, IP not set yet)

```sh
sudo apt install -y libvirt-daemon-system qemu-system-arm qemu-utils qemu-efi-aarch64
sudo usermod -aG libvirt mimo
```

Bridge via netplan (`/etc/netplan/60-br0.yaml`, then `sudo netplan try`):

```yaml
network:
  version: 2
  ethernets:
    eth0: {}
  bridges:
    br0:
      interfaces: [eth0]
      addresses: [192.168.1.PI/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.1]
```

Ubuntu confines each VM with AppArmor, and the per-VM profile does not list the
qcow2 *backing file* (the base cloud image), so QEMU fails with
`Could not open '.../k3s-pi-base.qcow2': Permission denied`
(seen on Ubuntu 26.04.1, libvirt 12.0.0; the kernel audit log may hide the
denial because of rate limiting: `sysctl -w kernel.printk_ratelimit=0`).
Fix, once, as root:

```sh
mkdir -p /etc/apparmor.d/abstractions/libvirt-qemu.d
echo '/var/lib/libvirt/images/k3s-*/** rk,' > /etc/apparmor.d/abstractions/libvirt-qemu.d/k3s-images
```

Remove or disable any other netplan file that configures `eth0` with DHCP.
Confirm KVM is available: `ls /dev/kvm`.

## i7 (Proxmox VE 9, 192.168.1.245)

```sh
# API token for Terraform (privsep 0 = token inherits the user's rights)
pveum user add terraform@pve
pveum aclmod / -user terraform@pve -role Administrator
pveum user token add terraform@pve tf --privsep 0     # prints the secret once

# the bpg provider needs these content types on the file datastore
pvesm set local --content iso,vztmpl,backup,snippets,import
```

Also copy your Mac's SSH key to `root@192.168.1.245` (the provider reads `~/.ssh/id_rsa`
for snippet uploads; change `ssh_private_key_path` if yours differs) and check the node name in the UI (default variable: `pve`).

## From the Mac

```sh
cd terraform
cp terraform.tfvars.example terraform.tfvars   # fill in IPs, token, SSH key
terraform init && terraform plan
```

Note: all of this was validated with `terraform validate` only. No `plan` or
`apply` has been run against the hosts yet.
