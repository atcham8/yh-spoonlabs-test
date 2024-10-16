provider "aws" {
  region = "ap-northeast-2"
}

# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name                 = "my-vpc"
  cidr                 = "10.21.0.0/16"
  azs                  = ["ap-northeast-2a", "ap-northeast-2b"]
  public_subnets       = ["10.21.0.0/24", "10.21.1.0/24"]
  private_subnets      = ["10.21.32.0/24", "10.21.33.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = false
  one_nat_gateway_per_az = true
  public_subnet_tags   = { "Name" = "Public Subnet" }
  private_subnet_tags  = { "Name" = "Private Subnet" }
}

# EKS Module
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "18.0.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.27"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    eks_nodes = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "my-key-pair" # 변경: EC2 키페어 이름
      subnet_ids    = module.vpc.private_subnets
    }
  }
}

# ALB 및 Target Group 설정
resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
  enable_deletion_protection = false
}

resource "aws_lb_target_group" "tg" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# ALB 보안 그룹
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
