### base de datos de usuario ###
resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.project_name}-${var.environment}-user-pool"

  username_attributes = ["email"]

  password_policy {
    minimum_length    = 8
    require_uppercase = false
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  auto_verified_attributes = ["email"]
}

### La aplicación que puede usar User Pool ###
resource "aws_cognito_user_pool_client" "app_client" {
  name         = var.app_client_name
  user_pool_id = aws_cognito_user_pool.user_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
    
  ]
  ### duracion de los tokens ###
  access_token_validity  = 1          
  id_token_validity      = 1
  refresh_token_validity = 30

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

output "user_pool_id" {
  value = aws_cognito_user_pool.user_pool.id
}

output "user_pool_client_id" {
  value = aws_cognito_user_pool_client.app_client.id
}