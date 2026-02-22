# ------------------------------------
# EC2 Outputs
# ------------------------------------

output "ec2_public_ip" {
  value = aws_instance.my-server.public_ip
}

# output "ec2_public_dns" {
#   value = aws_instance.web_server.public_dns
# }