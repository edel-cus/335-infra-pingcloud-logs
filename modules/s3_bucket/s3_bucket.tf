variable "bucket_name" {
  type = string
}

resource "aws_s3_bucket" "logs" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Purpose = "PingCloudLogs"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "glacier_transition" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "glacier-transition"
    status = "Enabled"

    filter {
      prefix = "" # Aplica a todos los objetos
    }

    transition {
      days          = 30   # Días después de la creación del objeto para moverlo a Glacier Instant Retrieval
      storage_class = "GLACIER_IR"
    }

    transition {
      days          = 60   # Días después de la creación del objeto para moverlo a Glacier Deep Archive
      storage_class = "DEEP_ARCHIVE"
    }
  }
}

output "bucket_name" {
  value = aws_s3_bucket.logs.id
}