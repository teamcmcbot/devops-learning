# Task 016: Create IAM User

When establishing infrastructure on the AWS cloud, Identity and Access Management (IAM) is among the first and most critical services to configure. IAM facilitates the creation and management of user accounts, groups, roles, policies, and other access controls. The Nautilus DevOps team is currently in the process of configuring these resources and has outlined the following requirements:

For this task, create an IAM user named `iamuser_mariyam`.

## Solution

1. Log in to the AWS Management Console.
2. Navigate to the IAM (Identity and Access Management) service.
3. In the left-hand menu, click on "Users".
4. Click on the "Add user" button.
5. Enter the username as `iamuser_mariyam`.
6. Leave the rest of the settings as default (i.e., Programmatic access and AWS Management Console access unchecked).
7. Click on "Next: Permissions".
8. Click on "Next: Tags" without adding any permissions or tags.
9. Click on "Next: Review".
10. Review the user details and click on "Create user".
11. Verify that the user `iamuser_mariyam` has been created successfully.
