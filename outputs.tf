output "beanstalk_endpoint_url" {
  value = aws_elastic_beanstalk_environment.environment.endpoint_url
}
output "beanstalk_id" {
  value = aws_elastic_beanstalk_environment.environment.id
}
output "beanstalk_cname" {
  value = aws_elastic_beanstalk_environment.environment.cname 
}
output "beanstalk_load_balancers" {
  value = element(tolist(aws_elastic_beanstalk_environment.environment.load_balancers), 0)
}
output "code_pipeline_id" {
  value = aws_codepipeline.codepipeline.id
}
output "code_pipeline_name" {
  value = aws_codepipeline.codepipeline.name
}
output "update_iam_policy" {
  value = aws_iam_policy.application_policy.name
}
output "iam_role" {
  value = aws_iam_role.instance.id
}