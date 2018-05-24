resource "aws_security_group" "database" {
  name        = "webserver -: database"
  description = "Allow connections from webservers"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${split(", ", "${var.webserver_cidrs}")}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "LAMP: Database"
  }
}
