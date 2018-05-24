resource "aws_db_instance" "database" {
  allocated_storage    = 5
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "10.3"
  instance_class       = "db.r3.large"
  name                 = "OttomanDiviner"
  username             = "ottoman"
  password             = "Password1234!"
  db_subnet_group_name = "${aws_db_subnet_group.database.name}"

  # parameter_group_name   = "default.mysql5.6"
  availability_zone      = "eu-west-1"
  vpc_security_group_ids = ["${aws_security_group.database.id}"]
  skip_final_snapshot    = true

  # multi_az = true

  tags {
    Name = "${var.database_tag}"
  }
}
