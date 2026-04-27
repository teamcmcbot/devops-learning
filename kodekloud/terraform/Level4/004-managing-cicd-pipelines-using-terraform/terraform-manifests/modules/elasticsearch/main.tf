# - **elasticsearch**: to provision an Elasticsearch domain named `xfusion-<env>-es`.
resource "aws_elasticsearch_domain" "elasticsearch_domain" {
  domain_name           = "${var.KKE_ELASTICSEARCH_DOMAIN}"
  elasticsearch_version = "7.10"

  cluster_config {
    instance_type  = "t3.small.elasticsearch"
    instance_count = 1
  }

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
  
  tags = {
    Environment = "${var.KKE_ENV}"
  }
}