resource "aws_elastic_beanstalk_application" "application" {
  name        = "${local.identifier}"
  description = "${local.identifier}"

  appversion_lifecycle {
    service_role          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-elasticbeanstalk-service-role"
    max_count             = var.lifecycle_max_count
    delete_source_from_s3 = true
  }
}

resource "aws_elastic_beanstalk_application_version" "default" {
  name        = "sample-app-${local.identifier}"
  application = aws_elastic_beanstalk_application.application.name
  description = "application version created by terraform"
  bucket      = var.deploy_bucket_name
  key         = "sample-applications/dotnet-asp-v1.zip"
}

data "aws_elastic_beanstalk_hosted_zone" "current" {
    depends_on = [aws_elastic_beanstalk_environment.environment]
}

resource "aws_elastic_beanstalk_environment" "environment" {
  name                = "${local.identifier}"
  application         = aws_elastic_beanstalk_application.application.name
  solution_stack_name = var.solution_name
  tier                = var.tier
  tags = {
    environment   = lower(var.environment)
    application   = lower(var.application)
    cost-center   = lower(var.cost-center)
    deployed-by   = lower(var.deployed-by)
  }

  // specific platform settings
  dynamic "setting" {
    for_each = var.platform_options
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.instance.arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "ManagedActionsEnabled"
    value     = true
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions"
    name      = "PreferredStartTime"
    value     = var.maintenance_window
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "UpdateLevel"
    value     = var.platform_update
  }

  setting {
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    name      = "InstanceRefreshEnabled"
    value     = true
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = var.healthcheck_path
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = var.stream_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "DeleteOnTerminate"
    value     = var.delete_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "RetentionInDays"
    value     = var.retention_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "HealthStreamingEnabled"
    value     = var.stream_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "DeleteOnTerminate"
    value     = var.delete_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs:health"
    name      = "RetentionInDays"
    value     = var.retention_logs
  }

  setting {
    namespace = "aws:elasticbeanstalk:xray"
    name      = "XRayEnabled"
    value     = var.enable_xray
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.profile.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.generated_key.key_name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp2"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.root_volume
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Topic ARN"
    value     = var.sns_topic_arn
  }

  setting {
    namespace = "aws:elasticbeanstalk:sns:topics"
    name      = "Notification Topic Name"
    value     = var.sns_topic_name
  }

  # A quick and safe rollback in case the deployment fails. 
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = var.rolling_update_type
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = var.deploy_policy
  }

  // Environment variables
  dynamic "setting" {
    for_each = var.dynamic_environment
    content {
      namespace = "aws:elasticbeanstalk:application:environment"
      name      = setting.value.name
      value     = setting.value.value
    }
  }

  dynamic "setting" {
    for_each = local.loadbalancer_settings[var.loadbalancer_type]
    content {
      namespace = setting.value.namespace
      name      = setting.value.name
      value     = setting.value.value
    }
  }

  setting {
    namespace = "aws:cloudformation:template:parameter"
    name      = "InstanceTypeFamily"
    value     = var.instance_family
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "InstanceTypes"
    value     = var.instance_types
  }

  setting {
    name      = "ELBSubnets"
    namespace = "aws:ec2:vpc"
    value     = join(",", sort(var.public_subnets))
  }

  setting {
    name      = "Subnets"
    namespace = "aws:ec2:vpc"
    value     = join(",", sort(var.privateA_subnets))
  }

  // Autoscaling
  setting {
    name      = "MeasureName"
    namespace = "aws:autoscaling:trigger"
    value     = "CPUUtilization"
  }

  setting {
    name      = "Unit"
    namespace = "aws:autoscaling:trigger"
    value     = "Percent"
  }

  setting {
    name      = "Statistic"
    namespace = "aws:autoscaling:trigger"
    value     = "Average"
  }

  setting {
    name      = "Period"
    namespace = "aws:autoscaling:trigger"
    value     = "5"
  }

  setting {
    name      = "BreachDuration"
    namespace = "aws:autoscaling:trigger"
    value     = "5"
  }

  setting {
    name      = "UpperThreshold"
    namespace = "aws:autoscaling:trigger"
    value     = var.upper_threshold
  }

  setting {
    name      = "UpperBreachScaleIncrement"
    namespace = "aws:autoscaling:trigger"
    value     = 1
  }

  setting {
    name      = "LowerThreshold"
    namespace = "aws:autoscaling:trigger"
    value     = var.lower_threshold
  }

  setting {
    name      = "LowerBreachScaleIncrement"
    namespace = "aws:autoscaling:trigger"
    value     = -1
  }

  setting {
    name      = "MinSize"
    namespace = "aws:autoscaling:asg"
    value     = var.min_instance
  }

  setting {
    name      = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value     = var.max_instance
  }
}
