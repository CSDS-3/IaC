#C3S-IaC Module tlskey output.tf - Terraform coding for C3S infrastrcture as code

output "private_key" {
  value     = tls_private_key.tls_key_pair.private_key_pem
  sensitive = true
}

output "public_key_name" {
  value     = aws_key_pair.generated_key.key_name
  sensitive = true
}
