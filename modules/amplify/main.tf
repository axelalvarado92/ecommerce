resource "aws_amplify_app" "frontend" {
  name         = "${var.project_name}-${var.environment}-frontend"
  repository   = var.repository
  access_token = var.access_token

  build_spec = <<-EOT
    version: 1
frontend:
  phases:
    preBuild:
      commands:
        - npm install
    build:
      commands:
        - npm run build
  artifacts:
    baseDirectory: build
    files:
      - '**/*'
  cache:
    paths:
      - node_modules/**/*
  EOT

  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }

  environment_variables = {
    ENV = var.environment
  }
}

resource "aws_amplify_branch" "frontend_branch" {

  app_id      = aws_amplify_app.frontend.id
  branch_name = var.branch_name

  framework = "React"

  stage = "DEVELOPMENT"

  environment_variables = {
    REACT_APP_API_SERVER = var.api_url
  }
}

output "amplify_app_id" {
  value = aws_amplify_app.frontend.id
}

output "amplify_default_domain" {
  value = aws_amplify_app.frontend.default_domain
}