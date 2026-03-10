variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "us-east-1"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  default     = "ecommerce"
  type        = string

}

variable "environment" {
  description = "The environment to deploy to"
  default     = "dev"
  type        = string

}
variable "access_token" {
  description = "Github Personal Access Token"
  type        = string
  sensitive = true
}

