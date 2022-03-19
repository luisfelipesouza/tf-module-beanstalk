data "aws_iam_policy_document" "role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = [
        "ec2.amazonaws.com", 
        "elasticbeanstalk.amazonaws.com",
        "managedupdates.elasticbeanstalk.amazonaws.com",
        "maintenance.elasticbeanstalk.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "instance" {
  name                  = lower("role-beanstalk-${local.identifier}")
  path                  = "/"
  assume_role_policy    = data.aws_iam_policy_document.role-policy.json
  force_detach_policies = true
}

# EC2 Profile
resource "aws_iam_instance_profile" "profile" {
  name = lower("profile-beanstalk-${local.identifier}")
  role = aws_iam_role.instance.name
}

// OK
resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWebTier" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWorkerTier" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkCustomPlatformforEC2Role" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkCustomPlatformforEC2Role"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkEnhancedHealth" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

// OK
resource "aws_iam_role_policy_attachment" "AmazonSSMAutomationRole" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSXrayWriteOnlyAccess" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
}

// Allows an environment to manage Amazon CloudWatch Logs log groups
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkRoleCWL" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleCWL"
}

// OK
resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkRoleSNS" {
  role       = aws_iam_role.instance.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkRoleSNS"
}