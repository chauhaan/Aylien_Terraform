variable "instance_type" {
  default = ""
}

variable "aws_region" {
  default = ""
}

variable "key_pair" {
  default = ""
}

variable "vpc_id" {
  default = ""
}

variable "upper_threshold" {
  default = "75"
}

variable "lower_threshold" {
  default = "25"
}

variable "instance_id" {
  description = "Instance id of the application server"
  default = ""
}
