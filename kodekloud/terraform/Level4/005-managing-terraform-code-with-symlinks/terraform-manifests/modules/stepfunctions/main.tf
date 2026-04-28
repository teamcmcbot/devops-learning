data "aws_ssm_parameter" "sns_param" {
  name = var.KKE_SSM_PARAM_NAME
}

resource "aws_iam_role" "sfn_role" {
  name = "${var.KKE_STEP_FUNCTION_NAME}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "sfn_policy" {
  name   = "${var.KKE_STEP_FUNCTION_NAME}-policy"
  role   = aws_iam_role.sfn_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = data.aws_ssm_parameter.sns_param.arn
      }
    ]
  })
}

resource "aws_sfn_state_machine" "this" {
  name     = var.KKE_STEP_FUNCTION_NAME
  role_arn = aws_iam_role.sfn_role.arn
  # definition = jsonencode({
  #   StartAt = "ReadSSM"
  #   States = {
  #     ReadSSM = {
  #       Type   = "Pass"
  #       Result = {
  #         SSMParamName = var.KKE_SSM_PARAM_NAME
  #       }
  #       End = true
  #     }
  #   }
  # })

  # Actually read the SSM parameter value at runtime
  definition = jsonencode({
  StartAt = "ReadSSM"
  States = {
    ReadSSM = {
      Type     = "Task"
      Resource = "arn:aws:states:::aws-sdk:ssm:getParameter"
      Parameters = {
        Name           = var.KKE_SSM_PARAM_NAME
        WithDecryption = false
      }
      ResultSelector = {
        "SnsArn.$" = "$.Parameter.Value"
      }
      End = true
    }
  }
})
}