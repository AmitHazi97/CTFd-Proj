# 🚩 Automated CTFd Infrastructure with Jenkins & Terraform

![Project Header](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)
![Jenkins](https://img.shields.io/badge/jenkins-%23D24939.svg?style=for-the-badge&logo=jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

## 📖 Project Overview
This project automates the deployment of a vulnerable **CTFd (Capture The Flag)** server on AWS. Built on **Ubuntu 24.04 LTS**, the system focuses on infrastructure isolation, automated provisioning, and high stability.

The entire environment is managed as **Infrastructure as Code (IaC)**, allowing for rapid deployment and automated teardown via a Jenkins CI/CD pipeline.

---

## 🛠️ Environment Prerequisites & Jenkins Setup
The pipeline is executed on a **Custom AMI** based on **Ubuntu 24.04 LTS**, pre-configured with the following DevOps toolchain to ensure seamless integration:

* **Jenkins Service**: 
    * Installed on a Linux system and runs as a persistent service.
    * Configured to automatically start on boot via `systemd`.
    * Orchestrates the entire CI/CD workflow via a `Jenkinsfile` stored in version control.
* **Terraform (v1.0+)**: Utilized for Infrastructure as Code (IaC) to provision and manage all 7 AWS resources.
* **AWS CLI**: Integrated for secure, IAM-based API authentication.
* **Docker**: Installed on the target server via User Data to host and manage the CTFd containers.

---

## 🏗️ Architecture & Security
The deployment creates a completely isolated environment to ensure security and prevent interference:

* **Isolated VPC**: A dedicated CIDR (`10.0.0.0/16`) was implemented to ensure zero IP conflicts and isolate the vulnerable infrastructure.
* **Security Groups**:
    * **Port 8000**: Inbound access for the CTFd Web UI.
    * **Port 22**: Inbound SSH for administrative tasks and "Escape the Box" style challenges.
* **Stability Enhancements (Optimized for t3.micro)**:
    * **2GB Swap File**: Manually configured within the host to provide memory resilience and prevent OOM (Out of Memory) crashes.
    * **Parallelism Control**: Terraform execution is limited to `-parallelism=1` to minimize CPU and RAM spikes.

---

## 🔌 CTFd & Platform Integration (Python Plugin)
The environment demonstrates full integration between Infrastructure and the CTF platform:

* **Automated Reachability**: A custom Python plugin validates connectivity between the CTFd instance and the vulnerable target.
* **Data Flow**: The Jenkins pipeline captures Terraform outputs (public IP) and passes them to the Python layer via the `server_ip.txt` artifact.
* **Validation Action**: The plugin exposes a "Validation" action in CTFd that attempts to reach the instance (e.g., via ICMP) and reports success or failure.

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
3. Retrieve the IP from the **Outputs** section:
   ```bash
   instance_public_ip = "3.70.45.59"
   ```

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
   
