#C3S-IaC Account C3S_Application main.tf - Terraform coding for C3S infrastrcture as code
#======================================================================
#  Header
#======================================================================


provider "aws" {
  region = "us-west-1"
  profile = "302071135337_12hrAdministratorAccess"
}




#======================================================================
#  VPC and Subnets
#======================================================================

module network {
    source    = "../../modules/network" 
    subnet_cidr_block_private = var.subnet_cidr_block_private
    subnet_cidr_block_dmz ="10.0.3.0/24"
    app_abb = "app"
    create_dmz = true
    vpc_cidr_block="10.0.2.0/23" 
}


resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  vpc_id     = module.network.vpc-id
  cidr_block = "100.192.8.0/25"
}

resource "aws_subnet" "private_subnet" {
	vpc_id     = module.network.vpc-id
	cidr_block = "100.192.8.0/25"
  availability_zone = "us-east-1a"
	tags = {
    		Name = "Secondary Subnet"
  }
}


#======================================================================
# private Security Group 
#======================================================================

resource "aws_security_group" "Application_pri_SG" {
  name        = "Application_pri_SG"
  description = "Application Private Security Group"
  vpc_id      = module.network.vpc-id

  ingress {
    description      = "ICMP from VPC"
    from_port        = -1
    to_port          = -1
    protocol         = "ICMP"
    cidr_blocks      = ["10.0.0.0/23", "10.0.2.0/23"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/23", "10.0.2.0/23"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/23", "10.0.2.0/23"]
  }


  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["10.0.0.0/23", "10.0.2.0/23"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  tags = {
    Name = "Application_private_SG"
  }
}

#======================================================================
# Create Application TLS key
#======================================================================

module tlskey {
  source = "../../modules/tlskey"
  key_name = "Application_key"
  pass_acc_abb = var.app_abb
}

#======================================================================
# Application Instance in Private Subnet (2 linux)
#======================================================================

resource "aws_instance" "App_linux" {
  count                            = var.vm_count  
  ami                              = "ami-0aa7d40eeae50c9a9"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.Application_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "Application host Linux"
    Project = "C3S"
  }
}

#======================================================================
# Application Instance in Private Subnet (2 windows)
#======================================================================

resource "aws_instance" "App_window" {
  count                            = var.vm_count  
  ami                              = "ami-03cf1a25c0360a382"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.Application_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "Application host Windows"
    Project = "C3S"
  }
}
#======================================================================
# Application Instance in Private Subnet (2 MAC)
#======================================================================

resource "aws_instance" "App_mac" {
  count                            = var.vm_count  
  ami                              = "ami-00805552fa999b1a0"
  instance_type                    = "mac1.metal"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = aws_subnet.private_subnet.id
  vpc_security_group_ids           = [aws_security_group.Application_pri_SG.id]
  

  root_block_device {
    volume_size           = "100"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "Application Host MAC-OS"
    Project = "C3S"
  }
}
