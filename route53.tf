resource "aws_route53_record" "root" {
  count = var.domain != "" ? 1 : 0
  
  zone_id = var.hosted_zone_id
  name    = "${var.domain}."
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.environment.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www_root" {
  count = var.domain != "" ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = "www.${var.domain}."
  type    = "A"

  alias {
    name                   = aws_elastic_beanstalk_environment.environment.cname
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = false
  }
}