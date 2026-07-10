output "public_ips" {
  description = "Public IP addresses of all EC2 instances"

  value = {
    for server_name, instance in aws_instance.servers :
    server_name => instance.public_ip
  }
}

output "instance_ids" {
  description = "Instance IDs of all EC2 instances"

  value = {
    for server_name, instance in aws_instance.servers :
    server_name => instance.id
  }
}
