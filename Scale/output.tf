output "LoadBalancer_DNS" {
  value = "${aws_elb.lb.dns_name}"
}
