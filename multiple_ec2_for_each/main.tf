resource "aws_key_pair" "my_key_pair" {
    key_name = "multiple_ec2"
    public_key = file("multiple_ec2.pub")
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_security_group" "multiple_sg" {
    vpc_id = aws_default_vpc.default.id
    name = "multiple_sg"
    description = "multiple_sg"
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
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow all outbound rule"
    }

  
}

resource "aws_instance" "multiple_instance" {
    for_each = tomap({
        instancemicro = "t2.micro"
        instancemini = "t2.medium"
    })
    key_name = aws_key_pair.my_key_pair.key_name
    ami = "ami-020cba7c55df1f615"
    instance_type = each.value
    security_groups = [ aws_security_group.multiple_sg.name ]
    root_block_device {
      volume_size = 8
      volume_type = "gp3"
    }
    tags = {
      Name = each.key
    }
  
}

output "public_ip" {
    value = [
        for key in aws_instance.multiple_instance : key.public_ip
    ]
  
}