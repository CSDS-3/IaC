#C3S-IaC Account C3S_Application variables.tf - Terraform coding for C3S infrastrcture as code


variable "subnet_cidr_block_private"  {
	type = string
	default = "10.0.2.0/24"
}	

variable "subnet_cidr_block_ingress"  {
	type = list
    description = "allowed ingress cidr"
	default = ["10.0.0.0/24", "10.0.4.0/24"]
}	
variable "vm_count" {
  description = "Number of Virtual Machines"
  default     = 2
  type        = string
}
variable "app_abb"{
	type = string
	default = "app"
}	