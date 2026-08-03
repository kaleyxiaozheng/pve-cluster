# variables.tf

# variable "template_ip" {
#   description = "Static IP for the Ubuntu template VM"
#   type        = string
# }

# variable "pve_host_ip" {
#   description = "IP address of the Proxmox host"
#   type        = string
# }

# variable "datastore" {
#   type    = string
#   default = "local-lvm"
# }

variable "proxmox_api_url" {
  description = "Proxmox API address"
  type        = string
  default     = "https://192.168.50.100:8006/"
}

variable "proxmox_api_token" {
  description = "Proxmox API Token (format: user@realm!tokenid=tokenvalue)"
  type        = string
  sensitive   = true  # Terraform will not display it in plain text in the logs
}

variable "k3s_token" {
  description = "The token used for K3s node joining"
  type        = string
  sensitive   = true  # true to prevent it from being displayed in logs, as it's a sensitive value
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key for node access"
  type        = string
  default     = "/Users/kaleyzheng/.ssh/id_ed25519"
  sensitive   = true  # true to prevent it from being displayed in logs, as it's a sensitive value
}

variable "ssh_public_key_path" { 
  description = "Path to the SSH public key for node access"
  type = string 
  default = "/Users/kaleyzheng/.ssh/id_ed25519.pub"
  sensitive   = true  # true to prevent it from being displayed in logs, as it's a sensitive value
}

variable "vm_password" { 
  type = string
  sensitive = true 
  description = "Password for user ubuntu on the VMs (if needed for cloud-init)"
}

variable "node_type" {
  type        = string
  description = "Node type: master or worker"
  default     = "worker" 
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key for node access"
  type        = string
  sensitive   = true  # true to prevent it from being displayed in logs, as it's a sensitive value
}

# variable "master_tailscale_ip" {
#   description = "Tailscale IP of the master node for worker nodes to connect"
#   type        = string
# }