provider "aws" {
  region     = "eu-west-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "OD_VPC"
  cidr = "10.0.0.0/16"

  azs              = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  database_subnets = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "ottomandiviner"

  engine            = "postgres"
  engine_version    = "9.6.3"
  instance_class    = "db.t2.large"
  allocated_storage = 5

  name     = "OttomanDiviner"
  username = "Ottoman"
  password = "WeCmBKO-j%-Oi?a3V-GkMdtwK4AOZMZF$HkpRah31S5MuK8o8bBhz!d1a?x2"
  port     = "5432"

  vpc_security_group_ids = ["${module.vpc.default_security_group_id}"]

  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

  # DB subnet group
  subnet_ids = "${module.vpc.database_subnets}"

  # DB parameter group
  family = "postgres9.6"

  # Snapshot name upon DB deletion
  final_snapshot_identifier = "OttomanDivinerSnapshot"
}

resource "aws_s3_bucket" "OD_bucket" {
  bucket = "hcktn-ottmndvnr-bucket"
  acl    = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "web_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "web-farm"
  instance_count = 1

  ami                    = "ami-ca0135b3"
  instance_type          = "t2.micro"
  key_name               = "ottomandiviner"
  monitoring             = true
  vpc_security_group_ids = ["${module.vpc.default_security_group_id}"]
  subnet_id              = "${module.vpc.private_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

/*
## Waiting on AWS Support to raise the limit

module "etl_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "etl-farm"
  instance_count = 1

  ami                    = "ami-945e68ed"
  instance_type          = "p2.xlarge"
  key_name               = "ottomandiviner"
  monitoring             = true
  vpc_security_group_ids = ["${module.vpc.default_security_group_id}"]
  subnet_id              = "${module.vpc.private_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
*/
module "bastion_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "bastion-farm"
  instance_count = 1

  ami                    = "ami-945e68ed"
  instance_type          = "t2.micro"
  key_name               = "external"
  monitoring             = true
  vpc_security_group_ids = ["${module.vpc.default_security_group_id}"]
  subnet_id              = "${module.vpc.public_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}