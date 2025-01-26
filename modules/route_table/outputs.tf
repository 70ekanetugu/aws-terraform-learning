output "public_id" {
  description = "The unique identifier of the public route table created by this module."
  value       = aws_route_table.public.id
}

output "private_id" {
  description = "The unique identifier of the private route table created by this module."
  value       = aws_route_table.private.id
}
