# 🚩 Automated CTFd Infrastructure with Jenkins & Terraform

![Project Header](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%23D24939.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

## 📖 Project Overview
This project automates the deployment of a vulnerable **CTFd (Capture The Flag)** server on AWS. Built on **Ubuntu 24.04 LTS**, the system focuses on infrastructure isolation, automated provisioning, and high stability.

The entire environment is managed as **Infrastructure as Code (IaC)**, allowing for rapid deployment and automated teardown via a Jenkins CI/CD pipeline.

---

## 🏗️ Architecture & Security
The deployment creates a completely isolated environment to ensure security and prevent interference:



* **Isolated VPC**: Dedicated CIDR (`10.0.0.0/16`) separate from the default Jenkins network.
* **Security Groups**:
    * **Port 8000**: Inbound access for CTFd Web UI.
    * **Port 22**: Inbound SSH for management.
* **Stability Enhancements**:
    * **2GB Swap File**: Added to prevent OOM (Out of Memory) crashes during provisioning.
    * **Parallelism Control**: Terraform runs with `-parallelism=1` to conserve resources on micro-instances.

---

## 🛠️ Environment Prerequisites
The pipeline is designed to run on a Custom AMI (Ubuntu 24.04 LTS) with:
* **Jenkins**: Orchestrates the workflow.
* **Terraform (v1.0+)**: Manages AWS resources.
* **AWS CLI**: For secure API authentication.
* **Docker**: To host the CTFd application.

---

## 🚀 Deployment & How to Find the IP

### 1. Run the Pipeline
1. Open Jenkins and select the **CTF-Automation** job.
2. Click **Build with Parameters**.
3. Ensure `DESTROY_INFRA` is **unchecked** and click **Build**.

### 2. Locating the IP in Logs
Since AWS assigns a dynamic IP, you must retrieve it from the Jenkins logs:
1. Open the current build in Jenkins and click on **Console Output**.
2. Scroll to the bottom to find the **Terraform Apply** stage.
3. Look for the **Outputs** section. It will look like this:

> **📋 Terraform Output Example:**
> ```bash
> Outputs:
> instance_public_ip = "3.70.45.59"
> ```

### 3. Access the Environment
* **Web UI**: `http://<IP_FROM_LOGS>:8000`
* **SSH Access**: `ssh ctf@<IP_FROM_LOGS>` (Password: `ctf`)

---

## 🛡️ Challenge Verification (GTFOBins)
The server is pre-configured with a privilege escalation vulnerability:

1. Connect via SSH as user `ctf`.
2. Run `sudo -l` to see allowed commands.
3. Exploit the `find` binary to gain **Root** access:
   ```bash
   sudo find . -exec /bin/sh \;
   whoami # Should return 'root'
---

## 📂 Project Structure
```text
├── Jenkinsfile            # Pipeline logic (Init, Plan, Apply, Destroy)
├── main.tf                # EC2 Instance & User Data (Docker setup)
├── providers.tf           # AWS Provider settings
├── variables.tf           # Environment variables
└── modules/
    └── networking/        # VPC, Subnets, and Security Groups
```
 ---

## 🧹 Tearing Down
To stop AWS billing and remove all **7 resources**:

1. Run the **Jenkins job**.
2. Check the **DESTROY_INFRA** parameter.
3. Click **Build**.
   
