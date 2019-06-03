output "Instance_ID" {
  value = "${aws_instance.paint.id}"
}

output "Instance_IP" {
  value = "${aws_instance.paint.public_ip}"
}