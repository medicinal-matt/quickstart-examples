provider "snowflake" {
  username = var.sf_operator_username
  account  = var.sf_account
  region   = var.sf_region
  role     = var.sf_operator_user_role
  private_key_path = var.sf_private_key_path
}

resource "aws_sqs_queue" "message_queue" {
  content_based_deduplication = true
  name                        = "${var.prefix}-sf-loader.fifo"
  fifo_queue                  = true
  kms_master_key_id           = "alias/aws/sqs"
}

module "common" {
  source = "../common"

  prefix = var.prefix
  vpc_id = var.vpc_id
  public_subnet_ids = var.public_subnet_ids

  s3_bucket_name = var.s3_bucket_name
  s3_bucket_deploy = var.s3_bucket_deploy
  s3_bucket_object_prefix = var.s3_bucket_object_prefix

  ssh_public_key = var.ssh_public_key
  ssh_ip_allowlist = var.ssh_ip_allowlist

  iglu_server_dns_name = var.iglu_server_dns_name
  iglu_super_api_key = var.iglu_super_api_key

  pipeline_kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  telemetry_enabled = var.telemetry_enabled
  user_provided_id  = var.user_provided_id
  
  iam_permissions_boundary = var.iam_permissions_boundary
  
  ssl_information = var.ssl_information
  
  tags = var.tags
  
  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_retention_days = var.cloudwatch_logs_retention_days
}

module "stream_shredder_enriched" {
  source = "../../../../../../terraform-aws-stream-shredder-kinesis-ec2"

  name = "${var.prefix}-stream-shredder-enriched-server"
  vpc_id = var.vpc_id
  subnet_ids = var.public_subnet_ids

  ssh_key_name     = module.common.ssh_key_name
  ssh_ip_allowlist = var.ssh_ip_allowlist

  stream_name             = module.common.enriched_stream_name
  s3_bucket_name          = var.s3_bucket_name
  s3_bucket_object_prefix = "${var.s3_bucket_object_prefix}transformed/good"
  window_period           = var.shredder_window_period
  sqs_queue_name          = aws_sqs_queue.message_queue.name
  format_type             = "widerow"

  custom_iglu_resolvers = module.common.custom_iglu_resolvers

  kcl_write_max_capacity = var.pipeline_kcl_write_max_capacity

  iam_permissions_boundary = var.iam_permissions_boundary

  telemetry_enabled = var.telemetry_enabled
  user_provided_id  = var.user_provided_id

  tags = var.tags

  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_retention_days = var.cloudwatch_logs_retention_days
}

module "snowflake_loader" {
  # TODO: Change source when Snowflake Loader terraform module is released
  source = "../../../../../../terraform-snowflake-loader"

  loader_enabled = var.loader_enabled

  # Some of the Snowflake resources are having problem when hypen is used in the name.
  name = replace(var.prefix, "-", "_")
  vpc_id = var.vpc_id
  subnet_ids = var.public_subnet_ids

  ssh_key_name = module.common.ssh_key_name
  ssh_ip_allowlist = var.ssh_ip_allowlist

  iam_permissions_boundary = var.iam_permissions_boundary

  telemetry_enabled = var.telemetry_enabled
  user_provided_id  = var.user_provided_id

  custom_iglu_resolvers = module.common.custom_iglu_resolvers
  
  stage_bucket_name = var.s3_bucket_name
  transformed_stage_prefix = "${var.s3_bucket_object_prefix}transformed/good"
  
  sqs_queue_name = aws_sqs_queue.message_queue.name

  sf_db_name = var.sf_db_name
  sf_wh_name = var.sf_wh_name
  sf_loader_password = var.sf_loader_password
  sf_region = var.sf_region
  sf_account = var.sf_account

  tags = var.tags

  cloudwatch_logs_enabled = var.cloudwatch_logs_enabled
  cloudwatch_logs_retention_days = var.cloudwatch_logs_retention_days
}
