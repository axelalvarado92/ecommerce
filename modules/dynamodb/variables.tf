variable "project_name" {
    description = "El nombre del proyecto"
    type = string
    default = "ecommmerce"
}
variable "environment" {
    description = "El environment donde se va a desplegar"
    type = string
    default = "dev"
}

variable "billing_mode" {
    description = "DynamoDB billing mode"
    type = string
    default = "PAY_PER_REQUEST"
}

variable "tags" {
    description = "A map of tags to add to all resources"
    type = map(string)
    default = {}
  
}