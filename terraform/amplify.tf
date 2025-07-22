resource "aws_amplify_app" "main" {
  name       = var.app_name
  repository = var.repository_url

  access_token = var.github_access_token

  platform = "WEB"

  enable_branch_auto_build    = false
  enable_branch_auto_deletion = false
  enable_basic_auth           = false

  build_spec = <<-EOT
version: 1
backend:
  phases:
    build:
      commands:
        - npm ci --cache .npm --prefer-offline
        - npx ampx pipeline-deploy --branch $AWS_BRANCH --app-id $AWS_APP_ID
frontend:
  phases:
    build:
      commands:
        - mkdir ./dist && touch ./dist/index.html
  artifacts:
    baseDirectory: dist
    files:
      - '**/*'
  cache:
    paths:
      - .npm/**/*
EOT

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  iam_service_role_arn = aws_iam_role.amplify_service.arn

  tags = {
    Name        = var.app_name
    Environment = var.environment
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.main.id
  branch_name = "main"

  framework                = "Web"
  stage                   = "PRODUCTION"
  enable_notification     = false
  enable_auto_build       = true
  enable_basic_auth       = false
  enable_performance_mode = false
  ttl                     = "5"
  enable_pull_request_preview = false

  tags = {
    Name        = "${var.app_name}-main-branch"
    Environment = var.environment
  }
}
