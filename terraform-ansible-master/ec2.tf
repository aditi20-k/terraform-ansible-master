# =========================================================
# KEY PAIR
# =========================================================

resource "aws_key_pair" "my_key_new" {
  key_name   = "terra-key-ansible"
  public_key = file("${path.module}/terra-key-ansible.pub")
}


# =========================================================
# DEFAULT VPC
# =========================================================

resource "aws_default_vpc" "default" {
}


# =========================================================
# SECURITY GROUP
# =========================================================

resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "Terraform generated Security Group"
  vpc_id      = aws_default_vpc.default.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS access"
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "automate-sg"
  }
}


# =========================================================
# EC2 INSTANCES
# =========================================================

resource "aws_instance" "my_instance" {

  for_each = {
    TWS-Junoon-Master = "ami-0aba19e56f3eaec05"
    TWS-Junoon-1      = "ami-0aba19e56f3eaec05"
    TWS-Junoon-2      = "ami-07ba4be829b9bf20a"
    TWS-Junoon-3      = "ami-06cfeaaa22092f09d"
  }

  ami           = each.value
  instance_type = "t3.micro"

  # Terraform-created key pair
  key_name = aws_key_pair.my_key_new.key_name

  # Security Group
  security_groups = [
    aws_security_group.my_security_group.name
  ]

  # Root disk
  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }
}