variable "project_name" {
    description = "The name of the project"
    type = string
    default = "ecommerce"
  
}

variable "environment" {
    description = "The environment to deploy to"
    type = string
    default = "dev"
  
}

variable "app_client_name" {
    description = "The app client for the cognito user pool"
    type = string
    default = null
  
}