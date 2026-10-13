variable "name" {
  type = string
}

variable "github_repo" {
  type        = string
  description = "owner/repo, e.g. your-username/devops-eks-project"
}

variable "ecr_repository_arn" {
  type = string
}
