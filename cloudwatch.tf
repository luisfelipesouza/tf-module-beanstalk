resource "aws_cloudwatch_event_rule" "codepipeline" {
  name        = lower("codepipeline-event-rule-${local.identifier}")
  description = "Amazon CloudWatch Events rule to automatically start your pipeline when a change occurs in the Amazon S3 object key or S3 folder"
  is_enabled = true

  event_pattern = jsonencode(
        {
            detail = {
                eventName = [
                    "PutObject",
                    "CompleteMultipartUpload",
                    "CopyObject",
                ]
                eventSource = [
                    "s3.amazonaws.com",
                ]
                requestParameters = {
                    bucketName = [
                        var.deploy_bucket_name,
                    ]
                    key = [
                        "${var.deploy_package_prefix}/${var.deploy_package_object}",
                    ]
                }
            }
            detail-type = [
                "AWS API Call via CloudTrail",
            ]
            source      = [
                "aws.s3",
            ]
        }
    )
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule      = aws_cloudwatch_event_rule.codepipeline.name
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.start_codepipeline_role.arn

  depends_on = [aws_codepipeline.codepipeline, aws_cloudwatch_event_rule.codepipeline]
}