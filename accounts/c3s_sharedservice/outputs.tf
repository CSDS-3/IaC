#C3S-IaC Account C3S_SharedService output.tf - Terraform coding for C3S infrastrcture as code
output "routerTable" {
  value = aws_route_table_association.dmz_rta
}
