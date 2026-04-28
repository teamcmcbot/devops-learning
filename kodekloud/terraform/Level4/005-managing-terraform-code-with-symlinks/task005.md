# Task 005: Managing Terraform Code with Symlinks

The nautilus team is building a Terraform-based AWS pipeline using strict modular design, symbolic links for configuration reuse, and a sequential resource flow

1. Create modules under `modules/` named:

- **SNS Module**: Create an SNS topic named `nautilus-sns-topic`.
- **SSM Module**: Create an SSM Parameter named `nautilus-param` storing the ARN of the SNS topic from the SNS module. The SSM parameter should be of type `String`.
- **Step Functions Module**: Create a Step Functions state machine named `nautilus-stepfunction` that retrieves the SNS topic ARN from the SSM Parameter. The Step Function should have an IAM role with a policy allowing `ssm:GetParameter` access to read the parameter.

2. Use `symbolic links` to reuse the root `variables.tf` file across all modules (no duplicated variable declarations inside module main.tf files). Ensure the symlink uses an absolute path.

3. Create a single `main.tf` in the root to orchestrate the module calls in sequence SNS → SSM → Step Functions. Pass the SNS ARN output from the SNS module to the SSM module, and the SSM parameter name output from the SSM module to the Step Functions module.

4. Use the `depends_on` feature so that SSM depends on SNS and StepFunctions depend on SSM.

5. Use `variables.tf` file with the following variable names:

- `KKE_SNS_TOPIC_NAME`: name of the SNS topic.
- `KKE_SSM_PARAM_NAME`: SSM parameter name.
- `KKE_STEP_FUNCTION_NAME`: Step Function name.

6. Use `terraform.tfvars` file to input the values of the variables.

7) Use `outputs.tf` file with the following variables:

- `kke_sns_topic_name`: name of the SNS topic created.
- `kke_ssm_parameter_name`: name of the SSM parameter created.
- `kke_step_function_name`: name of the Step Function created.

8. **Additional implementation hints**:

- **SNS Module**: output both name and ARN of the topic.
- **SSM Module**: set the value of the parameter to the SNS ARN received from the SNS module. Also, ensure the SSM parameter implementation creates a direct Terraform dependency on the SNS topic so that the dependency is visible in the Terraform graph.
- **Step Functions Module**: create an IAM role and policy allowing `ssm:GetParameter`, then assign the role to the state machine. The Step Function can use a simple placeholder definition (e.g., Pass state) for this task.

Sample Solution: https://kodekloud.com/community/t/terraform-level-4-task-5-validation-failed/490295/32

## Setup folders and empty files

