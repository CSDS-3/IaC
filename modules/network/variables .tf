#C3S-IaC Module Network variables.tf - Terraform coding for C3S infrastrcture as code

variable "create_dmz"{
	type = bool
	default = false
}	


variable "vpc_cidr_block" {
	type = string
	default = "10.0.0.0/23"
}	


variable "subnet_cidr_block_private"  {
	type = string
	default = "10.0.1.0/24"
}	


variable "subnet_cidr_block_dmz" {
	type = string
	default = ""
}	



variable "vpc_name" {
	type = string
	default = "C3S_ShareService_VPC"
}	

variable "app_abb"{
	type = string
}	

