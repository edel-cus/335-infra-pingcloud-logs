variable "lambda_name" {
  type = string
}
variable "lambda_role_name" {
  type = string
}
variable "s3_bucket_name" {
  type = string
}

resource "aws_iam_role" "lambda" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Purpose = "PingCloudLambda"
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.lambda_role_name}-policy"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "this" {
  function_name    = var.lambda_name
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  role             = aws_iam_role.lambda.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)

  environment {
    variables = {
      LOG_BUCKET = var.s3_bucket_name
    }
  }

  tags = {
    Purpose = "PingCloudLambda"
  }
}

output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_name" {
  value = aws_lambda_function.this.function_name
}