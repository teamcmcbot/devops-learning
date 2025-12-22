resource "aws_opensearch_domain" "devops-es" {
  domain_name = "devops-es"
}

# Output arn and domain_name
output "opensearch_domain_arn" {
  value = aws_opensearch_domain.devops-es.arn
}
output "opensearch_domain_name" {
  value = aws_opensearch_domain.devops-es.domain_name
}
