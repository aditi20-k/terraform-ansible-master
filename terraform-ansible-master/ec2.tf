# Key Pair
resource "aws_key_pair" "my_key_new" {
  key_name   = "terra-key-ansible"
  public_key = file("terra-key-ansible.pub")
}

# Default VPC
resource "aws_default_vpc" "default" {
}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
  description = "Terraform generated Security Group"
  vpc_id      = aws_default_vpc.default.id

  # Inbound - SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH open"
  }

  # Inbound - HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP open"
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound access"
  }

  tags = {
    Name = "automate-sg"
  }
}

# EC2 Instances
resource "aws_instance" "my_instance" {
  for_each = {
    TWS-Junoon-Master = "ami-033afab6c0b6982cf"
    TWS-Junoon-1      = "ami-05401e1394491333f"
    TWS-Junoon-2      = "ami-05401e1394491333f"
    TWS-Junoon-3      = "ami-03d7696ffeb1b45cc"
  }

  depends_on = [
    aws_security_group.my_security_group,
    aws_key_pair.my_key_new
  ]

  key_name        = aws_key_pair.my_key_new.key_name
  security_groups = [aws_security_group.my_security_group.name]

  instance_type = "t3.micro"
  ami           = each.value

  root_block_device {
    volume_size = 10
    volume_type = "gp3"
  }

  tags = {
    Name = each.key
  }
}