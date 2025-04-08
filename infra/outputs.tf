output "vpc" {
  description = "VPC"
  value       = aws_vpc.vpc.id
}

output "private-subnets" {
  description = "private-subnets"
  value       = [for k, v in aws_subnet.private-subnet : v.id]
}

output "public-subnets" {
  description = "public-subnets"
  value       = [for k, v in aws_subnet.public-subnet : v.id]
}

output "security_group_id_web" {
  description = "Security Group Id WEB"
  value       = aws_security_group.allow_web
}