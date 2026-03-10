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

variable "region" {
    description = "The AWS region to deploy to"
    type = string
    default = "us-east-1"
  
}

variable "lambda_invoke_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "user_pool" {
    type = string
  
}

variable "app_client" {
    type = string
  
}