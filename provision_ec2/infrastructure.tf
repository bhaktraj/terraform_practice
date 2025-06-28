# key pair for connection 
resource "aws_key_pair" "key_pair" {
    key_name = "terraform_keypair"
    public_key = file("terraform_keypair.pub")
  
}

#vpc and security_group

resource "aws_default_vpc" "default_vpc" {

}

resource "aws_security_group" "ec2securitygroup" {
    name = "sgbyterraform"
    description = "sgdecription"
    vpc_id = aws_default_vpc.default_vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "allow ssh"
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = -1
        cidr_blocks = [ "0.0.0.0/0" ]
        ipv6_cidr_blocks = ["::/0"]
        description = "all outbond open"
    }
  
}

# ec2 instance
resource "aws_instance" "ec2instance" {
    key_name = aws_key_pair.key_pair.key_name
    security_groups = [aws_security_group.ec2securitygroup.name]
    instance_type = "t2.micro"
    ami = "ami-0f918f7e67a3323f0"

    root_block_device {
      volume_size = 8
      volume_type = "gp3"
    }

    tags = {
      Name = "terraform first"
    }
  
}
