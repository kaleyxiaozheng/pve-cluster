# Goal
To simulate a complete cloud-native lifecycle locally at near-zero cost: from microservice orchestration, CI/CD pipeline load testing, and Service Mesh traffic management, to the architectural evolution of your future platform products.
</br>

# Pre-requisites
<details><summary>1. Audit & Network Baseline</summary>

1. Run a Network Discovery Scan
Before walking around the house, get a quick baseline of what is currently alive on your network.

Run `nmap -sn 192.168.1.0/24` on your local subnet, and jot down the IP addresses, MAC addresses, and manufacturer names that pop up.

![image](./img/audit_&_network_baseline.png)

`192.168.1.0/24` scan returned empty because Mac is sitting on a `10.0.0.0` network.

Since the MAC is on `10.0.0.166`, the target subnet is almost certainly `10.0.0.0/24`.

Run command again to discover layer-2 ARP accurately.
`sudo nmap -sn 10.0.0.0/24`

📋 Audit Wrap-Up & Findings
- **Network Layout**: Flat, single subnet (10.0.0.0/24).

- **Edge Router**: Sagemcom Broadband SAS (10.0.0.138) running custom Belong ISP firmware.

- **VLAN** Support: _None_.

- **Network Isolation Capabilities**: _None_. The default firmware locks you out of creating isolated subnets or segmented zones.

- **Current IoT Footprint**: Intermittent local unvetted hardware (like the Chengdu Quanjing smart camera at 10.0.0.161 and generic appliances) sitting directly on the same broadcast domain as your Mac notebooks.

</details>

<details><summary>2. Check Router Support for VLANs</summary>

- Check if your current edge device has the capabilities to handle DevSecOps-style network isolation.

1. Access the Admin Dashboard
	- Find your router's gateway IP (http://mygateway).

2. Look for the "VLAN" or "Advanced Networking" Section
Navigate through the settings menus looking for these specific terms:
•	VLAN / Subnets / Interface Grouping: Typically found under Advanced, LAN, or Network settings. If you see options to create VLAN ID 10, VLAN ID 20, etc., your router supports full 802.1Q VLAN tagging. You are good to go for a true enterprise-grade setup.
•	IP Passthrough / Bridge Mode: If your router is a basic ISP-provided modem/router combo, it likely won't support VLANs. Note if it has a "Bridge Mode" option—this means you can bypass its routing entirely and plug in a more advanced firewall/router later.

3. The Fallback Plan: Check for Guest Network Isolation
If your router doesn't support true VLANs, look for a Guest Network tab (usually under Wireless or Wi-Fi Settings).
- 	Turn it on conceptually to see the options.
- 	Look for a checkbox labeled "Access Intranet/Local Network" (you want this disabled) or "Enable AP Isolation" / "Isolate Station" (you want this enabled).
- 	Why this matters: This forces the router to block any device on the Guest Wi-Fi from talking to your main LAN devices (like your personal laptops or NAS), acting as a basic, hardware-level firewall block.
</details>

<details><summary>💡 What Can Be Controlled via Local LAN (Offline-Capable)</summary>

LAN-controlled devices communicate directly with your router, smartphone, or a local hub without sending data over the internet.

- Standard Network Tools & Protocols: Tools like nmap, SSH, FTP, and local network printing (CUPS/AirPrint) operate entirely on your local subnet.

- Open-Standard Smart Home Devices: Devices using Zigbee, Z-Wave, or Thread connect to a local hub (like Home Assistant, Hubitat, or an Apple HomePod). The automation logic happens inside your house.

- Local API/DIY Hardware: Smart plugs or lights flashed with open-source firmware (like Tasmota or ESPHome), and certain brands like Philips Hue or Lifx that expose a local API.

- Local Video Streaming: Network Attached Storage (NAS) devices, local Plex servers, or IP security cameras configured via RTSP (Real-Time Streaming Protocol).

- HomeKit-Compatible Devices: Apple HomeKit handles architecture locally. If your iPhone and HomeKit accessory are on the same Wi-Fi, commands do not travel to the cloud.

**Pros & Cons of LAN Control**

👍 _Pros_: Ultra-fast response times (low latency), works when the internet is down, high privacy/security.

👎 _Cons_: Harder to control when you are away from home (requires setting up a VPN or a local hub), initial setup can be more technical.
</details>


<details><summary>💡 What Must Go Through the Cloud (Internet-Required)</summary>

Cloud-controlled devices do not talk directly to your phone. Instead, your phone talks to a server on the internet, and that server sends the command back down to the device in your home.

- Voice Assistants: Amazon Alexa and Google Home rely heavily on cloud-based Natural Language Processing (NLP) to understand and execute commands.

- Proprietary/Budget Wi-Fi Devices: Many cheap smart plugs, bulbs, and appliances (using apps like Tuya, Smart Life, or native brand apps) require an internet connection to hand off data to their remote servers.

- Geofencing & Weather Automations: Any automation that triggers based on your GPS location, or changes "if it rains tomorrow," must fetch data from cloud services.

