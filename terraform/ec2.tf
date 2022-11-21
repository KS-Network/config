# Keypair
resource "aws_key_pair" "ec2_ssh_pub" {
  key_name   = format("%s-ec2-ssh-pub", var.name_prefix)
  public_key = file("./ec2-ssh.pub")
}

# AMI
data "aws_ami" "amazonLinux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# SG
resource "aws_security_group" "sg_api" {
  name        = format("%s-sg-ec2", var.name_prefix)
  vpc_id      = aws_vpc.vpc_main.id

  tags = {
    Name = format("%s-sg-ec2", var.name_prefix)
  }
}

## SG Rules
### Ingress
resource "aws_security_group_rule" "sg_api_rule_ing_http" {
  type              = "ingress"
  from_port         = var.apiserver_port
  to_port           = var.apiserver_port
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_api.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "sg_api_rule_ing_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "TCP"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_api.id

  lifecycle {
    create_before_destroy = true
  }
}

### Egress
resource "aws_security_group_rule" "sg_api_rule_eg_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# EC2
## AZ1
resource "aws_instance" "ec2_api" {
  ami           = data.aws_ami.amazonLinux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.sg_api.id
  ]

  subnet_id            = aws_subnet.pub_subnet_1_0.id
  key_name             = format("%s-ec2-ssh-pub", var.name_prefix)
  iam_instance_profile = aws_iam_instance_profile.ec2_api_iam_profile.name

  tags = {
    Name = format("%s-ec2-api", var.name_prefix)
    Tier = "api-server-layer"
  }
}

resource "aws_iam_instance_profile" "ec2_api_iam_profile" {
  name = format("%s-ec2-api-iam-profile", var.name_prefix)
  role = aws_iam_role.ec2_role.name
}

# EIP
resource "aws_eip" "eip_api" {
  vpc = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eip_association" "eip_api_assoc" {
  instance_id   = aws_instance.ec2_api.id
  allocation_id = aws_eip.eip_api.id
}
