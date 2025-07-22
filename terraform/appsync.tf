resource "aws_appsync_graphql_api" "main" {
  authentication_type = "AWS_IAM"
  name                = "${var.app_name}-api"

  schema = <<EOF
type Todo @aws_iam {
  id: ID!
  content: String
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

type Query {
  getTodo(id: ID!): Todo @aws_iam
  listTodos: [Todo] @aws_iam
}

type Mutation {
  createTodo(input: CreateTodoInput!): Todo @aws_iam
  updateTodo(input: UpdateTodoInput!): Todo @aws_iam
  deleteTodo(input: DeleteTodoInput!): Todo @aws_iam
}

input CreateTodoInput {
  content: String
}

input UpdateTodoInput {
  id: ID!
  content: String
}

input DeleteTodoInput {
  id: ID!
}

type Subscription {
  onCreateTodo: Todo @aws_subscribe(mutations: ["createTodo"]) @aws_iam
  onUpdateTodo: Todo @aws_subscribe(mutations: ["updateTodo"]) @aws_iam
  onDeleteTodo: Todo @aws_subscribe(mutations: ["deleteTodo"]) @aws_iam
}
EOF

  tags = {
    Name        = "${var.app_name}-graphql-api"
    Environment = var.environment
  }
}

resource "aws_appsync_datasource" "todo_table" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "TodoTable"
  service_role_arn = aws_iam_role.appsync_dynamodb.arn
  type             = "AMAZON_DYNAMODB"

  dynamodb_config {
    table_name = aws_dynamodb_table.todo.name
  }
}

resource "aws_appsync_resolver" "get_todo" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "getTodo"
  type        = "Query"
  data_source = aws_appsync_datasource.todo_table.name

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "GetItem",
    "key": {
        "id": $util.dynamodb.toDynamoDBJson($ctx.args.id)
    }
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "list_todos" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "listTodos"
  type        = "Query"
  data_source = aws_appsync_datasource.todo_table.name

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "Scan"
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result.items)
EOF
}

resource "aws_appsync_resolver" "create_todo" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "createTodo"
  type        = "Mutation"
  data_source = aws_appsync_datasource.todo_table.name

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "PutItem",
    "key": {
        "id": $util.dynamodb.toDynamoDBJson($util.autoId())
    },
    "attributeValues": {
        "content": $util.dynamodb.toDynamoDBJson($ctx.args.input.content),
        "createdAt": $util.dynamodb.toDynamoDBJson($util.time.nowISO8601()),
        "updatedAt": $util.dynamodb.toDynamoDBJson($util.time.nowISO8601())
    }
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "update_todo" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "updateTodo"
  type        = "Mutation"
  data_source = aws_appsync_datasource.todo_table.name

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "UpdateItem",
    "key": {
        "id": $util.dynamodb.toDynamoDBJson($ctx.args.input.id)
    },
    "update": {
        "expression": "SET content = :content, updatedAt = :updatedAt",
        "expressionValues": {
            ":content": $util.dynamodb.toDynamoDBJson($ctx.args.input.content),
            ":updatedAt": $util.dynamodb.toDynamoDBJson($util.time.nowISO8601())
        }
    }
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "delete_todo" {
  api_id      = aws_appsync_graphql_api.main.id
  field       = "deleteTodo"
  type        = "Mutation"
  data_source = aws_appsync_datasource.todo_table.name

  request_template = <<EOF
{
    "version": "2017-02-28",
    "operation": "DeleteItem",
    "key": {
        "id": $util.dynamodb.toDynamoDBJson($ctx.args.input.id)
    }
}
EOF

  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}
