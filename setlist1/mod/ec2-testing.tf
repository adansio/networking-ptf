variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "name_prefix" {
  type    = string
  default = "lab"
}

# Ejemplo: [aws_subnet.app_priv_az1.id, aws_subnet.db_priv_az1.id, aws_subnet.dmz_pub_az1.id], vienen del main
variable "subnet_ids" {
  type = list(string)
}

variable "db_sg_id"  { type = string }
variable "app_sg_id" { type = string }
variable "fe_sg_id"  { type = string }
variable "dmz_sg_id" { type = string }

variable "vpc_id" { type = string }

variable "subnet_type_map" {
  type = map(string)
  description = "Map subnet_id -> type. Type must be one of: \"app\", \"db\", \"dmz\". Example: { aws_subnet.app_priv_az1.id = \"app\", aws_subnet.db_priv_az1.id = \"db\", aws_subnet.dmz_pub_az1.id = \"dmz\"}"
}

provider "aws" {
  region = var.region
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_subnet" "lookup" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}

data "aws_iam_policy_document" "ssm_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# validación - normalización
locals {
  # default to "app" if a subnet_id missing or invalid
  normalized_subnet_type = { for id, t in var.subnet_type_map : id => lower(t) }
}

resource "aws_iam_role" "ssm_role" {
  name               = "${var.name_prefix}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role.json
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_instance" "servers" {
  for_each = data.aws_subnet.lookup

  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"
  subnet_id     = each.value.id
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name
  associate_public_ip_address = false

  vpc_security_group_ids = [    
	lookup(      
	  {
        "db"  = var.db_sg_id,
        "app" = var.app_sg_id,
        "fe"  = var.fe_sg_id,
        "dmz" = var.dmz_sg_id
      },
      lookup(local.normalized_subnet_type, each.key, "app"),
      var.app_sg_id    
	)
  ]

  user_data = <<-EOF
              #!/bin/bash
              yum install -y amazon-ssm-agent || true
              systemctl enable amazon-ssm-agent || true
              systemctl start amazon-ssm-agent || true
              EOF

  tags = {
    Name = "${var.name_prefix}-server-${substr(each.value.id, length(each.value.id) - 8, 8)}"
  }
}

