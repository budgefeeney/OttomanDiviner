variable "webserver_tag" {
  default = "OttomanDiviner: REST Server"
}

variable "database_tag" {
  default = "OttomanDiviner: Database"
}

variable "azs" {
  type    = "list"
  default = ["a", "b"]
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "profile" {}

variable "region" {}
