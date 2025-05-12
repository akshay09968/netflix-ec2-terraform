locals {
  ingress_ports = ["22", "80", "443", "8080", "9000"]
}

resource "aws_security_group" "net-sg" {
  name   = var.sg-name
  vpc_id = var.vpc_id
}

resource "aws_vpc_security_group_ingress_rule" "net-sg-ingress" {
  for_each          = toset(local.ingress_ports)
  security_group_id = aws_security_group.net-sg.id
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "net-sg-egress" {
  from_port         = 0
  to_port           = 0
  security_group_id = aws_security_group.net-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"  # -1 means all protocols
}

resource "aws_instance" "net-ec2" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.net-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    git clone https://github.com/N4si/DevSecOps-Project.git

    sudo apt-get update
    sudo apt-get install docker.io -y
    sudo usermod -aG docker $USER
    newgrp docker
    sudo chmod 777 /var/run/docker.sock

    docker run -d --name sonar -p 9000:9000 sonarqube:lts-community

    sudo apt-get install wget apt-transport-https gnupg lsb-release -y
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
    echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
    sudo apt-get update
    sudo apt-get install trivy -y

    sudo apt update
    sudo apt install fontconfig openjdk-17-jre -y

    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
    https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
    sudo apt-get update
    sudo apt-get install jenkins -y
    sudo systemctl start jenkins
    sudo systemctl enable jenkins
  EOF

  tags = {
    Name = var.ec2_name
  }
}