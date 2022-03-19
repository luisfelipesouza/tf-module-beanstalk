resource "aws_lambda_function" "lambda" {
  filename          = "./lambda.zip"
  function_name     = local.identifier
  role              = aws_iam_role.lambda.arn
  handler           = "index.handler"
  source_code_hash  = filebase64sha256("./lambda.zip")
  runtime           = "nodejs14.x"
  timeout           = 20

  environment {
    variables = {
      WEBHOOK_HOST  = var.teams_webhook_host,
      WEBHOOK_PATH  = var.teams_webhook_path,
      ACCOUNT       = data.aws_caller_identity.current.account_id,
      REGION        = var.region,
      APPLICATION   = local.identifier,
      DOMAIN        = var.domain,
    }
  }

  tags = {
    environment = lower(var.environment)
    application = lower(var.application)
    cost-center = lower(var.cost-center)
    deployed-by = lower(var.deployed-by)
  }

  depends_on = [null_resource.git_clone]
}

resource "aws_lambda_permission" "sns_execution" { 
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = local.identifier
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.beanstalk_alert.arn
}

//resource "null_resource" "github_lambda" {
//  triggers = {
//    on_version_change = "1"
//  }
//
//  provisioner "local-exec" {
//    command = "curl -o ./lambda.zip ${local.lambda_source[var.lambda_source]}"
//  }
//
//}


resource "null_resource" "git_clone" {
  triggers = {
    on_version_change = "1"
  }

  provisioner "local-exec" {
    command = "git clone https://github.com/luisfelipesouza/sns-beanstalk-lambda.git ./lambda"
  }
}

  data "archive_file" "git_clone" {
  type        = "zip"
  source_file = "./lambda/index.js"
  output_path = "./lambda.zip"

  depends_on = [null_resource.git_clone]
}
