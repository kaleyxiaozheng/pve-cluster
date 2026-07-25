# k3s_nodes.tf

module "master_node" {
  source                 = "git@github.com:kaleyxiaozheng/k3s-node-module.git?ref=v1.0.0"
  node_name              = "k3s-master-node"
  node_type              = "master"
  vm_id                  = 101
  memory                 = 4096
  static_ip              = "192.168.50.101/24"
  gateway                = "192.168.50.1"
  ssh_public_key_content = file(var.ssh_public_key_path) # fetch the content of the SSH public key file and pass it to the module
  vm_password            = var.vm_password # pass the VM password variable to the module for cloud-init use  
  tailscale_auth_key     = var.tailscale_auth_key
  k3s_token              = var.k3s_token
  ssh_private_key_path   = var.ssh_private_key_path # pass the SSH private key path variable to the module for SSH access
}

module "worker_node" {
  count                  = 3
  source                 = "git@github.com:kaleyxiaozheng/k3s-node-module.git?ref=v1.0.0"
  node_name              = "worker-node-${count.index + 1}"
  node_type              = "worker"
  vm_id                  = 102 + count.index
  memory                 = 3072
  static_ip              = "192.168.50.${102 + count.index}/24"
  gateway                = "192.168.50.1"
  master_ip              = "192.168.50.101"
  ssh_public_key_content = file(var.ssh_public_key_path) # fetch the content of the SSH public key file and pass it to the module
  vm_password            = var.vm_password # pass the VM password variable to the module for cloud-init use  
  k3s_token              = var.k3s_token
  tailscale_auth_key     = var.tailscale_auth_key
  ssh_private_key_path   = var.ssh_private_key_path # pass the SSH private key path variable to the module for SSH access

# Ensure the master node is created before worker nodes 
  depends_on = [
    module.master_node
  ] 
}