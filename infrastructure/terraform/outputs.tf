/**
output "bastion_ip" {
  description = "Bastion server IP"
  value       = "${module.bastion_cluster.public_ip}"
}
**/
output "etl_ip" {
  description = "Bastion server IP"
  value       = "${module.etl_cluster.public_ip}"
}

output "web_ip" {
  description = "Bastion server IP"
  value       = "${module.web_cluster.public_ip}"
}

output "rds_endpoint" {
  description = "RDS endpoing"
  value       = "${module.db.this_db_instance_endpoint}"
}
