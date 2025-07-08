variable "ami" {
  default = "ami-020cba7c55df1f615" #ami in ubuntu useast-1
  type    = string

}
variable "instance_type" {
  default = "t2.micro"
  type    = string
}

variable "volume_size" {
  default = 8
  type    = number
}