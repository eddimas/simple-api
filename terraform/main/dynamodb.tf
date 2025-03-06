resource "aws_dynamodb_table" "processed_data" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"

  hash_key  = var.dynamodb_table_hash_key
  range_key = var.dynamodb_table_sort_key

  attribute {
    name = var.dynamodb_table_hash_key
    type = "S"
  }

  attribute {
    name = var.dynamodb_table_sort_key
    type = "S"
  }
}
