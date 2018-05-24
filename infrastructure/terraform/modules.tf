provider "aws" {
  version = ">= 0.1.4"

  # default location is $HOME/.aws/credentials
  profile = "${var.profile}"
  region  = "${var.region}"
}

resource "aws_vpc" "lamp" {
  cidr_block = "${var.vpc_cidr_block}"

  tags {
    Name = "OttomanDiviner"
  }
}

module "webserver" {
  source = "modules/webserver"

  vpc_id        = "${aws_vpc.lamp.id}"
  vpc_cidr      = "${aws_vpc.lamp.cidr_block}"
  azs           = "${var.azs}"
  region        = "${var.region}"
  webserver_tag = "${var.webserver_tag}"

  # other module dependencies
  db_server_address = "${module.database.server_address}"
}

module "database" {
  source = "modules/database"

  vpc_id       = "${aws_vpc.lamp.id}"
  vpc_cidr     = "${aws_vpc.lamp.cidr_block}"
  azs          = "${var.azs}"
  region       = "${var.region}"
  database_tag = "${var.database_tag}"

  # other module dependencies
  webserver_cidrs = "${module.webserver.webserver_cidrs}"
}
