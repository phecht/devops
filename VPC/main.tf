terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    ansible = {
      version = "1.1.0"
      source  = "ansible/ansible"
    }
  }

  required_version = ">= 1.2.0"
}

# Configure the AWS provider

provider "aws" {
  region = var.aws_region
}


# Create a VPC

resource "aws_vpc" "MyLab-VPC" {
  cidr_block = var.cidr_block[0]

  tags = {
    Name = "MyLab-VPC"
  }

}

# Create a Subnet (public)

resource "aws_subnet" "MyLab-Subnet1" {
  vpc_id     = aws_vpc.MyLab-VPC.id
  cidr_block = var.cidr_block[1]
  tags = {
    Name = "MyLab-Subnet1"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "Mylab-InternetGateway" {
  vpc_id = aws_vpc.MyLab-VPC.id

  tags = {
    Name = "MyLab-InternetGateway"
  }
}

# Create a security group

resource "aws_security_group" "MyLab_sec_group" {
  name        = "MyLab Security Group"
  description = "Allow inbound and outbound traffic to MyLab"
  vpc_id      = aws_vpc.MyLab-VPC.id

  dynamic "ingress" {
    iterator = port
    for_each = var.ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow traffic"
  }

}

# create a routig table and association

resource "aws_route_table" "MyLab_RouteTable" {
  vpc_id = aws_vpc.MyLab-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Mylab-InternetGateway.id
  }

  tags = {
    name = "MyLab_RouteTable"
  }
}

resource "aws_route_table_association" "MyLab_asscoiation" {
  subnet_id      = aws_subnet.MyLab-Subnet1.id
  route_table_id = aws_route_table.MyLab_RouteTable.id

}

# Create a AWS EC2 instance
resource "aws_instance" "Jenkins" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.instance_key_name
  vpc_security_group_ids      = [aws_security_group.MyLab_sec_group.id]
  subnet_id                   = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data                   = file("InstallJenkins.sh")

  tags = {
    Name = "Jenkins-Server"
  }
}

resource "aws_instance" "AnsibleController" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.instance_key_name
  vpc_security_group_ids      = [aws_security_group.MyLab_sec_group.id]
  subnet_id                   = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data                   = file("InstallAnsibleCN.sh") 

  tags = {
    Name = "Ansible-ControlNode"
  }
}

resource "aws_instance" "AnsibleManagedNode1" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.instance_key_name
  vpc_security_group_ids      = [aws_security_group.MyLab_sec_group.id]
  subnet_id                   = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data                   = file("AnsibleManagedNode.sh") 

  tags = {
    Name = "AnsibleMN-ApacheTomcat"
  }
}

resource "aws_instance" "DockerHost" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.instance_key_name
  vpc_security_group_ids      = [aws_security_group.MyLab_sec_group.id]
  subnet_id                   = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data                   = file("dockersetup.sh") 

  tags = {
    Name = "DockerHost"
  }
}

resource "aws_instance" "Nexus" {
  ami                         = var.ami
  instance_type               = var.instance_type_for_nexus
  key_name                    = var.instance_key_name
  vpc_security_group_ids      = [aws_security_group.MyLab_sec_group.id]
  subnet_id                   = aws_subnet.MyLab-Subnet1.id
  associate_public_ip_address = true
  user_data                   = file("InstallNexus.sh") 

  tags = {
    Name = "Nexus-server"
  }
}

// On controlnode ssh-keygen
// ssh-copy-id to ManagedNode.
// 
/* 
resource "ansible_host" "my_ec2" {          #### ansible host details
  name   = "auto1Ansible"
  groups = ["nginx"]
  variables = {
    ansible_user                 = "ansible",
    ansible_ssh_private_key_file = "~/.ssh/id_rsa",
    ansible_python_interpreter   = "/usr/bin/python3"
  }
}

# Output the pulic IP address of the EC2 Jenkins instance
output "instance_anisble_host" {
  value       = ansible_host.my_ec2.name
  description = "The name of ansible instance"
}
 */

# Output the pulic IP address of the EC2 Jenkins instance
output "instance_public_jenkins_ip" {
  value       = aws_instance.Jenkins.public_ip
  description = "The public IP address of the EC2 Jenkins instance"
}

# Output the pulic IP address of the EC2 AnsibleController instance
output "instance_public_AnsibleController_ip" {
  value       = aws_instance.AnsibleController.public_ip
  description = "The public IP address of the EC2 AnsibleController instance"
}
# Output the pulic IP address of the EC2 AnsibleCMangedNode instance
output "instance_public_AnsibleManagedNode1_ip" {
  value       = aws_instance.AnsibleManagedNode1.public_ip
  description = "The public IP address of the EC2 AnsibleMN1"
}

# Output the pulic IP address of the EC2 DockerHost instance
output "instance_public_docker_ip" {
  value       = aws_instance.DockerHost.public_ip
  description = "The public IP address of the EC2 DockerHost"
}

# Output the pulic IP address of the EC2 Nexus instance
output "instance_public_nexus_ip" {
  value       = aws_instance.Nexus.public_ip
  description = "The public IP address of the EC2 Nexus"
}
