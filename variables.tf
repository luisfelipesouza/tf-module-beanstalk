variable "instance_types" {
  type = string
  default = "t3.micro, t3.small"
}
variable "certificate_arn" {
  type = string
  default = ""
}
variable "certificate_status" {
  type = string
  default = ""
}
variable "instance_family" {
  type = string
  default = "t3"
}
variable "application" {
  type = string
}
variable "cost-center" {
  type = string
}
variable "deployed-by" {
  type = string
}
variable "platform" {
  type = string
  default = "ec2"
}
variable "tier" {
  type = string
  default = "WebServer"
}
variable "min_instance" {
  type = number
  default = 1
}
variable "max_instance" {
  type = number
  default = 4
}
variable "upper_threshold" {
  type = number
  default = 80
}
variable "root_volume" {
  type = number
  default = 40
}
variable "lower_threshold" {
  type = number
  default = 25
}
variable "privateA_subnets" {
  type = list
}
variable "public_subnets" {
  type = list
}
variable "environment" {
  type = string
}
variable "hosted_zone_id" {
  type = string
  default = ""
}
variable "domain" {
  type = string
  default = ""
}
variable "deploy_bucket_name" {
  type = string
}
variable "deploy_package_prefix" {
  type = string
}
variable "deploy_package_object" {
  type = string
}
variable "solution_name" {
  type = string
}
variable "deploy_policy" {
  default = "AllAtOnce"
  type = string
}
variable "rolling_update_type" {
  default = "Time"
  type = string
}
variable "dynamic_environment" {
  type = list(any)
}
variable "platform_options" {
  type = list(any)
}
variable "loadbalancer_type" {
  type = string
  default = "application"
}
variable "loadbalancer_scheme" {
  type = string
  default = "public"
}
variable "loadbalancer_shared" {
  type = string
  default = ""
}
variable "region" {
  type = string
}
variable "healthcheck_path" {
  type = string
  default = "/"
}
variable "lifecycle_max_count" {
  type = number
  default = 30
}
variable "enable_xray" {
  type = bool
  default = false
}
variable "stream_logs" {
  type = bool
  default = true
}
variable "delete_logs" {
  type = bool
  default = true
}
variable "retention_logs" {
  type = number
  default = 90
}
variable "platform_update" {
  type = string
  default = "minor"
}
variable "idle_timeout" {
  type = number
  default = 60
}
variable "maintenance_window" {
  // 01 a.m (-03:00 GMT)
  type = string
  default = "Wed:09:30"
}
variable "iam_attachment" {
  type = bool
  default = false
}
variable "iam_attach_groups" {
  type = list(string)
  default = [""]
}
variable "sns_topic_arn"{
    type = string
}
variable "sns_topic_name" {
    type = string
}