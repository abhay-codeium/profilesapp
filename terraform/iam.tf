resource "aws_iam_role" "amplify_service" {
  name = "${var.app_name}-amplify-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-amplify-service-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "amplify_service_backend_deploy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmplifyBackendDeployFullAccess"
  role       = aws_iam_role.amplify_service.name
}

resource "aws_iam_role" "cognito_authenticated" {
  name = "${var.app_name}-cognito-authenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-cognito-authenticated-role"
    Environment = var.environment
  }
}

resource "aws_iam_role" "cognito_unauthenticated" {
  name = "${var.app_name}-cognito-unauthenticated-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "unauthenticated"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-cognito-unauthenticated-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "cognito_authenticated_policy" {
  name = "${var.app_name}-cognito-authenticated-policy"
  role = aws_iam_role.cognito_authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "appsync:GraphQL"
        ]
        Resource = "${aws_appsync_graphql_api.main.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cognito_unauthenticated_policy" {
  name = "${var.app_name}-cognito-unauthenticated-policy"
  role = aws_iam_role.cognito_unauthenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "appsync:GraphQL"
        ]
        Resource = "${aws_appsync_graphql_api.main.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role" "appsync_dynamodb" {
  name = "${var.app_name}-appsync-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.app_name}-appsync-dynamodb-role"
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "appsync_dynamodb_policy" {
  name = "${var.app_name}-appsync-dynamodb-policy"
  role = aws_iam_role.appsync_dynamodb.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.todo.arn
      }
    ]
  })
}
