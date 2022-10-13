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

variable "endpoint" {
    type = string
    description = "Enter the endpoint to check"
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


resource "aws_instance" "healthcheck" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  user_data = <<EOF

#!/bin/bash
SITE=var.endpoint
SITE_OK_STATUS=("200")
#Email users
NOTIFY_FROM_EMAIL='monitoring@healthcheck.com'
NOTIFY_TO_EMAIL='anmol7209@gmail.com'
RESPONSE=$(wget $SITE --no-check-certificate -S -q -O - 2>&1 | awk '/^  HTTP/{print $2}')
if [ -z "$RESPONSE" ]; then
    RESPONSE="0"
fi
if [[ $RESPONSE = *$SITE_OK_STATUS* ]]; then
    RESPONSE="200"
    STATUS="UP"
else
    STATUS="DOWN"
fi
echo "Site: $SITE is $STATUS"
echo "Site: $SITE" >>/tmp/SiteMonitor.email.tmp
echo "Status: $STATUS" >>/tmp/SiteMonitor.email.tmp
echo "-----Begin: Sending Email Content for Site status--------"
cat /tmp/SiteMonitor.email.tmp
$(mail -a "From: $NOTIFY_FROM_EMAIL" \
    -s "SiteMonitor Notification: $HOST is $STATUS" \
    "$NOTIFY_TO_EMAIL" </tmp/SiteMonitor.email.tmp)
echo "----- End:  Sending Email Content for Site status--------"

EOF
  security_groups = [aws_security_group.healthchecksg.name]
  tags = {
    Name = "Healthcheck"

}


}
resource "aws_security_group" "healthchecksg" {
    name = "Allowing all ports"
    ingress = [ {
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = [ ]
      prefix_list_ids = [ ]
      protocol = "TCP"
      security_groups = [ ]
      self = false
      to_port = 65535
    } ]
    egress = [ {
      cidr_blocks = ["0.0.0.0/0"]
      description = ""
      from_port = 0
      ipv6_cidr_blocks = [ ]
      prefix_list_ids = [ ]
      protocol = "TCP"
      security_groups = [ ]
      self = false
      to_port = 65535
    } ]
}
