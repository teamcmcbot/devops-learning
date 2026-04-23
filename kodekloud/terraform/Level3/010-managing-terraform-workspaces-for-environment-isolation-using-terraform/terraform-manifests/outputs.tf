# - `kke_api_gateway_names`= name of the api gateway created.
output "kke_api_gateway_names" {
  value = aws_api_gateway_rest_api.kke_api[*].name
}
# - `kke_log_group_names`= name of the matching logroups created.
output "kke_log_group_names" {
  value = aws_cloudwatch_log_group.kke_api_logs[*].name
}