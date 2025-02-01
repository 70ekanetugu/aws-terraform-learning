output "igw_id" {
  description = "Internet gateway id"
  value       = aws_internet_gateway.igw.id
}

output "subnet_private" {
  description = "Private subnet list"
  value       = aws_subnet.private
}

output "subnet_public" {
  description = "Public subnet list"
  value       = aws_subnet.public
}

output "vpc_arn" {
  description = "ARN of VPC"
  value       = aws_vpc.demo.arn
}

output "vpc_id" {
  description = "Id of VPC"
  value       = aws_vpc.demo.id
}
