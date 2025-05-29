variable "lambda_function_arn" {
  type = string
}
variable "scheduler_role_name" {
  type = string
}

resource "aws_cloudwatch_event_rule" "scheduler" {
  name                = "ping-cloud-every-5min"
  description         = "Ejecuta Lambda de hola mundo cada 5 minutos"
  schedule_expression = "rate(5 minutes)"

  tags = {
    Purpose = "PingCloudScheduler"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.scheduler.name
  arn  = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduler.arn
}

output "rule_name" {
  value = aws_cloudwatch_event_rule.scheduler.name
}