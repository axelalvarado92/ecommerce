### utilizo api gateway v2 porque voy a crear una http ###
resource "aws_apigatewayv2_api" "http_api" {
  name                       = "${var.project_name}-${var.environment}-api"
  protocol_type              = "HTTP"
}

### integracion con lambda ###
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"
  integration_method        = "POST"
  integration_uri           = var.lambda_invoke_arn
  payload_format_version = "2.0"

  depends_on = [
    var.lambda_function_name   ### en caso de que TF cree la interacion antes que lambda ###
  ]
 
}

### creacion de la rutas para api ###
resource "aws_apigatewayv2_route" "create_user" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /users"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_route" "post_auth" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /auth"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  
}

resource "aws_apigatewayv2_route" "post_orders" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /orders"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_authorizer_api.id
  
}

resource "aws_apigatewayv2_route" "get_orders" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /orders"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.jwt_authorizer_api.id
}

### sirve para obtener el account id ###
data "aws_caller_identity" "current" {

}
### permitir que apigateway invoque lambda ###
resource "aws_lambda_permission" "api_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.http_api.id}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
}

### jwt autorizher ###
resource "aws_apigatewayv2_authorizer" "jwt_authorizer_api" {
  api_id          = aws_apigatewayv2_api.http_api.id
  name            = "api-authorizer"
  authorizer_type = "JWT"

  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [var.app_client]
    issuer   = "https://cognito-idp.${var.region}.amazonaws.com/${var.user_pool}"
  }
}

### outputs###
output "api_url" {
  description = "Invoke URL of the API Gateway"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

