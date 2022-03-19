resource "aws_codepipeline" "codepipeline" {
  role_arn = aws_iam_role.codepipeline_role.arn
  name     = lower("pipeline-${local.identifier}")

  artifact_store {
    location = var.deploy_bucket_name
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.arn
      type = "KMS"
    }
  }
  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        PollForSourceChanges = false
        S3Bucket             = var.deploy_bucket_name
        S3ObjectKey          = "${var.deploy_package_prefix}/${var.deploy_package_object}"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.application.name
        EnvironmentName = aws_elastic_beanstalk_environment.environment.name
      }
    }
  }
  tags = {
    environment = lower(var.environment)
    application = lower(var.application)
    cost-center = lower(var.cost-center)
    deployed-by = lower(var.deployed-by)
  }
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}