- Third-Party Integrations (IFTTT): Services that bridge two different ecosystems (e.g., "If my Ring doorbell rings, blink my Hue lights via IFTTT") almost always process the logic in the cloud.

- Remote Web Services: Standard internet browsing, cloud storage (i.e., Google Drive, iCloud), and streaming services (Netflix, Spotify).

**Pros & Cons of Cloud Control**
👍 _Pros_: : Out-of-the-box remote control from anywhere in the world, seamless integration with voice assistants, incredibly easy setup.

👎 _Cons_: If your internet goes down (or the manufacturer's servers crash), your devices stop working. Higher latency and potential privacy concerns.
</details>

<details><summary>📋 Summary- The Hybrid Reality</summary>

Many modern devices use a hybrid approach. For example, a smart camera might stream video to your phone locally via LAN when you are home, but switch to a cloud stream the moment you step outside and connect to cellular data.

If you are aiming for privacy and reliability, look for devices labeled "Local Control" or integrate them using platforms like Home Assistant.
</details>
</br>

# Setup BeeLink
<details><summary>Creating a Proxmox VE (PVE) bootable USB drive</summary>

1. Download [Etcher for macOS (arm64)](https://etcher.balena.io/#download-etcher) and then drag `balenaEtcher` to Application
2. Download the latest .ios file from [Proxmox Website](https://www.proxmox.com/en/downloads)
3. Create bootable USB drive
- `diskutil eraseDisk ExFAT PVE MBR /dev/disk4`

| Command | Explain |
| :--- | :--- |
| `diskutil` | The built-in macOS utility used to manage disks,volumes, and partitions from the terminal |
| `eraseDisk` | To wipe the entire disk clean, destroying all existing partitions and data |
| `ExFAT` | This sets the "file system" format. ExFAT is a cross-platform format that is generally stable and easily recognized by macOS, making it a safe "clean slate" for tools like balenaEtcher to overwrite. |
| `PVE` | The name of the extend disk |
| `MBR` | Master Boot Record, MBR is often required for older or specific hardware booting (like the BIOS/UEFI mode used by many mini PCs like the Beelink) to recognize the USB drive as a bootable device. | 
| `/dev/disk4` | The identifier for the specific USB drive. It tells the system exactly which physical piece of hardware the previous instructions should be applied to |

</details>

<details><summary>Install PVE to BeeLink</summary>

1. setup `USB Device:UEFI: 0000, Partition 2` as Boot Option #1
2. restart and choose `Install Proxmox VE (Graphical)`
3. managetment network configuration

| Items | Value |
| :--- | :--- |
| Management Interface | nic0 (default value) |
| Hostname (FQDN) | pve.home |
| IP Address (CIDR) | 192.168.50.100/24 |
| Gateway | 192.168.50.1 |
| DNS Server | 192.168.50.1 |

4. Log in from a website via Mac Laptob: `https://192.168.50.100:8006`
- Username: root
-	Password: my password
5. Log in from Mac terminal: `ssh root@192.168.50.100`

</details>
</br>

# Terrafrom (IaC) and AWS
<details><summary>Create AWS Root account and Admin user</summary>

1. Create a root account in AWS
2. Create an IAM user
- login root account
- Search IAM
- User -> Create user (Admin)

![image](./img/create_IAM_admin_user.png)

- Permission -> `AdministratorAccess`

![image](./img/create_IAM_admin_user_permission.png)

📝 **Any AWS services will be prvisionsed by Admin user**

![image](./img/IAM_admin_user_login.png)

</details>

<details><summary>💰 Create AWS Budgets</summary>

<details><summary>💰 💰 Create AWS Budgets under Root Account</summary>

- Create budget in AWS Budgets
- Choose `Use a template (simplified)`
- Choose `Zero spend budget`
- Verify amount is $0.01 in `Budget amount`
- Email recipients: `team.aegisestate@gmail.com`
- Click `Create budget`

![image](./img/create_AWS_budgets.png)
</details>

<details><summary>🚀🚀🚀🚀 Save the budget🚀🚀🚀</summary>

给你的避坑指南（进阶版）
为了确保你的“永久不花钱”策略不失效，请记住这三条黄金准则：
•	避开“试用期”陷阱： AWS 有时会默认推荐一些高性能的存储（如 io2）或高级网络服务。在创建资源时，如果看到提示 "Free Tier Eligible"（符合免费层级），一定要勾选那个特定的配置。
•	别忘了清理： 你提到要做 AI Infra，这意味着你可能会用到 EC2（服务器）或 SageMaker（AI 训练）。这些东西不是永久免费的。
•	操作习惯： 每次练习完，确保进去点一下 "Terminate"（彻底终止，不是 Stop）。只有 Terminate 了，该资源占用的费用才会停止。
•	关于 Always Free： 当你看到 t3.micro 等服务标有 "Always Free" 时，这意味着只要你不超出每月 750 小时的使用限额，它就是永久免费的。这是你构建智能家居后台的首选。
</details>
</details>

<details><summary>Configure AWS configure, AWS CLI and Terraform CLI</summary>

<details><summary>1. AWS CLI and AWS configure</summary>

```bash
aws --version

# install aws CLI
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"

sudo installer -pkg AWSCLIV2.pkg -target /

which aws
aws --version
```

2. Connect AWS Admin account 
- Prepare key
> 1. AWS IAM -> AIM User (Admin) -> Security credentials -> Access keys -> Click `Create access key`
>
> 2. Save `Secret Key`
- aws configure
> Run `aws configure` from Mac Terminal

```bash
AWS Access Key ID: #copy and paste Access Key from CSV file
AWS Secret Access Key: # copy and paste Secret Key from CSV file
Default region name: ap-southeast-2 # same as terraform code
Default output format: json  # hit return

# verify
aws sts get-caller-identity
```

![image](./img/aws_config_admin_account.png)
</details>

<details><summary>2. Terrafrom </summary>

1. Terraform CLI
```bash
terraform --version

# upgrade version
brew trust hashicorp/tap
brew upgrade terraform  
```

2. run command `terrafomr init` under `pve-cluster` project **root path**

This command will do following things:

- Download Provider plugins: it reads provider.tf file，and downloads hashicorp/aws and Telmate/proxmox to .terraformfile
- Initialise Backend： it checks backend.tf and connects to AWS if it detecs S3
- Create workspace： it creates .terraform folder and lock.hcl file，These files guarantee the exact same plugin versions every time you run the code

⛔ Error occurred at command `terraform init`

![image](./img/s3_bucket_does_not_exist.png)

🎯 Solution: create s3 bucket first

![image](./img/s3_bucket_under_admin_account.png)

⛔ Error occurred at command `terraform plan`

![image](./img/terraform_plan_1.png)

🎯 Solution: create DynamoDB manually first
- Partition key: LockID

![imaga](./img/dynamodb_under_admin_account.png)

⛔ Error occurred at command `terraform plan`
> Root cause: S3 bucket with same name exsits and it was created manually, so it was not in state file.

🎯 Solution: Import S3 bucket to state file
```bash
terraform import aws_s3_bucket.aegis_logic_s3_bucket aegis-logic-terraform-state-bucket
```

</details>

<details><summary>🌟 Tips of Terraform</summary>

```bash
# format tf codes
terraform fmt

# clean up syntax error
terraform validate

# clean up cache and do terraform init
rm -rf .terraform .terraform.lock.hcl
terraform init
```
</details>
</details>
</br>

# Create ubuntu template in PVE
<details><summary>👉 Create ubuntu template in PVE UI (Recommended)</summary>

</br>
⭐ Create a template through PVE UI won't raise Terraform state drift issue.

1. Download [Ubuntu Server 24.04.4 LTS](https://ubuntu.com/download/server/thank-you?version=24.04.4&architecture=amd64&lts=true)

2. Create a basci VM (ubuntu-template) with ID 999

![image](./img/basic_vm_1.png)

![image](./img/basic_vm_2.png)

![image](./img/basic_vm_3.png)

![image](./img/basic_vm_4.png)

![image](./img/basic_vm_5.png)
💡 Setting the CPU type to host allows the virtual machine to directly utilize the full instruction set of the physical host CPU. This is particularly important for Kubernetes nodes, as it ensures the cluster can leverage advanced features like hardware virtualization extensions and specific instruction sets (such as AVX or AES-NI) required for efficient node operation and container performance.

![image](./img/basic_vm_6.png)

![image](./img/basic_vm_7.png)

![image](./img/basic_vm_8.png)

![image](./img/basic_vm_9.png)

🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 

‼️ To automate deployments using Terraform, ensure that a Cloud-Init Drive is added to Ubuntu VM template hardware configuration (select "Add" -> "CloudInit Drive" in the Proxmox interface) after installing the Ubuntu OS.

⚠️ This is a mandatory requirement for the proxmox_vm_qemu resource in Terraform to communicate with the cloned virtual machine, inject your SSH public key, and apply network configurations.

🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 🔴🟠🟡🟢🔵🟣 
3. add Cloud Init Drive
![image](./img/add_cloudinit_driver_1.png)

![image](./img/add_cloudinit_driver_2.png)

![image](./img/add_cloudinit_driver_3.png)

4. Start VM ubuntu-template and complete VM configuration by clicking console

![image](./img/configue_vm_template_1.png)

![image](./img/configue_vm_template_2.png)

![image](./img/configue_vm_template_3.png)

![image](./img/configue_vm_template_4.png)

![image](./img/configue_vm_template_5.png)

![image](./img/configue_vm_template_6.png)

![image](./img/configue_vm_template_7.png)

![image](./img/configue_vm_template_8.png)

![image](./img/configue_vm_template_9.png)
password: 123456

![image](./img/configue_vm_template_10.png)

![image](./img/configue_vm_template_11.png)

![image](./img/configue_vm_template_12.png)


5. Remove CD/DVD drive from hardware and verify boot order

![image](./img/ubuntu_template_boot_order_1.png)

6. reset username and password in cloud init seciton, click regenerate image and reset vm

![image](./img/cloud_init_username_password.png)

7. Log into 999 vm and install Guest Agent 
```bash
# 1. Update package list and install essential tools
sudo apt update
sudo apt install -y qemu-guest-agent cloud-init

# 2. Enable the Guest Agent
# This allows Proxmox to correctly identify and display the virtual machine's IP address and manage it effectively.
sudo systemctl enable --now qemu-guest-agent

# verify
systemctl status qemu-guest-agent

cloud-init status
```

![image](./img/enable_qemu_guest_agent.png)

![image](./img/qemu_guest_agent_verify_1.png)

![image](./img/qemu_guest_agent_verify_2.png)

8. Clean up the environment characters for template conversion
```bash
# clean up cache
sudo apt clean

# remove old SSH host key (prevent SSH fingerprint clash from cloned VM)
sudo rm /etc/ssh/ssh_host_*

# clean up cloud-init
sudo cloud-init clean

sudo truncate -s 0 /etc/machine-id

# verify
cat /etc/machine-id # expected empty line

ls /etc/ssh/ssh_host_* # expected "No such file or directory"

cloud-init status # expected "disabled" or "not run" for cloud-init clean
```

9. shut vm
```bash
sudo poweroff
```

10. convert ubuntu-template vm to template

![image](./img/convert_ubuntu_template_vm_to_template.png)

11. convert ubuntu-template to normal vm
- Run following command under `pve shell`
```bash
# remove template tag using sed command
sed -i '/^template: 1/d' /etc/pve/qemu-server/101.conf

# check if a lock file exists
ls -l /var/lock/pve-manager/qemu-server-101.lock

# if a lock file exsits, remove it
rm /var/lock/pve-manager/qemu-server-999.lock

# check exists
cat /etc/pve/qemu-server/101.conf
```

💡 Knowledge   
- Cloud-Init is used only at the very beginning when the VM first boots. It handles initial tasks like setting your SSH keys, hostname, and user creation.
- QEMU Guest Agent is a background service that runs inside your VM while it is operating. It acts as a permanent communication bridge between the Proxmox host and the guest OS.

</details>

<details><summary>💡 Remove Not Secure from browser address</summary>

The **Not Secure** warning and the red line in the browser address bar appear because you are accessing the Proxmox VE web interface using an SSL/TLS certificate that your browser cannot verify.

![image](./img/not_secure_signal.png)

⚙️ Fix 
```bash
# 1. download certificate to Mac
scp root@100.85.222.115:/etc/pve/pve-root-ca.pem ~/Desktop/

# 2. intall pem to Mac
```
</details>
</br>

# Install Tailscale 
<details><summary>What is Tailscale</summary>

TBC
</details>

<details><summary>Install Tailscale to BeeLink</summary>

1. SSH to PVE `ssh pve`
2. Run command `curl -fsSL https://tailscale.com/install.sh | sh`
3. Run command 	`tailscale up` to log into the account via browser, and sign in with Google

![image](./img/tailscale_account.png)

![image](./img/add_beelink_to_tailscale.png)
</details>

<details><summary>Install Tailscale to Mac</summary>

1. Download Tailscale from App store
2. Allow VPN Configuration

![image](./img/BeeLink_Mac_in_same_tunnel.png)

</details>

<details><summary>🚩 Install Tailscale to K3s-master-node once the master node is created </summary>

Got an error when check k3s master VM status.
```bash
root@pve:~# systemctl status k3s
Unit k3s.service could not be found.
```

🔧 Fix: Install Tailscale to k3s VM  
1. Access K3s master VM console 
2. run command
```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

K3s master node is now an independent node within your Tailscale network, assigned its own unique 100.x.x.x IP address. The cluster authentication keys are generated and readily available for you to access whenever needed.

![image](./img/command_tailscale_status.png)
</details>

<details><summary>Config kubeconfig</summary>

这是一个非常关键的观察！简单直接的回答是：你的 Master Node 的 IP 地址本身通常没有改变，但你现在有了“两个世界”的 IP 地址。
让我们理清楚这个逻辑：
1. 为什么你觉得 IP 变了？
•	原来的 IP (192.168.50.x)： 这是你家里局域网分配给 VM 的地址，只有在家里 Wi-Fi/有线网络下才有效。
•	现在的 IP (100.85.222.115)： 这是 Tailscale 虚拟网卡 分配的地址。这个 IP 是在全世界任何地方都能直接指向你那台 VM 的“全球唯一地址”。
你的 Master Node 的物理配置并没有改变，它依然拥有那个 192.168.50.x 的局域网地址。Tailscale 只是在你的 VM 内部安装了一张“虚拟网卡”，就像给这台机器多装了一张可以连通全球的“网卡”。
2. 你的 Master Node 受影响了吗？
•	功能上： 完全没有影响。它依然跑着你的 K3s 集群，依然在处理之前的任务。
•	访问上： 现在你多了一种连接方式。
•	在家时： 两种 IP 都能用。
•	在外网时： 必须使用 100.x.x.x，因为局域网 IP 192.168.50.x 在公网是无法路由的。
3. 给你的重要检查建议
为了确保你的 K3s 配置不会因为这个 IP 变化而崩溃，请执行以下检查：
	1.	登录 VM 100 的控制台。
	2.	输入 ip addr：
•	你会看到 eth0 (或者是 ens18 等) 有一个 192.168.50.x 的 IP。
•	你会看到一个叫 tailscale0 的接口，它上面绑定着 100.85.222.115。
	3.	K3s 的绑定： 你的 K3s 集群默认监听的是 0.0.0.0，这意味着它会自动同时接收来自这两个网卡的请求，所以它是不会因为多了个 IP 而停止工作的。
总结
你不需要担心 Master Node 的身份改变了。它只是被 Tailscale “赋能”了，变得可以在任何网络环境下被你找到。
你需要担心的是 kubeconfig：
因为你现在的 Kubernetes 集群 API Server 地址可能还是旧的（比如 192.168.50.100），你需要确保在外面通过 Tailscale 访问时，那个地址能被正确解析。这就是为什么我之前强烈建议你将 kubeconfig 中的 server 地址修改为 Tailscale IP 的原因——因为它是一个“全天候通用”的地址。
你的集群一切正常，明天带出去测试时，只要确保 Mac 连上了热点，然后使用 100.85.222.115 这个 IP 即可。

1. Retrieve the configuration from the k3s-master virtual machine terminal.
```bash
ssh master

ls -l /etc/rancher/k3s/k3s.yaml
sudo cat /etc/rancher/k3s/k3s.yaml
```
2. Copy and paste the whole context starting from `apiVersion` to `user` to Mac
- create folder `mkdir -p ~/.kube`
- copy and paste context of `k3s.yaml` to `~/.kube/config`
- override `server: https://127.0.0.1:6443` or `server: https://192.168.50.100:6443` to `server: https://100.85.222.115:6443`

3. Run command `kubectl get nodes` at Mac terminal. Mac now has full administrative access, allowing you to send control commands to 100.85.222.115 through an encrypted Tailscale tunnel—no matter where in the world you are tomorrow

❌ Can't run kubectl command
![image](./img/failed_run_kubectl_command_from_mac_terminal.png) 

Mac has successfully reached the VM via the Tailscale tunnel, but the K3s API server is not listening on that specific Tailscale IP address.
Simply put: The tunnel is open, but the door is locked.  

🤔 **Why is this happening?**  
By default, K3s typically listens only on 127.0.0.1 or the IP address of the primary network interface detected during installation (usually the eth0 IP, 192.168.50.x). It is currently unaware that it should be listening for traffic on the tailscale0 network interface.

💡 **Solution**  
Help K3s "see" the Tailscale interface
- Log into k3s-master node, edit the K3s configuration file
```bash 
cat /etc/systemd/system/k3s.service

sudo cat <<EOF | sudo tee /etc/systemd/system/k3s.service
[Unit]
Description=Lightweight Kubernetes
Documentation=https://k3s.io
Wants=network-online.target
After=network-online.target

[Install]
WantedBy=multi-user.target

[Service]
Type=notify
EnvironmentFile=-/etc/default/%N
EnvironmentFile=-/etc/sysconfig/%N
EnvironmentFile=-/etc/systemd/system/k3s.service.env
KillMode=process
Delegate=yes
User=root
LimitNOFILE=1048576
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
TimeoutStartSec=0
Restart=always
RestartSec=5s
ExecStartPre=-/sbin/modprobe br_netfilter
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/local/bin/k3s server --tls-san 100.119.185.90
EOF
```

![image](./img/k3s_master_k3s_service_1.png)

![image](./img/k3s_master_k3s_service_2.png)
- Load configuration: `sudo systemctl daemon-reload`
- Reboot k3s service: `sudo systemctl restart k3s`
- `sudo ss -tulnp | grep 6443`

![image](check_cluster_from_Mac_terminal.png)

网络连通性： 你已经成功配置了 Kubernetes API Server 监听 Tailscale 网络接口。
•	TLS 认证： 你已经成功处理了证书认证，使得 Mac 端的 kubectl 能够通过安全的加密隧道与集群通信。
•	集群管理： 你的 Mac 现在已经成为该 K3s 集群的远程管理终端。
</details>
</br>

# Create Proxmox API token before running terraform commands

<details><summary>What is proxmox API Token</summary>

Proxmox API Token enables Terraform to communicate with Proxmox on your behalf.

Terraform must connect to Proxmox PVE node via an API. This is typically achieved using an API ID and an API Token.
</details>

<details><summary>Create proxmox API Token</summary>

1. Log into PVE (https://100.85.222.115:8006/) 
2. API Token configuration  
Datacenter -> Permissions -> API Tokens -> Add
3. Add permission to terraform-token
4. Verify token  

```bash
curl -kv -H "Authorization: PVEAPIToken=root@pam\!terraform-token=1c50f781-99db-48fa-92d4-3feef9af6e6f" https://100.85.222.115:8006/api2/json/nodes
```

![image](./img/API_token_configuration.png)

![image](./img/API_token_creation.png)

![image](./img/API_token_info.png)

![image](./img/add_permission_to_terraform_token.png)

![image](./img/verify_api_token_1.png)
> 🚫 Token ID is incorrect in Authorization: PVEAPIToken=root@pamterraform...

![image](./img/verify_api_token_2.png)
</details>
</br>

# Set up k3s cluster 

<details><summary>1. create vm nodes</summary>

- Run following command under folder path `PVE-cluster` 
```bash
terraform init
terraform plan
terraform apply -auto-approve
```

- log into k3s master node after configuring ~/.ssh/config file

![image](./img/ssh_master_vm.png)

![image](./img/ssh_worker1_vm.png)

![image](./img/ssh_worker2_vm.png)

![image](./img/ssh_worker3_vm.png)

- To use kubectl conveniently in the long term, you can either change the file permissions to be readable by your current user or copy the file to your home directory.
```bash
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
source ~/.bashrc
```

![image](./img/kubectl_command_1.png)
</details>

<details><summary>4. Essential preparation tasks before deploy K3s cluster</summary>

- Update the system package list: Ensure that your system components are up to date.
- Configure basic dependencies: Install the necessary utilities.
- Prepare for K3s installation: Execute the official quick-installation script.

```bash
sudo apt update && sudo apt upgrade -y

# to ensure that the server is configured to allow K3s to utilize the necessary networking and container features
sudo swapoff -a
```

- 3 ways to verify swapoff command

![image](./img/verify_swapoff_command_1.png)

![image](./img/verify_swapoff_command_2.png)

![image](./img/verify_swapoff_command_3.png)

📋 `swapoff -a` command only disables swap temporarily for the current session. If you reboot the server, Ubuntu will read the /etc/fstab configuration file and automatically remount the swap partition.
To make this change permanent, you must comment out or delete the swap entry in the /etc/fstab file.

![image](./img/track_swap_in_etc_fstab.png)

```bash
cat /etc/fstab

# turnoff swap
sudo swapoff -a

# permanently disable swapoff
sudo sed -i '/swap.img/s/^/#/' /etc/fstab
```

> verify disable swap permanently

![image](./img/verify_disable_swap_permanently.png)

</details>

<details><summary>5. Install K3s in k3s-master node</summary>

```bash
curl -sfL https://get.k3s.io | sh -
```
verify node status
```bash
sudo kubectl get nodes
```

![image](./img/install_k3s.png)
</details>

<details><summary>6. Install Prometheus and Grafana</summary>

```bash
# 1. Download and unzip Helm, helm is the package manager in Kubernetes 
curl -LO https://get.helm.sh/helm-v3.15.1-linux-amd64.tar.gz
tar -zxvf helm-v3.15.1-linux-amd64.tar.gz

# 2. Move helm to bin folder
sudo mv linux-amd64/helm /usr/local/bin/helm

# 3. verify
helm version

# 4. Add the official Prometheus repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# 5. update index
helm repo update

# 6. verify
helm search repo prometheus-community
```
![image](./img/install_helm.png)

![image](./img/helm_install_prometheus.png)

- create a namespace to separate monitor system and applications pods

```bash
# 7. create a namespace to separate monitor system and application pods
kubectl create namespace monitoring
```

![image](./img/no_perission_only_root_user.png)

Fix: 
- `sudo kubectl create namespace monitoring`
- or grant permission to current user permonently
```bash

# 8. grant permission to current user
sudo chmod 644 /etc/rancher/k3s/k3s.yaml

# 9. setup environment variable
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
source ~/.bashrc

# 10. create ns
kubectl create namespace monitoring
```

![image](./img/grant_permission_create_ns.png)

```bash
# 11. deploy promethues and Grafana
sudo helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

![image](./img/repo_prometheus_community_not_found.png)

This is because previous configuration failed to store in kz user repo. 

Fix:
```bash
# 12. re-add prometheus repo
sudo helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
sudo helm repo update

# 13. verify
sudo helm repo list
```

Helm will begin downloading the manifest files for the various components from the repository and instantiate them as Pods, Services, and Deployments within Kubernetes.
•	Prometheus will be deployed as a StatefulSet, ensuring persistent data storage.
•	Grafana will run as a Deployment, waiting for you to access it via your web browser.

![image](./img/add_prometheus_repo.png)

![image](./img/connection_refuse.png)

This is because when you execute commands using sudo, your environment variables change. sudo does not automatically inherit the Kubeconfig permission settings that allow your current user to connect to the K3s cluster. Even though your cluster is already up and running, sudo helm fails to locate the hidden k3s.yaml configuration file, leading it to assume that you are not connected to any cluster at all.

To resolve this, you can explicitly point to the config file 

```bash
# 14. 
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
```

![image](./img/install_prometheus.png)

![image](./img/verify_prometheus_pods.png)

</details>

<details><summary>7. login Grafana via Web browser</summary>

Check pods are all running
To permanently fix permission issue
![image](./img/permanently_fix_permission_issue.png)

```bash
# 1. generate Grafana login password and store the password
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d ; echo

# 2. config port forwarding
# To enable access to the Grafana instance running inside your virtual machine from your MacBook's browser, we need to maintain a "tunnel" in your terminal.
sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80 --address='0.0.0.0'

# 3. view dashboard via Mac Web browser
# Open chrome in Mac
# Input address: http://192.168.50.100:3000
#	username：admin
# password：cope and paste the stored password
```

At this moment, the following logic is unfolding within your cluster:
- 	Data Collection: Prometheus automatically discovers and scrapes the health status (CPU, memory, network I/O, etc.) of each node via ServiceMonitor objects.
- Data Persistence: This data is stored in Prometheus's specialized time-series database (TSDB).
- 	Data Visualization: Grafana queries this data from Prometheus and renders it into the intuitive graphical dashboards you see in your browser.


⚠️ can't access Grafana via chrome
- port 3000 in use

![image](./img/port_3000_in_use.png)

🛠️ Fix: Update service type to NodePort

```bash
kubectl patch svc prometheus-grafana -n monitoring -p '{"spec": {"type": "NodePort"}}'

kubectl get svc prometheus-grafana -n monitoring
```

![image](./img/update_service_type_nodeport.png)

Then open chrome and input `http://192.168.50.101:30566`

![image](./img/grafana_login.png)
</details>

<details><summary>8. Walk through Prometheus pods</summary>

| Pod name | Role | Explanation |
| :--- | :--- | :--- |
| alertmanager-prometheus-kube-prometheus-alertmanager | | |
| prometheus-grafana | | | 
| prometheus-kube-prometheus-operator |  | |
| prometheus-kube-state-metrics | | | 
| prometheus-prometheus-kube-prometheus-prometheus | | | 
| prometheus-prometheus-node-exporter | | | 
</details>
</br>
 


<details><summary>Verififcation</summary>

To ensure K3s cluster is fully ready, perform the following steps:
1. Check IP address assignment:
In the Proxmox Web GUI, check the "Summary" page for each of the 4 VMs. Typically, a few minutes after the VM boots up, the `qemu-guest-agent` installed within the image will automatically sync the IP address to PVE.
2. Verify Cloud-Init injection:
Since used `source_raw` to pass the `user_data` directly, it is recommended to access the console of one of the nodes:
- Run sudo `cat /var/lib/cloud/instance/user-data.txt` to verify that your configuration was injected correctly.
- If no IP address is assigned, check the console for any error logs related to network configuration.
3. The fundamental first step to confirm that all nodes are online and have successfully joined the cluster.
- Run the command on the master node:
```bash
kubectl get nodes
kubectl get pods -n kube-system
```
4. Check Prometheus status
- Run the command on the master node: 
```bash
# check Prometheus Pod under monitoring namespace
kubectl get pods -n monitoring
```
- If the pods are running properly, we need to verify that they are actually collecting data. Map the service to the local machine using `kubectl port-forward`
```bash
kubectl port-forward svc/prometheus-server -n monitoring 9090:80
```
然后在浏览器打开 http://localhost:9090，进入 Status -> Targets 页面。
•	核心指标：Targets 页面
这是最关键的检查点。在该页面中：
•	Node Exporter：你应该能看到所有 Worker 节点的地址，且状态应为 UP（绿色）。
•	如果状态是 DOWN（红色），说明 Prometheus 无法连接到节点的 node-exporter。
3. 验证数据采集情况（PromQL 查询）
进入 Prometheus UI 的 Graph 页面，输入以下查询语句，看看是否能查到数据：
•	检查节点存活：up{job="node-exporter"}
•	如果有数据且值为 1，说明 Prometheus 已经成功采集到了该节点的指标。
•	检查集群负载：node_load1
•	如果能看到图形化数值，说明数据流入正常。
4. 常见排查点（如果发现异常）
如果监控没数据或显示 DOWN，请检查以下两点：
	1.	网络互通性：Prometheus 必须能够通过内网访问到各个 Worker 节点的 9100 端口（这是 node-exporter 的默认端口）。你可以从 Prometheus Pod 内部 telnet 一下节点端口：
kubectl exec -it <prometheus-pod-name> -n monitoring -- /bin/sh
# 然后在里面执行
nc -zv <worker-node-ip> 9100

	2.	ServiceMonitor/PodMonitor 配置：如果你是用 Prometheus Operator 安装的，确保对应的 ServiceMonitor 资源已经创建，并指定了正确的 matchLabels 来关联你的 exporter 服务。

</details>

<details><summary>🧰 Troubleshooting</summary>

<details><summary>👉 Guest Agent not running</summary>

![image](./img/guest_agent_not_running.png)

This usually means that even though the virtual machine has booted, the QEMU Guest Agent service is either not running or not installed at all.

The purpose of this agent is to allow Proxmox to gain deeper insight into the virtual machine (such as IP addresses, memory usage, and more precise shutdown commands).

The definition `agent { enabled = true }` in Terraform is correct. It instructs Proxmox to enable hardware support for the QEMU Guest Agent for that specific virtual machine.

### 🤷‍♀️ Why does the Agent still show "not running" inside the VM?

This is typically because Terraform can only configure the "hardware-level" switch; it cannot install or start software services inside the virtual machine (at the operating system level). Even if you have set `enabled = true` in Terraform, if the corresponding `qemu-guest-agent package` is not installed inside the VM (Ubuntu), the Proxmox interface will still display "Agent not running."

｜Distinguish | Purpose |
| :--- | :--- |
| **PVE Host** (`the hypervisor`) | This is where you manage the "Infrastructure as Code" via Terraform. The only action required on the PVE side is enabling the **`QEMU Guest Agent`** checkbox under Options, which is a hardware-level configuration. |
| **Virtual Machine** (`VM`) | This is the operating system (Ubuntu) that you access via `kubectl` or `SSH`. You need to install and start the **`qemu-guest-agent daemon`** at this level so that it can send status data back to PVE through the virtual hardware channel |

⚙️ `Fix`: How to get the Agent running
Add Agent install and start commands in `k3s-master-init.yaml.tpl` and `k3s-worker-init.yaml.tpl` files
</details>
</details>

<details><summary>Destory and re-create process</summary>

1. Terraform commands
```bash
# 1. remove 4 VM
terraform destroy

# 2. verify
terraform state list

# 3. re-create
terraform apply
```

2. Manually
- remove 4 VM from PVE
- clean up `pve->local(pve)->Snippets`
- 
```bash
# 1. Force remove these orphaned VMs from the Terraform state to prevent errors during the next apply
terraform state rm $(terraform state list)

# 2. re-init and apply
terraform init -upgrade
terraform apply
```
</details>
</br>

# Clean up PVE
<details><summary>Clean up master node and worker nodes in VPE  </summary>

1. Shutdown k3s-master-node and 3 worker-nodes manually.
2. Remove VM of k3s-master-node and 3 worker-nodes from PV manually 
3. check local-lvm via command `
pvesm list local-lvm` in pve shell
4. if the above command returns  vm-xxx-disk-x, run command `pvesm free local-lvm:vm-102-disk-0`

</details>
</br>

# ‼️IMPORTANT‼️
<details><summary>‼️ Network Routing Conflict: Tailscale Interference  </summary>

Tailscale virtual network interface (the tailscale0 or utun interface) has taken over the system's routing table.

🌟🌟 solution:  
1️⃣ ssh pve via terminal: `ssh root@100.85.222.115`  
2️⃣ access pve via browser: `https://100.85.222.115:8006`

![image](./img/tailscale_ip.png)

![image](./img/connected_devices_tailscale.png)
</details>
</br>

# Learning Points
<details><summary>💡 K3s runs as a Systemd service in the background</summary>

1. K3s runs as a Systemd service in the background, rather than a process that you need to manually "start" or keep open in your terminal, then you can check its status and start it after `ssh pve`

```bash
sudo systemctl status k3s
sudo systemctl start k3s
```
</details>
</br>

这是一个非常好的策略性问题。作为架构师，我会建议你：先安装 Prometheus 和 Grafana，然后再扩容 Worker 节点。
原因在于，监控系统本身就是你管理集群的“眼睛”。
为什么要先安装监控？
	1.	获得“上帝视角”： 当你开始添加 Worker 节点时，集群的负载分布会发生变化。如果你先装好了 Grafana，你就能在增加节点的过程中，实时看到内存是如何被分摊到新节点上的，CPU 的使用曲线是如何平滑下来的。这种对比是非常直观的学习过程。
	2.	避免后续“盲操作”： 如果你先一股脑儿把 Worker 节点全装好，一旦某个节点因为配置问题或者资源冲突导致 Pod 无法正常调度，你还得回头去排查为什么它不工作。先装监控，等于先装好了“报警器”，后面的扩容操作会更从容。
	3.	资源利用率验证： 你可以先看看 Prometheus 采集到的数据，确认当前 Master 节点的资源消耗情况，这样你就能更准确地评估：“我到底需不需要再加 3 个节点，还是其实加 1 个就够了？”
建议的操作流程：
	1.	第一阶段（当前）： 在你现有的 k3s-master 上完成 Prometheus 和 Grafana 的部署，把监控仪表盘跑起来。
	2.	第二阶段（验证）： 在 Grafana 里观察集群的资源占用。如果你发现内存占用已经到了 70%-80%，这时候再创建 Worker 节点就非常“名正言顺”了。
	3.	第三阶段（扩容）： 依次创建并加入 Worker 节点。每加一个节点，你都能在 Grafana 的面板上看到新的节点信息被自动识别并展示出来。
给你一个架构小挑战：
你可以先通过我之前给你的 helm 命令把 Prometheus 和 Grafana 装上。当你能在 Grafana 里看到 k3s-master 的资源数据时，再来找我，我教你如何通过自动化脚本快速加入 Worker 节点。
现在的集群只有一个 Master，监控系统跑起来后，你会看到非常清晰的资源利用率曲线。你想好先监控哪些指标了吗？（比如是先看 CPU 还是内存？）



what is makefile?
write dokcerfile
write terraform module