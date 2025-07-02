resource "aws_key_pair" "my_key_pair" {
  key_name   = "multiple_ec2"
  public_key = file("multiple_ec2.pub")

}
resource "aws_default_vpc" "default" {


}
resource "aws_security_group" "multiple_ec2_SG" {
  vpc_id      = aws_default_vpc.default.id
  name        = "multiple_ec2_sg"
  description = "multiple_ec2_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbond route"
  }

}
resource "aws_instance" "ec2_instance" {
  ami             = "ami-020cba7c55df1f615"
  instance_type   = "t2.micro"
  count           = 3
  key_name        = aws_key_pair.my_key_pair.key_name
  security_groups = [aws_security_group.multiple_ec2_SG.name]

  root_block_device {
    volume_size = 8
    volume_type = "gp3"

  }

}

output "ec2_public_id" {
  value = aws_instance.ec2_instance[*].public_ip

}