```bash
export ROOT_DIR="/home/bob/terraform"
cd $ROOT_DIR
mkdir -p modules/sns
mkdir -p modules/ssm
mkdir -p modules/stepfunctions

# root files
touch main.tf outputs.tf variables.tf terraform.tfvars 

# modules files 
cd $ROOT_DIR/modules
touch sns/main.tf sns/outputs.tf
touch ssm/main.tf ssm/outputs.tf
touch stepfunctions/main.tf stepfunctions/outputs.tf


# Create Symlinks of variables.tf to modules
cd $ROOT_DIR
ln -s "$ROOT_DIR/variables.tf" "$ROOT_DIR/modules/sns/variables.tf"
ln -s "$ROOT_DIR/variables.tf" "$ROOT_DIR/modules/ssm/variables.tf"
ln -s "$ROOT_DIR/variables.tf" "$ROOT_DIR/modules/stepfunctions/variables.tf"

# Verify links
ls -l $ROOT_DIR/modules/sns/
ls -l $ROOT_DIR/modules/ssm/
ls -l $ROOT_DIR/modules/stepfunctions/
```

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # module.sns.aws_sns_topic.this will be created
  + resource "aws_sns_topic" "this" {
      + arn                         = (known after apply)
      + beginning_archive_time      = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "nautilus-sns-topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

  # module.ssm.aws_ssm_parameter.this will be created
  + resource "aws_ssm_parameter" "this" {
      + arn            = (known after apply)
      + data_type      = (known after apply)
      + has_value_wo   = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + key_id         = (known after apply)
      + name           = "nautilus-param"
      + tags_all       = (known after apply)
      + tier           = (known after apply)
      + type           = "String"
      + value          = (sensitive value)
      + value_wo       = (write-only attribute)
      + version        = (known after apply)
    }

  # module.stepfunctions.data.aws_ssm_parameter.sns_param will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "aws_ssm_parameter" "sns_param" {
      + arn            = (known after apply)
      + id             = (known after apply)
      + insecure_value = (known after apply)
      + name           = "nautilus-param"
      + type           = (known after apply)
      + value          = (sensitive value)
      + version        = (known after apply)
    }

  # module.stepfunctions.aws_iam_role.sfn_role will be created
  + resource "aws_iam_role" "sfn_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "states.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "nautilus-stepfunction-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy (known after apply)
    }

  # module.stepfunctions.aws_iam_role_policy.sfn_policy will be created
  + resource "aws_iam_role_policy" "sfn_policy" {
      + id          = (known after apply)
      + name        = "nautilus-stepfunction-policy"
      + name_prefix = (known after apply)
      + policy      = (known after apply)
      + role        = (known after apply)
    }

  # module.stepfunctions.aws_sfn_state_machine.this will be created
  + resource "aws_sfn_state_machine" "this" {
      + arn                       = (known after apply)
      + creation_date             = (known after apply)
      + definition                = jsonencode(
            {
              + StartAt = "ReadSSM"
              + States  = {
                  + ReadSSM = {
                      + End            = true
                      + Parameters     = {
                          + Name           = "nautilus-param"
                          + WithDecryption = false
                        }
                      + Resource       = "arn:aws:states:::aws-sdk:ssm:getParameter"
                      + ResultSelector = {
                          + "SnsArn.$" = "$.Parameter.Value"
                        }
                      + Type           = "Task"
                    }
                }
            }
        )
      + description               = (known after apply)
      + id                        = (known after apply)
      + name                      = "nautilus-stepfunction"
      + name_prefix               = (known after apply)
      + publish                   = false
      + revision_id               = (known after apply)
      + role_arn                  = (known after apply)
      + state_machine_version_arn = (known after apply)
      + status                    = (known after apply)
      + tags_all                  = (known after apply)
      + type                      = "STANDARD"
      + version_description       = (known after apply)

      + encryption_configuration (known after apply)

      + logging_configuration (known after apply)

      + tracing_configuration (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_sns_topic_arn      = (known after apply)
  + kke_sns_topic_name     = "nautilus-sns-topic"
  + kke_ssm_parameter_name = "nautilus-param"
  + kke_step_function_name = "nautilus-stepfunction"
module.sns.aws_sns_topic.this: Creating...
module.sns.aws_sns_topic.this: Creation complete after 1s [id=arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic]
module.ssm.aws_ssm_parameter.this: Creating...
module.ssm.aws_ssm_parameter.this: Creation complete after 0s [id=nautilus-param]
module.stepfunctions.data.aws_ssm_parameter.sns_param: Reading...
module.stepfunctions.aws_iam_role.sfn_role: Creating...
module.stepfunctions.data.aws_ssm_parameter.sns_param: Read complete after 0s [id=nautilus-param]
module.stepfunctions.aws_iam_role.sfn_role: Creation complete after 0s [id=nautilus-stepfunction-role]
module.stepfunctions.aws_iam_role_policy.sfn_policy: Creating...
module.stepfunctions.aws_sfn_state_machine.this: Creating...
module.stepfunctions.aws_iam_role_policy.sfn_policy: Creation complete after 0s [id=nautilus-stepfunction-role:nautilus-stepfunction-policy]
module.stepfunctions.aws_sfn_state_machine.this: Creation complete after 0s [id=arn:aws:states:us-east-1:000000000000:stateMachine:nautilus-stepfunction]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
kke_sns_topic_name = "nautilus-sns-topic"
kke_ssm_parameter_name = "nautilus-param"
kke_step_function_name = "nautilus-stepfunction"
```

## Verification

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# module.sns.aws_sns_topic.this:
resource "aws_sns_topic" "this" {
    application_failure_feedback_role_arn    = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = 0
    archive_policy                           = null
    arn                                      = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
    beginning_archive_time                   = null
    content_based_deduplication              = false
    delivery_policy                          = null
    display_name                             = null
    fifo_topic                               = false
    firehose_failure_feedback_role_arn       = null
    firehose_success_feedback_role_arn       = null
    firehose_success_feedback_sample_rate    = 0
    http_failure_feedback_role_arn           = null
    http_success_feedback_role_arn           = null
    http_success_feedback_sample_rate        = 0
    id                                       = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
    kms_master_key_id                        = null
    lambda_failure_feedback_role_arn         = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = 0
    name                                     = "nautilus-sns-topic"
    name_prefix                              = null
    owner                                    = "000000000000"
    policy                                   = jsonencode(
        {
            Id        = "__default_policy_ID"
            Statement = [
                {
                    Action    = [
                        "SNS:GetTopicAttributes",
                        "SNS:SetTopicAttributes",
                        "SNS:AddPermission",
                        "SNS:RemovePermission",
                        "SNS:DeleteTopic",
                        "SNS:Subscribe",
                        "SNS:ListSubscriptionsByTopic",
                        "SNS:Publish",
                    ]
                    Condition = {
                        StringEquals = {
                            "AWS:SourceOwner" = "000000000000"
                        }
                    }
                    Effect    = "Allow"
                    Principal = {
                        AWS = "*"
                    }
                    Resource  = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
                    Sid       = "__default_statement_ID"
                },
            ]
            Version   = "2008-10-17"
        }
    )
    signature_version                        = 0
    sqs_failure_feedback_role_arn            = null
    sqs_success_feedback_role_arn            = null
    sqs_success_feedback_sample_rate         = 0
    tags_all                                 = {}
    tracing_config                           = null
}
# module.ssm.aws_ssm_parameter.this:
resource "aws_ssm_parameter" "this" {
    allowed_pattern = null
    arn             = "arn:aws:ssm:us-east-1:000000000000:parameter/nautilus-param"
    data_type       = "text"
    description     = null
    id              = "nautilus-param"
    key_id          = null
    name            = "nautilus-param"
    tags_all        = {}
    tier            = null
    type            = "String"
    value           = (sensitive value)
    value_wo        = (write-only attribute)
    version         = 1
}
# module.stepfunctions.data.aws_ssm_parameter.sns_param:
data "aws_ssm_parameter" "sns_param" {
    arn             = "arn:aws:ssm:us-east-1:000000000000:parameter/nautilus-param"
    id              = "nautilus-param"
    insecure_value  = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
    name            = "nautilus-param"
    type            = "String"
    value           = (sensitive value)
    version         = 1
    with_decryption = true
}

# module.stepfunctions.aws_iam_role.sfn_role:
resource "aws_iam_role" "sfn_role" {
    arn                   = "arn:aws:iam::000000000000:role/nautilus-stepfunction-role"
    assume_role_policy    = jsonencode(
        {
            Statement = [
                {
                    Action    = "sts:AssumeRole"
                    Effect    = "Allow"
                    Principal = {
                        Service = "states.amazonaws.com"
                    }
                },
            ]
            Version   = "2012-10-17"
        }
    )
    create_date           = "2026-04-28T17:54:58Z"
    description           = null
    force_detach_policies = false
    id                    = "nautilus-stepfunction-role"
    managed_policy_arns   = []
    max_session_duration  = 3600
    name                  = "nautilus-stepfunction-role"
    name_prefix           = null
    path                  = "/"
    permissions_boundary  = null
    tags_all              = {}
    unique_id             = "AROAQAAAAAAAE2JHD54YC"
}

# module.stepfunctions.aws_iam_role_policy.sfn_policy:
resource "aws_iam_role_policy" "sfn_policy" {
    id          = "nautilus-stepfunction-role:nautilus-stepfunction-policy"
    name        = "nautilus-stepfunction-policy"
    name_prefix = null
    policy      = jsonencode(
        {
            Statement = [
                {
                    Action   = [
                        "ssm:GetParameter",
                    ]
                    Effect   = "Allow"
                    Resource = "arn:aws:ssm:us-east-1:000000000000:parameter/nautilus-param"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    role        = "nautilus-stepfunction-role"
}

# module.stepfunctions.aws_sfn_state_machine.this:
resource "aws_sfn_state_machine" "this" {
    arn                       = "arn:aws:states:us-east-1:000000000000:stateMachine:nautilus-stepfunction"
    creation_date             = "2026-04-28T17:54:58Z"
    definition                = jsonencode(
        {
            StartAt = "ReadSSM"
            States  = {
                ReadSSM = {
                    End            = true
                    Parameters     = {
                        Name           = "nautilus-param"
                        WithDecryption = false
                    }
                    Resource       = "arn:aws:states:::aws-sdk:ssm:getParameter"
                    ResultSelector = {
                        "SnsArn.$" = "$.Parameter.Value"
                    }
                    Type           = "Task"
                }
            }
        }
    )
    description               = null
    id                        = "arn:aws:states:us-east-1:000000000000:stateMachine:nautilus-stepfunction"
    name                      = "nautilus-stepfunction"
    name_prefix               = null
    publish                   = false
    revision_id               = null
    role_arn                  = "arn:aws:iam::000000000000:role/nautilus-stepfunction-role"
    state_machine_version_arn = null
    status                    = "ACTIVE"
    tags_all                  = {}
    type                      = "STANDARD"

    logging_configuration {
        include_execution_data = false
        level                  = "OFF"
        log_destination        = null
    }
}


Outputs:

kke_sns_topic_arn = "arn:aws:sns:us-east-1:000000000000:nautilus-sns-topic"
kke_sns_topic_name = "nautilus-sns-topic"
kke_ssm_parameter_name = "nautilus-param"
kke_step_function_name = "nautilus-stepfunction"
```

```bash

```