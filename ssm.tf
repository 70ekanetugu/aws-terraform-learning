resource "aws_ssm_parameter" "db_username" {
  name        = "/demo/db_username"
  value       = "root"
  type        = "String"
  description = "DBユーザー名"
}
resource "aws_ssm_parameter" "db_password" {
  name        = "/demo/db_password"
  value       = "RawPassword"
  type        = "SecureString"
  description = "DBパスワード"

  lifecycle {
    ignore_changes = [value]
  }
}
