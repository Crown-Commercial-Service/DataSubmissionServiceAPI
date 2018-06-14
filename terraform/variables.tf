variable "region" {
  description = "AWS Region"
}

variable "app_name" {
  description = "Application Name"
}

variable "rails_env" {
  description = "RAILS_ENV for CodeBuild"
  default     = "production"
}

variable "git_branch_to_track" {
  description = "Git Branch to track"
}

variable "github_token" {
  description = "GitHub Token"
}

variable "github_owner" {
  description = "GitHub Owner"
}

variable "github_repo" {
  description = "GitHub Repo"
}

variable "ecs_cluster_name" {
  description = "ECS Cluster Name"
}

variable "ecs_service_name" {
  description = "ECS Service Name"
}
