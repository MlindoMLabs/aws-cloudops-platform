output "instance_id" {
  description = "ID of the launched EC2 instance"
  value       = aws_instance.app_node.id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_node.public_ip
}

output "security_group_id" {
  description = "Security Group ID attached to EC2"
  value       = aws_security_group.ec2_sg.id
}

output "iam_instance_profile_name" {
  description = "Name of the IAM Instance Profile attached to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}
