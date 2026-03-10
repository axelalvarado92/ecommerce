data "archive_file" "lambda_api_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/api"
  output_path = "${path.module}/lambda_api.zip"
}

data "archive_file" "lambda_worker_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambdas/worker"
  output_path = "${path.module}/lambda_worker.zip"
}

resource "aws_lambda_event_source_mapping" "lambda_trigger" {
  event_source_arn = module.sqs.sqs_arn
  function_name    = module.lambda_worker.lambda_function_name
  
  depends_on = [
    module.lambda_worker,
    module.sqs
  ]
}
