resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "${var.project_name}-${var.environment}-dynamodb"
  billing_mode   = var.billing_mode
  hash_key       = "PK"
  range_key      = "SK"

  attribute {
    name = "PK"
    type = "S"
  }

  attribute {
    name = "SK"
    type = "S"
  }

  attribute {
  name = "GSI1PK"
  type = "S"
}

  attribute {
  name = "GSI1SK"
  type = "S"
}

  attribute {
  name = "GSI2PK"
  type = "S"
}

  attribute {
  name = "GSI2SK"
  type = "S"
}

  attribute {
  name = "GSI3PK"
  type = "S"
}

  attribute {
  name = "GSI3SK"
  type = "S"
}
### para mejor escala y que no haya colision entre entidades, ej: usuario, empresa, admin, etc ###
global_secondary_index {
  name            = "GSI1"
  hash_key        = "GSI1PK"
  range_key       = "GSI1SK"
  projection_type = "ALL"
}

global_secondary_index {
  name            = "GSI2"
  hash_key        = "GSI2PK"
  range_key       = "GSI2SK"
  projection_type = "ALL"
}
### aqui uso un GSI3 para el "status" y saber como va la orden ###
global_secondary_index {
  name            = "GSI3"
  hash_key        = "GSI3PK"
  range_key       = "GSI3SK"
  projection_type = "ALL"
}
 
   ttl {
    attribute_name = "ExpiresAt"
    enabled        = true
   }

  tags = {
    Name        = var.project_name
    Environment = var.environment
  }
}

### output para que lambda puede leer recurso aws_dynamodb_table ###
output "table_name" {
  value = aws_dynamodb_table.basic-dynamodb-table.name
}

output "table_arn" {
  value = aws_dynamodb_table.basic-dynamodb-table.arn
}