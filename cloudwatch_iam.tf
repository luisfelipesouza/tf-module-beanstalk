data "aws_iam_policy_document" "start_codepipeline_document" {
  statement {
    effect = "Allow"
    actions = ["codepipeline:StartPipelineExecution"]
    resources = [aws_codepipeline.codepipeline.arn]
  }
}

resource "aws_iam_policy" "start_codepipeline_policy" {
  name    = lower("policy-start-codepipeline-${local.identifier}")
  policy  = data.aws_iam_policy_document.start_codepipeline_document.json
}

data "aws_iam_policy_document" "start_pipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "start_codepipeline_role" {
  name                  = lower("role-start-cloudwatch-${local.identifier}")
  path                  = "/"
  assume_role_policy    = data.aws_iam_policy_document.start_pipeline_assume_role.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "start_pipeline_role_attach" {
  role        = aws_iam_role.start_codepipeline_role.name
  policy_arn  = aws_iam_policy.start_codepipeline_policy.arn
}