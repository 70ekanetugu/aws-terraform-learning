output "ids" {
  value = { for i, v in aws_subnet.default.*.id : i => v }
}
