resource "random_id" "id" {
  byte_length = 4
}

locals {
  identifier            = lower("${var.application}-${var.environment}-${random_id.id.hex}")
  loadbalancer_settings = {
    "application" = [
      {
        name      = "StickinessEnabled"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        value     = "true"
      },
      {
        name      = "SSLCertificateArns"
        namespace = "aws:elbv2:listener:443"
        value     = var.certificate_status == "ISSUED" ? var.certificate_arn : "" 
      },
      {
        name      = "Protocol"
        namespace = "aws:elbv2:listener:443"
        value     = "HTTPS"
      },
      {
        name      = "SSLPolicy"
        namespace = "aws:elbv2:listener:443"
        value     = var.certificate_status == "ISSUED" ? "ELBSecurityPolicy-TLS-1-2-2017-01" : "false"
      },
      {
        name      = "ListenerEnabled"
        namespace = "aws:elbv2:listener:443"
        value     = var.certificate_status == "ISSUED" ? "true" : "false"
      },
      {
        name      = "IdleTimeout"
        namespace = "aws:elbv2:loadbalancer"
        value     = var.idle_timeout
      },
      {
        name      = "Protocol"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        value     = "HTTP"
      },
      {
        name      = "ListenerEnabled"
        namespace = "aws:elbv2:listener:default"
        value     = "true"
      },
      {
        name      = "LoadBalancerType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "application"
      },
      {
        name      = "ELBScheme"
        namespace = "aws:ec2:vpc"
        value     = var.loadbalancer_scheme
      },
      {
        name      = "EnvironmentType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "LoadBalanced"
      }
    ]
    "shared" = [
      
      {
        name      = "LoadBalancerType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "application"
      },
      {
        name      = "LoadBalancerIsShared"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "true"
      },
      {
        name      = "SharedLoadBalancer"
        namespace = "aws:elbv2:loadbalancer"
        value     = var.loadbalancer_shared
      },
      {
        name      = "EnvironmentType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "LoadBalanced"
      }
    ]
    "network" = [
      {
        name      = "Protocol"
        namespace = "aws:elasticbeanstalk:environment:process:default"
        value     = "TCP"
      },
      {
        name      = "ListenerEnabled"
        namespace = "aws:elbv2:listener:default"
        value     = "true"
      },
      {
        name      = "LoadBalancerType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "network"
      },
      {
        name      = "ELBScheme"
        namespace = "aws:ec2:vpc"
        value     = var.loadbalancer_scheme
      },
      {
        name      = "EnvironmentType"
        namespace = "aws:elasticbeanstalk:environment"
        value     = "LoadBalanced"
      }
    ]
  }
}