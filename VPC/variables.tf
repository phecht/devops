variable "aws_region" {
  type    = string
  default = "us-west-1"
}
variable "cidr_block" {
  type    = list(string)
  default = ["172.20.0.0/16", "172.20.10.0/24"]
}

variable "ports" {
  type    = list(number)
  default = [22, 80, 443, 8080, 8081]
}

variable "ami" {
  type    = string
  default = "ami-051ed863837a0b1b6" // ami-0b0f4c27376f8aa79 ami-04e914639d0cca79a ami-051ed863837a0b1b6
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_type_for_nexus" {
  type    = string
  default = "t2.medium"
}

variable "instance_key_name" {
  type    = string
  default = "udemy_ec2"
}

