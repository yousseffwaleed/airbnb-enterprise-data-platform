terraform {
  required_version = ">= 1.5"
  required_providers {
    aws       = { source = "hashicorp/aws", version = ">= 5.0" }
    snowflake = { source = "snowflakedb/snowflake", version = "~> 2.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

# Key and passphrase come from SNOWFLAKE_PRIVATE_KEY and SNOWFLAKE_PRIVATE_KEY_PASSPHRASE.
provider "snowflake" {
  organization_name = var.snowflake_organization
  account_name      = var.snowflake_account
  user              = var.snowflake_user
  role              = "ACCOUNTADMIN"
  authenticator     = "SNOWFLAKE_JWT"
}

data "aws_caller_identity" "current" {}

locals {
  role_name = "snowflake_s3_role"
  prefix    = "source/"
  # Built as a string so the integration does not depend on the role resource (avoids a cycle).
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.role_name}"
}

# ---------- S3 ----------
resource "aws_s3_bucket" "landing" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_public_access_block" "landing" {
  bucket                  = aws_s3_bucket.landing.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ---------- Snowflake storage integration ----------
resource "snowflake_storage_integration_aws" "s3" {
  name                      = "S3_AIRBNB_INT"
  enabled                   = true
  storage_provider          = "S3"
  storage_allowed_locations = ["s3://${aws_s3_bucket.landing.bucket}/${local.prefix}"]
  storage_aws_role_arn      = local.role_arn
}

# ---------- IAM role Snowflake assumes ----------
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration_aws.s3.describe_output[0].iam_user_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [snowflake_storage_integration_aws.s3.describe_output[0].external_id]
    }
  }
}

data "aws_iam_policy_document" "read" {
  statement {
    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.landing.arn}/${local.prefix}*"]
  }
  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.landing.arn]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${local.prefix}*"]
    }
  }
}

resource "aws_iam_role" "snowflake" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy" "read" {
  name   = "snowflake-airbnb-s3-read"
  role   = aws_iam_role.snowflake.id
  policy = data.aws_iam_policy_document.read.json
}

# ---------- Warehouses ----------
resource "snowflake_warehouse" "this" {
  for_each            = var.warehouses
  name                = each.key
  warehouse_size      = each.value.size
  auto_suspend        = each.value.auto_suspend
  auto_resume         = true
  initially_suspended = true
}

# ---------- Adopt objects that already exist ----------
import {
  to = aws_s3_bucket.landing
  id = "snowbucketyoussef"
}
import {
  to = aws_s3_bucket_public_access_block.landing
  id = "snowbucketyoussef"
}
import {
  to = aws_iam_role.snowflake
  id = "snowflake_s3_role"
}
import {
  to = aws_iam_role_policy.read
  id = "snowflake_s3_role:snowflake-airbnb-s3-read"
}
import {
  to = snowflake_storage_integration_aws.s3
  id = "\"S3_AIRBNB_INT\""
}
import {
  to = snowflake_warehouse.this["COMPUTE_WH"]
  id = "\"COMPUTE_WH\""
}
