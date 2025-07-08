resource "aws_default_vpc" "vpc" {
}

resource "aws_key_pair" "key_pair" {
  key_name   = "ansible"
  public_key = file("ansible.pub")
}

resource "aws_security_group" "ansible_Sg" {
  name        = "ansible_Sg"
  description = "ansible_sg"
  vpc_id      = aws_default_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow ssh"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "allow for all in outbound rule"

  }

}

resource "aws_instance" "ec2instance" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key_pair.key_name
  security_groups = [aws_security_group.ansible_Sg.name]
  user_data       = file("ansible_install.sh")
  count = 4
  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

}