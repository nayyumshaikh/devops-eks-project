variable "name" {
  type        = string
  description = "Prefix for resource names"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name, used for subnet discovery tags"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "az_count" {
  type    = number
  default = 2
}
