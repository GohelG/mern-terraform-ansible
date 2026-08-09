# Multi-Tier MERN Application Deployment on Azure via Terraform & Ansible
This repository automates the infrastructure provisioning and deployment of a multi-tier MERN (MongoDB, Express, React, Node.js) application on Microsoft Azure using Terraform and Ansible.

---

## 🏗️ Project Architecture
*   **Networking:** 1 Azure Virtual Network (VNet) split into 1 Public Subnet (Web Frontend/API) and 1 Private Subnet (Database Layer).
*   **Gateways:** Azure NAT Gateway attached to the private subnet for secure outbound internet traffic.
*   **Compute:** 
    *   `web-server-vm`: Ubuntu Linux Virtual Machine in the public subnet.
    *   `db-server-vm`: Ubuntu Linux Virtual Machine in the private subnet.
*   **Security:** Network Security Groups (NSG) configured with strict IP whitelisting for SSH, and an Azure User-Assigned Managed Identity.

---

## 📁 Repository File Structures

### 1. Terraform Infrastructure Layout

```text
terraform-azure-project/
│
├── modules/                 # Reusable infrastructure blocks
│   ├── vnet/                # Network component layer
│   │   ├── main.tf          # VNet, Subnets, NAT Gateway, Route Tables
│   │   ├── variables.tf     
│   │   └── outputs.tf       # Outputs vnet_id, subnet_ids to feed other modules
│   │
│   ├── security/            # Access Control layer
│   │   ├── main.tf          # NSGs and User-Assigned Managed Identities
│   │   ├── variables.tf
│   │   └── outputs.tf       # Outputs security_group_ids and identity_names
│   │
│   └── compute/             # Server layer
│       ├── main.tf          # Web and DB Azure Virtual Machine instances
│       ├── variables.tf
│       └── outputs.tf       # Outputs individual VM metadata
│
├── main.tf                  # Root file orchestration (calls vnet, security, compute)
├── providers.tf             # Terraform & Azure Provider Authentication definitions
├── variables.tf             # Global input variables
└── outputs.tf               # Root output pulling the Web IP from compute module
```

### 2. Ansible Configuration Layout

```text
ansible-project/
│
├── group_vars/
│   ├── all.yaml                 # Global configuration (app versions, paths)
│   ├── webservers.yaml          # Node.js environment variables & secrets
│   └── dbservers.yaml           # MongoDB database names and user accounts
│
├── roles/
│   ├── common/                 # Basic security hardening for all nodes
│   │   ├── handlers/main.yaml                  
│   │   └── tasks/main.yaml      
│   │
│   ├── webserver/              # Node.js, NPM, Git, and PM2 deployment
│   │   ├── tasks/main.yaml
│   │   ├── handlers/main.yaml   
│   │   └── templates/env.j2    # Dynamic .env file for the Express backend
│   │
│   └── dbserver/               # MongoDB installation, binding, and users
│       ├── tasks/main.yaml 
│       ├── handlers/main.yaml        
│       └── templates/mongod.conf.j2  # Custom config file to allow connections
│
├── ansible.cfg                 # Global configuration defaults
├── inventory.ini               # Public and Private IP listings (from Terraform)
└── site.yaml                   # Master playbook coordinating the installation
```
---

## 🛠️ Prerequisites
Before executing the pipelines, ensure you have the following utilities installed locally:

*   [Azure CLI](https://microsoft.com) 
*   [Terraform](https://hashicorp.com) 
*   [Ansible Core](https://ansible.com) 

---

## 🚀 Part 1: Infrastructure Setup with Terraform

### 1. Azure CLI install, Azure Setup and AuthenticationLog into your Azure account using the Azure CLI and set your target subscription:

```bash
curl -fsSL 'https://azurecliprod.blob.core.windows.net/$root/deb_install.sh' | sudo bash
```

```bash
az login
az account set --subscription "SUBSCRIPTION_ID"
```

### 2. Initialization and Execution
### Deployment Steps

Follow these steps to deploy the infrastructure using Terraform.

#### 1. Navigate to the Project Directory
Change your current working directory to the location of your Terraform files:
```bash
cd /path/to/your/terraform/project
```

#### 2. Initialize Terraform
Initialize the backend configuration and download the required provider modules:
```bash
terraform init
```

#### 3. Format the Configuration
Automatically rewrite all Terraform configuration files to ensure consistent formatting and style:
```bash
terraform fmt
```

#### 4. Validate the Code
Verify the configuration files to ensure they are syntactically valid and internally consistent:
```bash
terraform validate
```

#### 5. Generate an Execution Plan
Create and save a preview of the actions Terraform will take to reach your desired state:
```bash
terraform plan -out=myplan.binary
```

#### 6. Apply the Configuration
Deploy the virtual network (VNet), subnets, security groups, managed identities, and virtual machines. 

Run the following command to execute the saved plan:
```bash
terraform apply myplan.binary
```

*Note: If you are applying changes directly without a saved plan file, you can append the `--auto-approve` flag to bypass the interactive approval prompt:*
```bash
terraform apply --auto-approve
```

### 3. Resource OutputsUpon successful application, Terraform outputs critical connectivity definitions needed for deployment configuration:

```text
Outputs:
web_server_public_ip = "X.X.X.X"
```
---

## 📦 Part 2: Configuration & Deployment with Ansible 
Once the infrastructure is ready, Ansible takes over to configure the operating systems and run the application.

### 1. Configure Inventory
Update the local `inventory.ini` using the public and private IP coordinates provided by Terraform. Connection to the private database server is proxied securely through the public web node:

```ini
[webservers]
web_node ansible_host=YOUR_PUBLIC_WEB_SERVER_IP

[dbservers]
db_node ansible_host=YOUR_PRIVATE_DB_SERVER_IP ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q ubuntu@YOUR_PUBLIC_WEB_SERVER_IP -i ~/.ssh/azure-vm-key.pem"'
```

### 2. Deploy Configuration PlaybooksRun the master execution file to provision, compile, build, and harden your environments:

```bash
ansible-playbook -i inventory.ini site.yml
```

### 3. Automated Tasks Executed by Ansible
*   **Security Hardening:** Packages are upgraded to stable distributions, root SSH login is explicitly deactivated, and localized firewalls (UFW) are configured.
*   **Database Provisioning:** MongoDB is compiled on the private node, local loopback restrictions are updated to accept trusted application traffic, and access controls (RBAC) are verified.
*   **Web Server Build Out:** Node.js runtime engines are installed, your MERN stack source code repository is cloned via Git, environment files are written dynamically, production bundles are built, and processes are spawned using `pm2`.

---
## 🔒 Security Summary
*   **SSH Isolation:** The Web infrastructure accepts incoming requests on port `22` strictly from your white-listed local workstation IP.
*   **DB Security:** The Database layer has no public IP tracking and completely rejects direct public internet traffic. It communicates on port `27017` solely with verified traffic from the Web public subnet.
---

# 👨‍💻 Author

**Gautam Gohel**

System Administrator | SRE Engineer | DevOps & Cloud Enthusiast 🚀

---
---