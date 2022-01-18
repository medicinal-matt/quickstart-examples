variable "prefix" {
  description = "Will be prefixed to all resource names. Use to easily identify the resources created"
  type        = string
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket events will be loaded into"
  type        = string
}

variable "s3_bucket_deploy" {
  description = "Whether this module should create a new bucket with the specified name - if the bucket already exists set this to false"
  type        = bool
  default     = true
}

variable "s3_bucket_object_prefix" {
  description = "An optional prefix under which Snowplow data will be saved (Note: your prefix must end with a trailing '/')"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "The VPC to deploy the components within"
  type        = string
}

variable "public_subnet_ids" {
  description = "The list of public subnets to deploy the components across"
  type        = list(string)
}

variable "ssh_public_key" {
  description = "The SSH public key to use for the deployment"
  type        = string
}

variable "ssh_ip_allowlist" {
  description = "The list of CIDR ranges to allow SSH traffic from"
  type        = list(any)
}

variable "iglu_server_dns_name" {
  description = "The DNS name of your Iglu Server"
  type        = string
}

variable "iglu_super_api_key" {
  description = "A UUIDv4 string to use as the master API key for Iglu Server management"
  type        = string
  sensitive   = true
}

variable "pipeline_kcl_write_max_capacity" {
  description = "Increasing this is important to increase throughput at very high pipeline volumes"
  type        = number
  default     = 50
}

variable "telemetry_enabled" {
  description = "Whether or not to send telemetry information back to Snowplow Analytics Ltd"
  type        = bool
  default     = true
}

variable "user_provided_id" {
  description = "An optional unique identifier to identify the telemetry events emitted by this stack"
  default     = ""
  type        = string
}

variable "iam_permissions_boundary" {
  description = "The permissions boundary ARN to set on IAM roles created"
  default     = ""
  type        = string
}

variable "ssl_information" {
  description = "The ARN of an Amazon Certificate Manager certificate to bind to the load balancer"
  type = object({
    enabled         = bool
    certificate_arn = string
  })
  default = {
    certificate_arn = ""
    enabled         = false
  }
}

variable "tags" {
  description = "The tags to append to the resources in this module"
  default     = {}
  type        = map(string)
}

variable "cloudwatch_logs_enabled" {
  description = "Whether application logs should be reported to CloudWatch"
  default     = true
  type        = bool
}

variable "cloudwatch_logs_retention_days" {
  description = "The length of time in days to retain logs for"
  default     = 7
  type        = number
}

variable "sf_operator_username" {
  description = "Snowflake username to pass Snowflake TF provider"
  type        = string
}

variable "sf_account" {
  description = "Snowflake account to use"
  type        = string
}

variable "sf_region" {
  description = "Region of Snowflake account"
  type        = string
}

variable "sf_operator_user_role" {
  description = "Snowflake user role to pass Snowflake TF provider"
  type        = string
}

variable "sf_private_key_path" {
  description = "Private key for accessing Snowflake"
  type        = string
}

variable "sf_db_name" {
  description = "The name of the database to connect to"
  type        = string
}

variable "sf_wh_name" {
  description = "The name of the Snowflake warehouse to connect to"
  type        = string
}

variable "sf_loader_password" {
  description = "The password to use to connect to the database"
  type        = string
  sensitive   = true
}

variable "shredder_window_period" {
  description = "Frequency to emit shredding finished message - 5,10,15,20,30,60 etc minutes"
  type        = string
  default     = "5 minutes"
}
