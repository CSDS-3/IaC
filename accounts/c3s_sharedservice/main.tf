#C3S-IaC Account C3S_SharedService main.tf - Terraform coding for C3S infrastrcture as code

#======================================================================
#  Header
#======================================================================


provider "aws" {
  region = "us-east-1"
  profile = "358664794210_12hrAdministratorAccess"
}




#======================================================================
#  VPC and Subnets
#======================================================================

module network {
    source    = "../../modules/network" 
    subnet_cidr_block_dmz = "10.0.0.0/24"
    app_abb = "ss"
    create_dmz = true
}


#======================================================================
#  VPC internet_gateway for DMZ 
#======================================================================



resource "aws_internet_gateway" "ss_dmz_igw" {
  vpc_id = module.network.vpc-id

  tags = {
    Name = "ss_dmz_igw"
  }
}


resource "aws_route_table" "ss_vpcmain_rt" {
  vpc_id = "${module.network.vpc-id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ss_dmz_igw.id}"
  }
}


#DMZ subnet assoc to route table
resource "aws_route_table_association" "dmz_rta" {
  subnet_id      = module.network.dmz-sn-id
  route_table_id = aws_route_table.ss_vpcmain_rt.id
}


#======================================================================
# DMZ Security Group 
#======================================================================

resource "aws_security_group" "SharedSevice_DMZ_SG" {
  name        = "SharedSevice_DMZ_SG"
  description = "SharedSevice DMZ Security Group"
  vpc_id      = module.network.vpc-id

  ingress {
    description      = "ICMP from VPC"
    from_port        = -1
    to_port          = -1
    protocol         = "ICMP"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  ingress {
    description      = "windows RDP access"
    from_port        = 3389
    to_port          = 3389
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  tags = {
    Name = "SharedSevice_DMZ_SG"
  }
}



#======================================================================
# private Security Group 
#======================================================================

resource "aws_security_group" "SharedSevice_pri_SG" {
  name        = "SharedSevice_pri_SG"
  description = "SharedSevice Private Security Group"
  vpc_id      = module.network.vpc-id

  ingress {
    description      = "ICMP from VPC"
    from_port        = -1
    to_port          = -1
    protocol         = "ICMP"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }

  ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }


  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }


  ingress {
    description      = "Splunp UI"
    from_port        = 8000
    to_port          = 8000
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }

  ingress {
    description      = "Splunk Internal Comms"
    from_port        = 8089
    to_port          = 8089
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }

  ingress {
    description      = "Indexer Coms"
    from_port        = 9997
    to_port          = 9997
    protocol         = "tcp"
    security_groups = [aws_security_group.SharedSevice_DMZ_SG.id]
    #cidr_blocks      = [network.subnet_cidr_block_dmz]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   }

  tags = {
    Name = "SharedSevice_private_SG"
  }
}

#======================================================================
# Create Bastion TLS key
#======================================================================

module tlskey {
  source = "../../modules/tlskey"
  key_name = "C3S_key"
  pass_acc_abb = var.app_abb
}


#======================================================================
# Bastion Instance in DMZ
#======================================================================

resource "aws_instance" "bastion" {
  ami                              = "ami-0b5eea76982371e91"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = true
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.dmz-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_DMZ_SG.id]


  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "Bastion host"
    Project = "C3S"
  }
}


#======================================================================
# Bastion Windows Instance in DMZ
#======================================================================

resource "aws_instance" "bastion_win" {
  ami                              = "ami-03cf1a25c0360a382"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = true
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.dmz-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_DMZ_SG.id]


  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

  tags = {
    Name    = "Bastion_windows host"
    Project = "C3S"
  }
}



#======================================================================
# Master Loging bucket and Cloudtrail
#======================================================================

module cloudtrail_s3 {
  source = "../../modules/cloudtrail_s3"
}


#======================================================================
# Three vms in private subnet
#======================================================================


variable "mv_machings_forw" {
  type    = list
  default = ["Heavy_Forwarder", "Search_Head"]
}

resource "aws_instance" "splunk_vm_forw" {
  count = 2
  ami                              = "ami-0b5eea76982371e91"
  instance_type                    = "c4.2xlarge"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

 
  tags = {
    Name    = var.mv_machings_forw[count.index]
    Project = "C3S"
  }
}




resource "aws_instance" "splunk_vm_index" {
  ami                              = "ami-0b5eea76982371e91"
  instance_type                    = "m4.4xlarge"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

 
  tags = {
    Name    = "Splunk Indexer"
    Project = "C3S"
  }
}


#======================================================================
# Three vms in private subnet - "Ansible", "Scanning","Snipe_It"
#======================================================================




resource "aws_instance" "pri_app_vm_snipe" {
  ami                              = "ami-0aedf6b1cb669b4c7"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

 
  tags = {
    Name    = "Snipe_It"
    Project = "C3S"
  }
}

resource "aws_instance" "pri_app_vm_ansible" {
  ami                              = "ami-06640050dc3f556bb"
  instance_type                    = "t2.micro"
  associate_public_ip_address      = false
  key_name                         = module.tlskey.public_key_name
  monitoring                       = true
  subnet_id                        = module.network.pri-sn-id
  vpc_security_group_ids           = [aws_security_group.SharedSevice_pri_SG.id]
  

  root_block_device {
    volume_size           = "50"
    delete_on_termination = true
    encrypted             = true 
  }

  lifecycle {
    ignore_changes = [ami]
  }

 
  tags = {
    Name    = "Ansible"
    Project = "C3S"
  }
}