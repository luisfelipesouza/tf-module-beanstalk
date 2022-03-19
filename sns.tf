resource "aws_sns_topic" "beanstalk_alert" {
  name = lower("topic-${local.identifier}")
  tags = {
    environment   = lower(var.environment)
    application   = lower(var.application)
    cost-center   = lower(var.cost-center)
    deployed-by   = lower(var.deployed-by)
  }
}

resource "aws_sns_topic_subscription" "lambda" { 
  topic_arn = aws_sns_topic.beanstalk_alert.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.lambda.arn
}