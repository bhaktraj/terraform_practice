##################### output of public ip instance ######################################
output "public_instance_ip_publicip" {
    value = aws_instance.public_instance.public_ip 
}

##################### Output of public instance private ip ##############################
output "public_instance_privateip" {
    value = aws_instance.public_instance.private_ip
}
##################### Output of public instance dns #####################################
output "public_instance_dns" {
    value = aws_instance.public_instance.public_dns
}

#################### Output of Private instance Ip #######################################

output "private_instance_ip_privateip" {
    value = aws_instance.private_instance.private_ip
  
}