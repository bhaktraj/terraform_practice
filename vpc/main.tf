############### create a vpc ###################

resource "aws_vpc" "new_vpc" {
    tags = {
      Name = "Self_create_vpc"
    }
    cidr_block = "195.0.0.0/27"
    instance_tenancy = "default"
    enable_dns_support   = true                # Enable internal DNS resolution
    enable_dns_hostnames = true                # Enable public DNS names for instances
}

############## Create Subnet ####################
############## South Subnet  ####################

resource "aws_subnet" "bhakt_south" {
    vpc_id = aws_vpc.new_vpc.id
    tags = {
      Name = "bhakt_south"
    }
    cidr_block = "195.0.0.0/28"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
}

############### North Subnet #####################

resource "aws_subnet" "bhakt_north" {
    vpc_id = aws_vpc.new_vpc.id
    tags = {
      Name = "bhakt_north"
    }
    cidr_block = "195.0.0.16/28"
    availability_zone = "us-east-1b"
}

##################### Create Route table for private communication ####################

resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.new_vpc.id
    tags = {
      Name = "private_route_table"
    }
}
############################## add subnet to private route table ############################
resource "aws_route_table_association" "private_route" {
    subnet_id = aws_subnet.bhakt_north.id
    route_table_id = aws_route_table.private_route.id
  
}

############################ Create Internet Gateway #########################################
resource "aws_internet_gateway" "public_route" {
    tags = {
      Name = "Public_path"
    }
    vpc_id = aws_vpc.new_vpc.id
}

######################### Create Public Route table ###################################

resource "aws_route_table" "public_route" {
    vpc_id = aws_vpc.new_vpc.id
    tags = {
      Name = "Public_route_table"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.public_route.id
    }
  
}

################################# add public subnet to Public Route Table ###################################

resource "aws_route_table_association" "public_route" {
    subnet_id = aws_subnet.bhakt_south.id
    route_table_id = aws_route_table.public_route.id
  
}

################################ Add or Create instance in this VPC one in public and one in private ###############################

########## Key pair for login ############

resource "aws_key_pair" "key_pair" {
    key_name = "terraformvpckey"
    public_key = file("terraformvpckey.pub")
}

############# Security Group ####################

resource "aws_security_group" "public_instance_SG" {
    vpc_id = aws_vpc.new_vpc.id
    name = "publicSG"
    description = "PublicSG"
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "ssh allow"
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "http allow"

    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [ "0.0.0.0/0" ]
        description = "outbound allow for all"
    }
  
}

############# EC2 instance Create for public #################3
resource "aws_instance" "public_instance" {
    key_name = aws_key_pair.key_pair.key_name
    ami = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.bhakt_south.id
    security_groups = [aws_security_group.public_instance_SG.id]
    user_data = file("install_niginx.sh")
    root_block_device {
      volume_size = 8
      volume_type = "gp3"
    }
    tags = {
      Name = "Public_instance"
    }

}

resource "aws_instance" "private_instance" {
    key_name = aws_key_pair.key_pair.key_name
    ami = "ami-020cba7c55df1f615"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.bhakt_north.id
    security_groups = [aws_security_group.public_instance_SG.id]
    root_block_device {
      volume_size = 8
      volume_type = "gp3"
    }   
    tags = {
      Name = "Private instance"
    }
}