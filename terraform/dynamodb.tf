resource "aws_dynamodb_table" "todo" {
  name           = "${var.app_name}-Todo-${random_id.table_suffix.hex}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.app_name}-todo-table"
    Environment = var.environment
  }
}

resource "random_id" "table_suffix" {
  byte_length = 4
}
