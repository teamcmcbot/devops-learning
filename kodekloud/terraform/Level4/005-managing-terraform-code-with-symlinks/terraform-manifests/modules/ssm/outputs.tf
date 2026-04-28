# - `kke_ssm_parameter_name`: name of the SSM parameter created.
output "kke_ssm_parameter_name" {
  value = aws_ssm_parameter.this.name
}
