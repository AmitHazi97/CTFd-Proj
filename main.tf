
module "networking" {
  source = "./modules/networking"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "aws_instance" "ctf_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  subnet_id              = module.networking.subnet_id
  vpc_security_group_ids = [module.networking.sg_id]

  user_data = <<-EOF
              #!/bin/bash
              useradd -m -s /bin/bash ctf
              echo "ctf:ctf" | chpasswd
              echo "ctf ALL=(ALL) NOPASSWD: /usr/bin/find" > /etc/sudoers.d/ctf
            
              apt-get update
              apt-get install -y docker.io
              systemctl start docker
              systemctl enable docker

              docker run -d -p 8000:8000 --name ctfd --restart unless-stopped ctfd/ctfd || docker start ctfd
              EOF

  tags = { Name = "CTF-Vulnerable-Server" }
}

output "public_ip" {
  description = "The public IP address of the CTF server"
  # השם כאן חייב להתאים בדיוק לשם המשאב שהגדרת ב-resource
  value       = aws_instance.ctf_server.public_ip
}