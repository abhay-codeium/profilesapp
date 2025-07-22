output "amplify_app_id" {
  description = "Amplify App ID"
  value       = aws_amplify_app.main.id
}

output "amplify_default_domain" {
  description = "Amplify default domain"
  value       = aws_amplify_app.main.default_domain
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "cognito_identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = aws_cognito_identity_pool.main.id
}

output "appsync_graphql_url" {
  description = "AppSync GraphQL URL"
  value       = aws_appsync_graphql_api.main.uris["GRAPHQL"]
}

output "appsync_api_id" {
  description = "AppSync API ID"
  value       = aws_appsync_graphql_api.main.id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.todo.name
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}
