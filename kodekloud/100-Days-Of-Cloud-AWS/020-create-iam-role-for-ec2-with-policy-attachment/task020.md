# Task 020 - Create IAM Role for EC2 with Policy Attachment

When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements:

Create an IAM role as below:

1. IAM role name must be `iamrole_ravi`.

2. Entity type must be AWS Service and use case must be EC2.

3. Attach a policy named `iampolicy_ravi`.

## Solution

1. Log in to the AWS Management Console.
2. Navigate to the IAM > Roles section.
3. Click on the `Create role` button.
4. Select `AWS service` as the trusted entity type.
5. Choose `EC2` as the use case and click on the `Next` button
6. In the `Attach permissions policies` section, search for the policy named `iampolicy_ravi`.
7. Select the checkbox next to `iampolicy_ravi` and click next.
8. In the `Set role name` section, enter `iamrole_ravi` as the role name.
9. Click on the `Create role` button to complete the process.
10. In IAM > Roles > `iamrole_ravi`, verify that the policy `iampolicy_ravi` is listed under the `Permissions policies` tab.
