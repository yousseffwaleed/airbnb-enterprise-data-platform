variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "bucket_name" {
  type    = string
  default = "snowbucketyoussef"
}

variable "snowflake_organization" {
  type = string
}

variable "snowflake_account" {
  type = string
}

variable "snowflake_user" {
  type = string
}

# Match these to SHOW WAREHOUSES so the first plan shows no changes.
variable "warehouses" {
  type = map(object({ size = string, auto_suspend = number }))
  default = {
    COMPUTE_WH = { size = "XSMALL", auto_suspend = 60 }
  }
}
