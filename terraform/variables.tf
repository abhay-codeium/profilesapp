variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2"
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "profilesapp"
}

variable "repository_url" {
  description = "GitHub repository URL"
  type        = string
  default     = "https://github.com/abhay-codeium/profilesapp"
}

variable "github_access_token" {
  description = "GitHub access token for Amplify"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "main"
}
