
# Requirement 4: Use count to create API Gateway resources.
# Requirement 8: Use KKE_API_NAMES list variable as the source of API names.
resource "aws_api_gateway_rest_api" "kke_api" {
  count = length(var.KKE_API_NAMES)

  # Requirement 2 and 5: Prefix API name with current workspace.
  name = "${terraform.workspace}-${var.KKE_API_NAMES[count.index]}"

  # Requirement 6 and 7: Log API creation events to /home/bob/terraform/apigateway.log.
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p /home/bob/terraform
      echo "Created API Gateway ${self.name} in workspace ${terraform.workspace}" >> /home/bob/terraform/apigateway.log
    EOT
  }
}

# Requirement 3: Create matching CloudWatch Log Group names for each API.
# Requirement 4: Use count to create matching log groups.
resource "aws_cloudwatch_log_group" "kke_api_logs" {
  count = length(var.KKE_API_NAMES)

  name = "/aws/apigateway/${aws_api_gateway_rest_api.kke_api[count.index].name}"

  # Requirement 6 and 7: Log log-group creation events to /home/bob/terraform/loggroups.log.
  provisioner "local-exec" {
    command = <<-EOT
      mkdir -p /home/bob/terraform
      echo "Created Log Group ${self.name} in workspace ${terraform.workspace}" >> /home/bob/terraform/loggroups.log
    EOT
  }
}