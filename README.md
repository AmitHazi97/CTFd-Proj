# 🚩 Automated CTFd Infrastructure with Jenkins & Terraform

![Project Header](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%23D24939.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

## 📖 Project Overview
This project automates the deployment of a vulnerable **CTFd (Capture The Flag)** server on AWS. Built on **Ubuntu 24.04 LTS**, the system focuses on infrastructure isolation, automated provisioning, and high stability.

The entire environment is managed as **Infrastructure as Code (IaC)**, allowing for rapid deployment and automated teardown via a Jenkins CI/CD pipeline.

---

## 🔧 Jenkins Installation & Setup
To meet the requirement of a persistent automation server, Jenkins was configured as follows:

* [cite_start]**Service Deployment**: Jenkins is installed on a Linux-based controller [cite: 57] [cite_start]and configured as a `systemd` service to ensure it runs as a service [cite: 59] [cite_start]and automatically starts on boot.
* [cite_start]**CI/CD Integration**: The pipeline logic is defined via a `Jenkinsfile` stored in version control [cite: 61, 78][cite_start], enabling a reproducible build-to-deploy flow.
* [cite_start]**Toolchain**: The Jenkins node is pre-provisioned with Terraform, AWS CLI, and Docker to execute the required infrastructure and deployment stages.

---

## 🏗️ Architecture & Security
[cite_start]The deployment creates a completely isolated environment to ensure security and prevent interference:

* [cite_start]**Isolated VPC**: A dedicated CIDR (`10.0.0.0/16`) was implemented to ensure zero IP conflicts with the Jenkins controller and to isolate the vulnerable infrastructure.
* **Security Groups**:
    * [cite_start]**Port 8000**: Inbound access for the CTFd Web UI.
    * [cite_start]**Port 22**: Inbound SSH for administrative tasks and "Escape the Box" style challenges.
* **Stability Enhancements (Optimized for t3.micro)**:
    * [cite_start]**2GB Swap File**: Manually configured within the **Ubuntu 24.04** host to provide memory resilience and prevent OOM (Out of Memory) crashes during the `terraform apply` phase.
    * [cite_start]**Parallelism Control**: Terraform execution is limited to `-parallelism=1` to minimize CPU and RAM spikes on micro-instances.

---

## 🔌 CTFd & Platform Integration
[cite_start]The environment demonstrates a full integration between Infrastructure as Code and the CTF platform[cite: 4, 5]:

* [cite_start]**Automated Reachability**: A Python-based validation logic (implemented as a CTFd plugin) ensures connectivity between the CTFd instance and the vulnerable target.
* [cite_start]**Data Flow**: The Jenkins pipeline captures Terraform outputs (such as the public IP) and passes them to the Python/CTFd layer.
* [cite_start]**Validation**: The system includes a verification action in the CTFd UI/API that attempts to reach the EC2 instance (e.g., via ICMP) and reports success or failure.

---

## 🔧 Jenkins Installation & Setup
To meet the requirement of a persistent automation server, Jenkins was configured as follows:

* [cite_start]**Service Deployment**: Jenkins is installed on a Linux-based system and configured as a `systemd` service to ensure it runs as a service and automatically starts on boot.
* [cite_start]**CI/CD Integration**: The pipeline code is stored in version control (Jenkinsfile), enabling a reproducible and automated build-to-deploy flow.
* [cite_start]**Toolchain**: The Jenkins node is pre-provisioned with Terraform, AWS CLI, and Docker to execute the required infrastructure and deployment stages.
---

## 🛠️ Environment Prerequisites
The pipeline is executed on a **Custom AMI** based on **Ubuntu 24.04 LTS**, pre-configured with the following DevOps toolchain to ensure seamless integration:

* **Jenkins**: Orchestrates the entire CI/CD workflow and manages environment-specific credentials.
* **Terraform (v1.0+)**: Utilized for Infrastructure as Code (IaC) to provision and manage all 7 AWS resources.
* **AWS CLI**: Integrated for secure, IAM-based API authentication between the controller and the cloud provider.
* **Docker**: Installed on the target server via User Data to host and manage the CTFd application containers.

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
├── CTFd/                  # CTFd source code and Docker configuration 
├── modules/
│   └── networking/        # Reusable VPC, Subnets, and Security Groups 
├── .gitignore             # Git exclusion rules
├── Jenkinsfile            # End-to-end pipeline logic (Groovy) 
├── main.tf                # Main AWS resource provisioning (EC2 & User Data) 
├── providers.tf           # AWS Provider configuration 
├── server_ip.txt          # Artifact used to pass Terraform outputs to Python 
└── setup.sh               # Bash script for vulnerable sudo find configuration 
```
 ---

## 🧹 Tearing Down
To stop AWS billing and remove all **7 resources**:

1. Run the **Jenkins job**.
2. Check the **DESTROY_INFRA** parameter.
3. Click **Build**.
   
