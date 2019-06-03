data "aws_availability_zones" "all" {}

### Create AMI
resource "aws_ami_from_instance" "ami" {
  name               = "Python-Paint-Image"
  source_instance_id = "${var.instance_id}"
}

### Creating Security Group for Scailing Group
resource "aws_security_group" "asg_sg" {
  name        = "Paint ASG Security Group"
  description = "Paint ASG Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Creating Security Group for Load Balancer
resource "aws_security_group" "lb_sg" {
  name        = "Paint ASG LB Security Group"
  description = "Paint ASG LB Security Group"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

### Creating Load Balancer
resource "aws_elb" "lb" {
  name               = "Paint-ASG-CLB"
  security_groups    = ["${aws_security_group.lb_sg.id}"]
  availability_zones = ["${data.aws_availability_zones.all.names}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "TCP:8080"
  }

  listener {
    lb_port           = 8080
    lb_protocol       = "tcp"
    instance_port     = "8080"
    instance_protocol = "tcp"
  }

  listener {
    lb_port           = 8081
    lb_protocol       = "tcp"
    instance_port     = "8081"
    instance_protocol = "tcp"
  }
}

## Creating Launch Configuration
resource "aws_launch_configuration" "asg_lc" {
  name            = "Paint-Application-LC"
  image_id        = "${aws_ami_from_instance.ami.id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.asg_sg.id}"]
  key_name        = "${var.key_pair}"
}

## Creating AutoScaling Group
resource "aws_autoscaling_group" "asg" {
  name                 = "Paint-Application-ASG"
  launch_configuration = "${aws_launch_configuration.asg_lc.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  min_size             = 1
  max_size             = 5
  load_balancers       = ["${aws_elb.lb.name}"]

  tag {
    key                 = "Name"
    value               = "Paint Application"
    propagate_at_launch = true
  }
}

# scale up alarm
resource "aws_autoscaling_policy" "scaleup_policy" {
  name                   = "Increase Group Size"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  cooldown               = "300"
}

resource "aws_cloudwatch_metric_alarm" "scaleup_alarm" {
  alarm_name          = "Application-SG-ScaleUp"
  alarm_description   = "Application-SG-ScaleUp"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "180"
  statistic           = "Average"
  threshold           = "${var.upper_threshold}"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaleup_policy.arn}"]
}

# scale down alarm
resource "aws_autoscaling_policy" "scaledown_policy" {
  name                   = "Decrease Group Size"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  cooldown               = "300"
}

resource "aws_cloudwatch_metric_alarm" "scaledown_alarm" {
  alarm_name          = "Application-SG-ScaleDown"
  alarm_description   = "Application-SG-ScaleDown"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "360"
  statistic           = "Average"
  threshold           = "${var.lower_threshold}"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.asg.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.scaledown_policy.arn}"]
}
