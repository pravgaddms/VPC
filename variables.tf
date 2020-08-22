variable "vpc_cidr" {
  default     = "10.0.0.0/16"
}

variable "subnet1_cidr" {
  default     = "10.0.0.0/24"
}

variable "subnet1_az" {
  default     = "us-east-1a"
}
variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0ac80df6eff0e70b5"
}