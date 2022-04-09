data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "update" {
  statement {
    effect  = "Allow"
    actions = [
      "elasticbeanstalk:UpdateApplicationVersion",
      "elasticbeanstalk:CreateApplicationVersion",
      "elasticbeanstalk:DeleteApplicationVersion"
    ]
    resources = ["*"]
    condition {
      test      = "StringEquals"
      variable  = "elasticbeanstalk:InApplication"
      values = [
        "arn:aws:elasticbeanstalk:${var.region}:${data.aws_caller_identity.current.account_id}:application/${aws_elastic_beanstalk_application.application.name}"
      ]
    } 
  }

  statement {
    effect  = "Allow" 
    actions = [
      "elasticbeanstalk:DescribeAccountAttributes",
      "elasticbeanstalk:AbortEnvironmentUpdate",
      "elasticbeanstalk:TerminateEnvironment",
      "rds:*",
      "elasticbeanstalk:ValidateConfigurationSettings",
      "elasticbeanstalk:CheckDNSAvailability",
      "autoscaling:*",
      "elasticbeanstalk:RequestEnvironmentInfo",
      "elasticbeanstalk:RebuildEnvironment",
      "elasticbeanstalk:DescribeInstancesHealth",
      "elasticbeanstalk:DescribeEnvironmentHealth",
      "sns:*",
      "elasticbeanstalk:RestartAppServer",
      "s3:*",
      "cloudformation:*",
      "elasticloadbalancing:*",
      "elasticbeanstalk:CreateStorageLocation",
      "elasticbeanstalk:DescribeEnvironmentManagedActions",
      "elasticbeanstalk:SwapEnvironmentCNAMEs",
      "elasticbeanstalk:DescribeConfigurationOptions",
      "elasticbeanstalk:ApplyEnvironmentManagedAction",
      "cloudwatch:*",
      "elasticbeanstalk:CreateEnvironment",
      "elasticbeanstalk:List*",
      "elasticbeanstalk:DeleteEnvironmentConfiguration",
      "elasticbeanstalk:UpdateEnvironment",
      "ec2:*",
      "elasticbeanstalk:RetrieveEnvironmentInfo",
      "elasticbeanstalk:DescribeConfigurationSettings",
      "sqs:*",
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable"
    ]
    resources = ["*"]
  }
  statement {
    effect  = "Allow" 
    actions = [
      "iam:*"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-elasticbeanstalk-ec2-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-elasticbeanstalk-service-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:instance-profile/aws-elasticbeanstalk-ec2-role"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
        "elasticbeanstalk:DescribeEvents",
        "elasticbeanstalk:DescribeApplications",
        "elasticbeanstalk:AddTags",
        "elasticbeanstalk:ListPlatformVersions"
    ]
    resources = ["arn:aws:elasticbeanstalk:${var.region}:${data.aws_caller_identity.current.account_id}:application/${aws_elastic_beanstalk_application.application.name}"]
  }

  statement {
    effect  = "Allow"
    actions = [
        "elasticbeanstalk:AddTags",
        "elasticbeanstalk:Describe*"
    ]
    resources = [
        "arn:aws:elasticbeanstalk:*::platform/*",
        "arn:aws:elasticbeanstalk:*:*:environment/*/*",
        "arn:aws:elasticbeanstalk:*:*:application/*",
        "arn:aws:elasticbeanstalk:*::solutionstack/*",
        "arn:aws:elasticbeanstalk:*:*:applicationversion/*/*",
        "arn:aws:elasticbeanstalk:*:*:configurationtemplate/*/*"
    ]
    condition {
      test      = "StringEquals"
      variable  = "elasticbeanstalk:InApplication"
      values = [
        "arn:aws:elasticbeanstalk:${var.region}:${data.aws_caller_identity.current.account_id}:application/${aws_elastic_beanstalk_application.application.name}"
      ]
    }
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
    effect    = "Allow"
    actions   = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
    ]
    resources = [
        "arn:aws:s3:::${var.bucket_name}",
        "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

}

resource "aws_iam_policy" "application_policy" {
  name    = "update-policy-${local.identifier}"
  policy  = data.aws_iam_policy_document.update.json
}

resource "aws_iam_group_policy_attachment" "attachment_group" {
  count       = length(var.iam_attach_groups) > 0 ? length(var.iam_attach_groups) : 0
  group       = var.iam_attach_groups[count.index]
  policy_arn  = aws_iam_policy.application_policy.arn
}