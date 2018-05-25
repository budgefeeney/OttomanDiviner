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
  maintenance_window      = "Mon:00:00-Mon:03:00"
  backup_window           = "03:00-06:00"
  backup_retention_period = 0
  family = "postgres9.6"
  final_snapshot_identifier = "OttomanDivinerSnapshot"
  subnet_ids = "${module.vpc.public_subnets}"
  vpc_security_group_ids = [
    "${module.vpc.default_security_group_id}",
    "${module.postgres_sg.this_security_group_id}",
    "${module.bryan_sg.this_security_group_id}"
  ]
  publicly_accessible = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }

}

resource "aws_s3_bucket" "OD_bucket" {
  bucket = "hcktn-ottmndvnr-bucket"
  acl    = "private"
  force_destroy = true
  versioning { enabled = true }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

module "postgres_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "postgres"
  description = "POSTGRES access"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "DEBUG"
      cidr_blocks = "81.128.146.82/32"
    },
  ]
}

module "bryan_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "bryan"
  description = "POSTGRES access specially for bryan"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "DEBUG"
      cidr_blocks = "192.127.94.77/32"
    },
  ]
}
