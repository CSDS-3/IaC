#C3S-IaC Module tlskey variables.tf - Terraform coding for C3S infrastrcture as code

variable "key_name" {
   	type = string 
    default = "C3S_key"
}

variable "pass_acc_abb" {
   	type = string 
}
