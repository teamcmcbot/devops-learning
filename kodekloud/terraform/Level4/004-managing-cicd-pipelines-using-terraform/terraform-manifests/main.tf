locals {
  project_name          = "xfusion"
  dynamodb_table_name   = coalesce(var.KKE_DYNAMODB_TABLE_NAME, "${local.project_name}-${var.KKE_ENV}-table")
  secret_name           = coalesce(var.KKE_SECRET_NAME, "${local.project_name}-${var.KKE_ENV}-secret")
  secret_value          = coalesce(var.KKE_SECRET_VALUE, "${local.project_name}-${var.KKE_ENV}-value")
  elasticsearch_domain  = coalesce(var.KKE_ELASTICSEARCH_DOMAIN, "${local.project_name}-${var.KKE_ENV}-es")
}

module "dynamodb" {
  source     = "./modules/dynamodb"
  KKE_ENV = var.KKE_ENV
  KKE_DYNAMODB_TABLE_NAME = local.dynamodb_table_name
}

module "secretsmanager" {
  source       = "./modules/secretsmanager"
  KKE_ENV = var.KKE_ENV
  KKE_SECRET_NAME  = local.secret_name
  KKE_SECRET_VALUE = local.secret_value
}

module "elasticsearch" {
  source      = "./modules/elasticsearch"
  KKE_ENV = var.KKE_ENV
  KKE_ELASTICSEARCH_DOMAIN = local.elasticsearch_domain
}

# Outputs
# kke_table_name:exposes the name of the created DynamoDB table
output "kke_table_name" {
  value = module.dynamodb.kke_table_name
}
# kke_secret_arn :provides the ARN of the Secrets Manager secret
output "kke_secret_arn" {
  value = module.secretsmanager.kke_secret_arn
}
# kke_elasticsearch_endpoint: returns the endpoint of the Elasticsearch domain
output "kke_elasticsearch_endpoint" {
  value = module.elasticsearch.kke_elasticsearch_endpoint
}
