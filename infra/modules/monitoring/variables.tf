variable "name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "namespace" {
  type    = string
  default = "devops-app"
}

variable "service" {
  type    = string
  default = "devops-app"
}
