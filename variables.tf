variable "region" {
  description = "Región de AWS donde desplegar los recursos"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nombre del bucket S3 para logs"
  type        = string
}

variable "lambda_name" {
  description = "Nombre de la función Lambda"
  type        = string
  default     = "ping-cloud-hola-mundo"
}

variable "lambda_role_name" {
  description = "Nombre del rol IAM para Lambda"
  type        = string
  default     = "ping-cloud-lambda-role"
}

variable "scheduler_role_name" {
  description = "Nombre del rol IAM para EventBridge Scheduler"
  type        = string
  default     = "ping-cloud-eventbridge-role"
}