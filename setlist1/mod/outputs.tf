output "instance_ids" {
  value = { for k, v in aws_instance.servers : k => v.id }
}

output "instance_private_ips" {
  value = { for k, v in aws_instance.servers : k => v.private_ip }
}
