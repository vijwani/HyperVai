variable "access_keyvalue" {
    type = string
    description = "Please type your AWS access key "  
}
variable "secret_keyvalue" {
    type = string
    description = "Please type your AWS secret key "  
}
variable "regionvalue" {
    type = string
    description = "Please type which region need to deploy "
}

variable "ingressrules" {
  type = list(number)
  default = [22,80,443] 
}

variable "egressrules" {
  type = list(number)
  default = [22,80,443] 
}

provider "aws" {
    region = var.regionvalue
    access_key = var.access_keyvalue
    secret_key = var.secret_keyvalue
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

resource "aws_instance" "staticweb" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = file("server-script.sh")
  security_groups = [aws_security_group.mysecurity.name]
  tags = {
    Name = "Staticwebpage"
  }
}

resource "aws_security_group" "mysecurity" {
  name = "Allow HTTP/HTTPS"
  dynamic "ingress" {
    iterator = port 
    for_each = var.ingressrules
    content {
    description = ""
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = port.value
    to_port     = port.value
    }  
  }
  dynamic "egress" {
    iterator = port 
    for_each = var.egressrules
    content {
    description = ""
    ipv6_cidr_blocks = []
    prefix_list_ids = []
    security_groups = []
    self = false
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = port.value
    to_port     = port.value
    }
}
}



