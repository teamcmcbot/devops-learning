# Task 019 - Attach IAM Policy to IAM User

The Nautilus DevOps team has been creating a couple of services on AWS cloud. They have been breaking down the migration into smaller tasks, allowing for better control, risk mitigation, and optimization of resources throughout the migration process. Recently they came up with requirements mentioned below.

An IAM user named `iamuser_james` and a policy named `iampolicy_james` already exist. Attach the IAM policy `iampolicy_james` to the IAM user `iamuser_james`.

## Instructions

1. Log in to the AWS Management Console.
2. Navigate to the IAM > Policies section and locate the policy named `iampolicy_james`.
3. Select `iampolicy_james` and click on `Entities attached` tab.
4. In `Attached as a permissions policy` section, click on `Attach` button.
5. In the search box, type `iamuser_james` to find the user.
6. Select the checkbox next to `iamuser_james`.
7. Click on the `Attach policy` button to complete the process.
8. In IAM > User > `iamuser_james`, verify that the policy `iampolicy_james` is listed under the `Permissions policies` tab.
