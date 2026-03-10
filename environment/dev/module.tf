terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.50"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
  # Workaround para evitar el crash
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
  


module "dynamodb" {
  source = "../../modules/dynamodb"

}

module "apigateway" {
  source = "../../modules/apigateway"

  lambda_invoke_arn    = module.lambda_api.lambda_invoke_arn
  lambda_function_name = module.lambda_api.lambda_function_name

  user_pool  = module.cognito.user_pool_id
  app_client = module.cognito.user_pool_client_id
}

module "lambda_api" {
  source = "../../modules/lambda"

  function_name    = "lambda-api"
  filename         = data.archive_file.lambda_api_zip.output_path
  source_code_hash = data.archive_file.lambda_api_zip.output_base64sha256
  handler          = "index.handler"
  
  memory_size = 128
  timeout     = 10
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  dynamodb_table_arns = [module.dynamodb.table_arn]
  sqs_queue_arns      = [module.sqs.sqs_arn]
  
  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
    QUEUE_URL  = module.sqs.sqs_url
  }
}

module "lambda_worker" {
  source = "../../modules/lambda"

  function_name    = "lambda-worker"
  filename         = data.archive_file.lambda_worker_zip.output_path
  source_code_hash = data.archive_file.lambda_worker_zip.output_base64sha256
  handler          = "index.handler"
  
  memory_size = 256
  timeout     = 30

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]

  dynamodb_table_arns = [module.dynamodb.table_arn]
  sqs_queue_arns      = [module.sqs.sqs_arn]
 
  environment_variables = {
    TABLE_NAME = module.dynamodb.table_name
  }
}



module "cognito" {
  source          = "../../modules/cognito"
  app_client_name = "${var.project_name}-${var.environment}-client"

}


module "sqs" {
  source = "../../modules/sqs"
}

module "amplify" {

  source = "../../modules/amplify"

  project_name = var.project_name
  environment  = var.environment

  repository = "https://github.com/axelalvarado92/ecommerce-frontend.git"

  access_token = var.access_token

  api_url = module.apigateway.api_url
}