data "aws_iam_policy_document" "codepipeline_document" {
  statement {
    effect    = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "elasticbeanstalk:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow" 
    actions    = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow" 
    actions    = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
        "logs:CreateLogGroup",
        "logs:PutRetentionPolicy",
        "logs:DescribeLogGroups"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
        "iam:PassRole"
    ]
    resources = [
        "${aws_iam_role.instance.arn}/*",
        "${aws_iam_role.instance.arn}"
    ]
    condition {
      test      = "StringEquals"
      variable  = "iam:PassedToService"
      values = [
        "ec2.amazonaws.com"
      ]
    }
  }

}

resource "aws_iam_policy" "codepipeline_policy" {
  name    = lower("policy-codepipeline-${local.identifier}")
  policy  = data.aws_iam_policy_document.codepipeline_document.json
}

data "aws_iam_policy_document" "pipeline_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name                  = lower("role-cloudwatch-${local.identifier}")
  path                  = "/"
  assume_role_policy    = data.aws_iam_policy_document.pipeline_assume_role.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "pipeline-role-attach" {
  role        = aws_iam_role.codepipeline_role.name
  policy_arn  = aws_iam_policy.codepipeline_policy.arn
}