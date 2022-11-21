# Required Roles
## Common
### AWS managed policies
data "aws_iam_policy" "aws_codedeploy_role" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

data "aws_iam_policy" "aws_codedeploy_full_access" {
  arn = "arn:aws:iam::aws:policy/AWSCodeDeployFullAccess"
}

### Trusted entities
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codedeploy_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

## Roles
### EC2 role
resource "aws_iam_role" "ec2_role" {
  name               = format("%s-ec2-role", var.name_prefix)
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "grant_codedeploy_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_full_access.arn
}

resource "aws_iam_role_policy_attachment" "grant_codedeployrole_to_ec2" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_role.arn
}

### CodeDeploy role
resource "aws_iam_role" "codedeploy_role" {
  name               = format("%s-codedeploy-role", var.name_prefix)
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "grant_codedeployrole_to_codedeploy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = data.aws_iam_policy.aws_codedeploy_role.arn
}

# CodeDeploy
resource "aws_codedeploy_app" "codedeploy_api" {
  compute_platform = "Server"
  name             = format("%s-codedeploy-api", var.name_prefix)
}

resource "aws_codedeploy_deployment_group" "codedeploy_api_dpy_group" {
  app_name              = aws_codedeploy_app.codedeploy_api.name
  deployment_group_name = format("%s-codedeploy-api-deployment-group", var.name_prefix)
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      type  = "KEY_AND_VALUE"
      key   = "Tier"
      value = "api-server-layer"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}
