# - `kke_elasticsearch_endpoint`: returns the endpoint of the Elasticsearch domain
output "kke_elasticsearch_endpoint" {
  value = aws_elasticsearch_domain.elasticsearch_domain.endpoint
}