variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type        = string
  default     = "1.36"
  description = "Check which versions EKS currently supports before applying"
}

variable "control_plane_subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 3
}
