# key pair for login
resource "aws_key_pair" "keypair_to_login" {
  key_name = "terraformwithvar"
  public_key = file("terraformwithvar.pub")
}

# vpc
resource "aws_default_vpc" "default_vpc" {
  
}

# security group
resource "aws_security_group" "ec2securitygroup" {
    name = "automation sg"
    description = "automation_Sg"
    vpc_id = aws_default_vpc.default_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
        description = "allow ssh"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
        description = "allow ssh"
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = [ "::/0" ]
        description = "open outbout for all"
    }
  
}

resource "aws_instance" "ec2instance" {
  key_name = aws_key_pair.keypair_to_login.key_name
  security_groups = [ aws_security_group.ec2securitygroup.name ]
  instance_type = var.ec2_instance_type
  ami = var.ec2_ami
  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = "gp3"
  }
  tags = {
    Name = "Terraform"
  }
}