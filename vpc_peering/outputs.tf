output "bastion_ec2_instance_id" {
  description = "Bastion EC2 instance ID"
  value       = aws_instance.bastion.id
}

output "ec2_instance_dns" {
  description = "EC2 instance ID"
  value       = aws_instance.acceptor.private_dns
}

output "ec2_ssh_public_key" {
  description = "EC2 SSH public key"
  value       = tls_private_key.rsa.public_key_pem
}

output "postgres_endpoint" {
  description = "PostgreSQL instance endpoint"
  value       = aws_db_instance.psql.endpoint
}

output "mysql_endpoint" {
  description = "MySQL cluster endpoint"
  value       = aws_rds_cluster.mysql.endpoint
}
