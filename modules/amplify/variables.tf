variable "project_name" {
  type        = string
  description = "Nombre del proyecto"
}

variable "environment" {
  type        = string
  description = "Environment (dev, prod)"
}

variable "repository" {
  type        = string
  description = "Repositorio de GitHub"
}

variable "branch_name" {
  type        = string
  description = "Branch de deploy"
  default     = "main"
}


variable "api_url" {
  type        = string
  description = "URL del API Gateway"
}
variable "access_token" {
  type = string
  description = "token for Amplify"
  
}