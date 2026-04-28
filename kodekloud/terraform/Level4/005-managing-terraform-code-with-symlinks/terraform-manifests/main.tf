module "sns" {
  source = "./modules/sns"
  KKE_SSM_PARAM_NAME = var.KKE_SSM_PARAM_NAME
  KKE_SNS_TOPIC_NAME = var.KKE_SNS_TOPIC_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME
}

module "ssm" {
  source     = "./modules/ssm"
  SNS_TOPIC_ARN = module.sns.kke_sns_topic_arn
  KKE_SSM_PARAM_NAME = var.KKE_SSM_PARAM_NAME
  KKE_SNS_TOPIC_NAME = var.KKE_SNS_TOPIC_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME
  depends_on = [module.sns]
}

module "stepfunctions" {
  source     = "./modules/stepfunctions"
  KKE_SSM_PARAM_NAME = module.ssm.kke_ssm_parameter_name
  KKE_SNS_TOPIC_NAME = var.KKE_SNS_TOPIC_NAME
  KKE_STEP_FUNCTION_NAME = var.KKE_STEP_FUNCTION_NAME
  depends_on = [module.ssm]
}