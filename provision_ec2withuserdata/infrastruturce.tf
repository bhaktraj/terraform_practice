# key_pair for login

resource "aws_key_pair" "key_pair" {
    key_name = "terraformkey"
    public_key = file("terraformkey.pub")
  
}

# create VPC

resource aws_default_vpc "awsvpc" {

}

# security group 

resource "aws_security_group" "awssecuritygroup" {
    name = "automation SG"
    description = "automation SG"
    vpc_id = aws_default_vpc.awsvpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "allow ssh"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "allow http"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = ["::/0"]
        description = "allow all outbound"
    }
  
}

# create instance

resource "aws_instance" "ec2instance" {
    key_name = aws_key_pair.key_pair.key_name
    instance_type = var.ec2_instance_type
    ami = var.ec2_ami
    security_groups = [ aws_security_group.awssecuritygroup.name ]
    user_data = file("install_niginx.sh")

    root_block_device {
      volume_size = var.ec2_instance_size
      volume_type = "gp3"
    }

  
}

######### output #########

output "aws_public_ip" {
    value = aws_instance.ec2instance.public_ip
  
}
output "aws_public_dns" {
    value = aws_instance.ec2instance.public_dns
}