#C3S-IaC Module Network main.tf - Terraform coding for C3S infrastrcture as code

terraform {
	required_version = ">= 1.3.7"
}

resource "aws_vpc" "main"{
	cidr_block = var.vpc_cidr_block

	tags = {
    		Name = "C3S-${var.app_abb}-vpc" 
  }
}


resource "aws_subnet" "private_subnet" {
	vpc_id     = aws_vpc.main.id
	cidr_block = var.subnet_cidr_block_private
	tags = {
    		Name = "private Subnet"
  }
}


resource "aws_subnet" "dmz_subnet" {
	count = var.create_dmz? 1 : 0
	vpc_id     = aws_vpc.main.id
	cidr_block = var.subnet_cidr_block_dmz
	tags = {
    		Name = "public (DMZ) Subnet"
	}		

  }


 
