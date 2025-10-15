variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Local path to the SSH private key matching key_pair_name"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed to SSH (e.g., x.x.x.x/32)"
  type        = string
}

