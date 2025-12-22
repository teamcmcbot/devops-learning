# Task 018: Create Read-Only IAM Policy for EC2 Console Access

When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements.

Create an IAM policy named `iampolicy_ravi` in us-east-1 region, it must allow read-only access to the EC2 console, i.e this policy must allow users to view all instances, AMIs, and snapshots in the Amazon EC2 console.

## Instructions

1. Log in to the AWS Management Console.
2. Navigate to the IAM > Policies section.
3. Click on "Create policy".
4. Select the "JSON" tab and input the following policy document:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:DescribeImages",
        "ec2:DescribeSnapshots"
      ],
      "Resource": "*"
    }
  ]
}
```

5. Review the policy and name it `iampolicy_ravi`.
