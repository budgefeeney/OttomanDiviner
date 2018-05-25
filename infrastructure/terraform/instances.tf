module "web_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name           = "web-farm"
  instance_count = 1
  associate_public_ip_address = true
  ami                    = "ami-ca0135b3"
  instance_type          = "t2.micro"
  key_name               = "ottomandiviner"
  monitoring             = true
  vpc_security_group_ids = [
    "${module.vpc.default_security_group_id}",
    "${module.ssh_sg.this_security_group_id}",
    "${module.debug_sg.this_security_group_id}"
  ]
  subnet_id              = "${module.vpc.public_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}


module "etl_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name           = "etl-farm"
  instance_count = 1
  associate_public_ip_address = true
  ami                    = "ami-945e68ed"
  instance_type          = "p2.xlarge"
  key_name               = "ottomandiviner"
  monitoring             = true
  vpc_security_group_ids = [
    "${module.vpc.default_security_group_id}",
    "${module.ssh_sg.this_security_group_id}",
    "${module.debug_sg.this_security_group_id}"
  ]
  subnet_id              = "${module.vpc.public_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
/**
module "bastion_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"
  name                        = "bastion-farm"
  instance_count              = 1
  associate_public_ip_address = true
  ami                    = "ami-ca0135b3"
  instance_type          = "t2.micro"
  key_name               = "external"
  monitoring             = true
  vpc_security_group_ids = [
                            "${module.vpc.default_security_group_id}",
                            "${module.ssh_sg.this_security_group_id}"
                          ]
  subnet_id              = "${module.vpc.public_subnets[0]}"

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
**/
module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "ssh"
  description = "SSH access"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "81.128.146.82/32"
    },
  ]
}

module "debug_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "debug"
  description = "DEBUG access"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 8888
      to_port     = 8888
      protocol    = "tcp"
      description = "DEBUG"
      cidr_blocks = "81.128.146.82/32"
    },
  ]
}
