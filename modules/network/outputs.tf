#C3S-IaC Module Network output.tf - Terraform coding for C3S infrastrcture as code

output "vpc-id" {
  value = aws_vpc.main.id
}

output "vpc-cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "pri-sn-cidr_block" {
  value = aws_subnet.private_subnet.cidr_block
}


output "pri-sn-id" {
  value = aws_subnet.private_subnet.id
}


output "dmz-sn-cidr_block" {
  value="${var.create_dmz ? aws_subnet.dmz_subnet[0].cidr_block : ""}" 
}

output "dmz-sn-id" {
  value="${var.create_dmz ? aws_subnet.dmz_subnet[0].id : ""}" 
}


