resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = lower("rsa-key-${local.identifier}")
  public_key = tls_private_key.key.public_key_openssh

  tags = {
    environment   = lower(var.environment)
    application   = lower(var.application)
    cost-center   = lower(var.cost-center)
    deployed-by   = lower(var.deployed-by)
  }
}

resource "aws_secretsmanager_secret" "secret" {
  name = lower("rsa-pk-${local.identifier}")
  description = "Private Key for ${var.application} EC2 in ${var.environment} environment"
}

resource "aws_secretsmanager_secret_version" "access_key" {
  secret_id     = aws_secretsmanager_secret.secret.id
  secret_string = base64encode(tls_private_key.key.private_key_pem)
}