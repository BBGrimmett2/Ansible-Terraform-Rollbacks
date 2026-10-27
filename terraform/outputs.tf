output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.demo_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.demo_vpc.cidr_block
}

output "subnet_id" {
  description = "ID of the created subnet"
  value       = aws_subnet.demo_subnet.id
}

output "subnet_cidr" {
  description = "CIDR block of the subnet"
  value       = aws_subnet.demo_subnet.cidr_block
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.demo_sg.id
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.demo_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.demo_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.demo_instance.public_dns
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.demo_instance.private_ip
}

output "availability_zone" {
  description = "Availability zone where resources are deployed"
  value       = aws_subnet.demo_subnet.availability_zone
}
