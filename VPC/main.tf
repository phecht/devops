terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
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

# Output the pulic IP address of the EC2 instance
output "instance_public_ip" {
  value       = aws_instance.Jenkins.public_ip
  description = "The public IP address of the EC2 instance"
}
