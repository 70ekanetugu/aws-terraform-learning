output "ids" {
  description = "Map of Created subnet ids. Key is index, Value is subnet id. "
  value       = { for i, v in aws_subnet.default.*.id : i => v }
}
