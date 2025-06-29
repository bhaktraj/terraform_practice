output "aws_public_ip" {
    value = aws_instance.ec2instance.public_ip
  
}
output "aws_public_dns" {
    value = aws_instance.ec2instance.public_dns
}
output "aws_private_ip" {
    value = aws_instance.ec2instance.private_ip
}
output "aws_private_dns" {
    value = aws_instance.ec2instance.private_dns
}