output "jenkins_url" {
  value = "http://${aws_instance.master.public_ip}:8080"
}

output "ssh_command" {
  value = "ssh -i ${var.project_name}-master-key.pem ubuntu@${aws_instance.master.public_ip}"
}
