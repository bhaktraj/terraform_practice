variable "ec2_instance_type" {
    default = "t2.micro"
    type = string
  
}

variable "ec2_ami" {
    default = "ami-020cba7c55df1f615"
    type = string
  
}

variable "ec2_volume_size" {
    default = 8
    type = number
  
}