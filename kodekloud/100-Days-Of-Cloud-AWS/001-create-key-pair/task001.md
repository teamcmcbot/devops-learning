# Task 001: Create Key Pair

The Nautilus DevOps team is strategizing the migration of a portion of their infrastructure to the AWS cloud. Recognizing the scale of this undertaking, they have opted to approach the migration in incremental steps rather than as a single massive transition. To achieve this, they have segmented large tasks into smaller, more manageable units. This granular approach enables the team to execute the migration in gradual phases, ensuring smoother implementation and minimizing disruption to ongoing operations. By breaking down the migration into smaller tasks, the Nautilus DevOps team can systematically progress through each stage, allowing for better control, risk mitigation, and optimization of resources throughout the migration process.

For this task, create a key pair with the following requirements:

Name of the key pair should be devops-kp.

Key pair type must be rsa

## Solution

```bash
~ on ☁️  (us-east-1) ➜  aws ec2 create-key-pair --key-name devops-kp --key-type rsa
{
    "KeyPairId": "key-04c97c3376d9e74eb",
    "KeyName": "devops-kp",
    "KeyFingerprint": "93:94:60:59:c7:2b:1e:5b:94:17:65:cf:3d:a5:86:05:90:42:e5:2f",
    "KeyMaterial": "[PRIVATE KEY DATA HIDDEN FOR SECURITY REASONS]"
}

~ on ☁️  (us-east-1) ➜  aws ec2 describe-key-pairs
{
    "KeyPairs": [
        {
            "KeyPairId": "key-04c97c3376d9e74eb",
            "KeyType": "rsa",
            "Tags": [],
            "CreateTime": "2025-11-25T05:35:00.095Z",
            "KeyName": "devops-kp",
            "KeyFingerprint": "93:94:60:59:c7:2b:1e:5b:94:17:65:cf:3d:a5:86:05:90:42:e5:2f"
        }
    ]
}

~ on ☁️  (us-east-1) ➜
```
