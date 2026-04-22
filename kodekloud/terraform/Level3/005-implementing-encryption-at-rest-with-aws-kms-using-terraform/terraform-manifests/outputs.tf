# - `kke_kms_key_name`: name of the key created.
output "kke_kms_key_name" {
  value = trimprefix(aws_kms_alias.xfusion_kms_key_alias.name, "alias/")
}