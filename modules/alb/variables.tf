variable "vpc_id" {
  type        = string
  description = "Id of VPC"
}

variable "name" {
  type        = string
  description = "Name of ALB"
}

variable "subnet_ids" {
  type        = set(string)
  description = "Set of subnet IDs where ALB will be deployed. These subnets must be in the same VPC"
}

variable "security_group_ids" {
  type        = set(string)
  description = "Security group id set used by ALB"
}

variable "target_group_name" {
  type        = string
  description = ""
}

variable "target_type" {
  type        = string
  description = "Specifies the type of target that requests are routed to. Valid values are 'instance' for EC2 instances, 'ip' for direct IP addresses, or 'lambda' for AWS Lambda functions."
}

variable "protocol" {
  type        = string
  description = "The protocol used by ALB. Valid values are 'HTTP' or 'HTTPS'."
  default     = "HTTPS"
}

variable "listen_port" {
  type        = number
  description = "Listening port. 80, 444, 8080 etc..."
  default     = 443
}

variable "target_port" {
  type        = number
  description = "The port on which the target group will receive traffic. This is typically the port on which your application is configured to listen."
  default     = 80
}

variable "is_internal" {
  type        = bool
  description = "Determines if the ALB is internal. Set to true for internal (non-internet-facing) load balancers, false for internet-facing."
  default     = true
}

variable "enable_deletion_protection" {
  type        = bool
  description = "Enables or disables deletion protection on the ALB. When set to true, the ALB cannot be deleted unless this setting is turned off."
  default     = true
}

variable "log_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket where access logs from the ALB are stored. If left empty, logging is disabled."
  default     = ""
}
