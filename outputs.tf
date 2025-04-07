output "private-subnet-1a" {
  description = "private-subnet-1a"
  value       = aws_subnet.private-subnet-1a.id
}

output "private-subnet-1b" {
  description = "private-subnet-1b"
  value       = aws_subnet.private-subnet-1b.id
}
output "public-subnet-1a" {
  description = "public-subnet-1a"
  value       = aws_subnet.public-subnet-1a.id
}

output "public-subnet-1b" {
  description = "public-subnet-1b"
  value       = aws_subnet.public-subnet-1b.id
}

output "security_group_id_web" {
  description = "Security Group Id WEB"
  value       = aws_security_group.allow_web
}