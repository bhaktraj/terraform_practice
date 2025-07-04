################# Create vpc ####################

resource "aws_vpc" "vpc_with_security" {
  cidr_block = "195.0.0.0/26"
  tags = {
    Name = "vpc_with_security"
  }
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

################# Subnet ################
############# Public Subnet #############

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.vpc_with_security.id
  cidr_block        = "195.0.0.0/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Public_subnet1"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.vpc_with_security.id
  cidr_block        = "195.0.0.16/28"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Public_subnet2"
  }
}

################## Private Subnet ###################

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.vpc_with_security.id
  cidr_block        = "195.0.0.32/28"
  availability_zone = "us-east-1a"
  tags = {
    Name = "Private_subnet1"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id            = aws_vpc.vpc_with_security.id
  cidr_block        = "195.0.0.48/28"
  availability_zone = "us-east-1b"
  tags = {
    Name = "Private_subnet2"
  }
}

############# Internet Gateway ################

resource "aws_internet_gateway" "public_routing" {
  tags = {
    Name = "public_internet_gateway"
  }
  vpc_id = aws_vpc.vpc_with_security.id
}

############# Route table for Private Connection #################

resource "aws_route_table" "private_route_table" {
  tags = {
    Name = "private_route_table"
  }
  vpc_id = aws_vpc.vpc_with_security.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
  depends_on = [aws_nat_gateway.nat_gateway]
}

############# Route table for Public Connetion ###################
############ Internet gateway connect to public subnet ###########

resource "aws_route_table" "public_route_table" {
  tags = {
    Name = "public_route_table"
  }
  vpc_id = aws_vpc.vpc_with_security.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_routing.id
  }
}

########## Route table associaton for private subnet ################

resource "aws_route_table_association" "private_table" {
  for_each = tomap({
    private_subnet1 = aws_subnet.private_subnet.id
    Private_subnet2 = aws_subnet.private_subnet1.id

  })
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}

########### Route table association for public subnet ###############

resource "aws_route_table_association" "public_table" {
  for_each = tomap({
    public_subnet1 = aws_subnet.public_subnet.id
    Public_subnet2 = aws_subnet.public_subnet1.id

  })
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}

################ Elastic Ip for NAT Gateway ###############
resource "aws_eip" "elastic_ip" {
  tags = {
    Name = "Nat_Gateway_elastic_ip"
  }
}

################### Associate NAT-Gateway #################

resource "aws_nat_gateway" "nat_gateway" {
  subnet_id     = aws_subnet.public_subnet.id
  allocation_id = aws_eip.elastic_ip.id

  tags = {
    Name = "Nat_gateway"
  }

}

################### NACL Rule #####################

resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc_with_security.id
  tags = {
    Name = "Nacl_rule",
  }
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0

  }
}
################### NACL Subnet association #######################

resource "aws_network_acl_association" "nacl_association" {
  network_acl_id = aws_network_acl.nacl.id
  for_each = tomap({
    public_subnet  = aws_subnet.public_subnet.id
    private_subnet = aws_subnet.private_subnet.id
  })
  subnet_id = each.value
}

###########################################################################
########################## EC2 instance Create ############################
###########################################################################

############################# Key pair ####################################

resource "aws_key_pair" "my_key_pair" {
  key_name   = "securitykeypair"
  public_key = file("securitykeypair.pub")
}

########################### Security Key pair #############################
resource "aws_security_group" "instance_sg" {
  name        = "instance_sg"
  description = "instance_sg"
  vpc_id      = aws_vpc.vpc_with_security.id

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
    description = "allow all outbond rule"
  }

}

########################## EC2 instance ########################

resource "aws_instance" "aws_ec2_instance" {
  for_each = tomap({
    public  = aws_subnet.public_subnet.id
    private = aws_subnet.private_subnet.id
  })
  instance_type   = "t2.micro"
  ami             = "ami-020cba7c55df1f615"
  subnet_id       = each.value
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.instance_sg.name]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
  tags = {
    Name = "EC2_${each.key}"
  }

}