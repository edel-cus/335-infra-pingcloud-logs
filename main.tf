terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

module "log_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = "ping-cloud-logs-${random_id.suffix.hex}"
}

module "lambda" {
  source           = "./modules/lambda"
  lambda_name      = "ping-cloud-hola-mundo"
  s3_bucket_name   = module.log_bucket.bucket_name
  lambda_role_name = "ping-cloud-lambda-role"
}

module "eventbridge" {
  source                = "./modules/eventbridge"
  lambda_function_arn   = module.lambda.lambda_arn
  scheduler_role_name   = "ping-cloud-eventbridge-role"
}

output "bucket_name" {
  value = module.log_bucket.bucket_name
}

output "lambda_function_name" {
  value = module.lambda.lambda_name
}

output "eventbridge_rule_name" {
  value = module.eventbridge.rule_name
}