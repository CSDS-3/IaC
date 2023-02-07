#C3S-IaC Module tlskey main.tf - Terraform coding for C3S infrastrcture as code
#======================================================================
#  Create Key Pair
#======================================================================
resource "tls_private_key" "tls_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.tls_key_pair.public_key_openssh
}

# write to file 
resource "local_file" "private_key_file" {
  filename = "C:/Users/ThomasRando/.ssh/${var.key_name}.pem"
  content  = tls_private_key.tls_key_pair.private_key_pem
}

#======================================================================
#  put key pairs in s3
#======================================================================


