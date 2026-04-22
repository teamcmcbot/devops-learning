# Task 005: Implementing Encryption at Rest with AWS KMS Using Terraform

The Nautilus DevOps team is focusing on improving their data security by using AWS KMS. Your task is to create a KMS key and manage the encryption and decryption of a pre-existing sensitive file using the KMS key.

Specific Requirements:

1. Create a symmetric KMS key named `xfusion-kms-key` to manage encryption and decryption.

2. Encrypt the provided `SensitiveData.txt` file (located in `/home/bob/terraform`), base64 encode the ciphertext, and save the encrypted version as `EncryptedData.bin` in the `/home/bob/terraform` directory.

3. Try to decrypt the same and verify that the decrypted data matches the original file.

4. Create `main.tf file` (do not create a separate .tf file) to provision a KMS key, encrypt and decrypt the file.

5. Create `outputs.tf` file to output the following:

- `kke_kms_key_name`: name of the key created.

## Solution

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform apply -auto-approve

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.aws_kms_secrets.decrypt will be read during apply
  # (config refers to values not yet known)
 <= data "aws_kms_secrets" "decrypt" {
      + id        = (known after apply)
      + plaintext = (sensitive value)

      + secret {
          + name    = "decrypted_data"
          + payload = (known after apply)
        }
    }

  # aws_kms_alias.xfusion_kms_key_alias will be created
  + resource "aws_kms_alias" "xfusion_kms_key_alias" {
      + arn            = (known after apply)
      + id             = (known after apply)
      + name           = "alias/xfusion-kms-key"
      + name_prefix    = (known after apply)
      + target_key_arn = (known after apply)
      + target_key_id  = (known after apply)
    }

  # aws_kms_ciphertext.encrypt will be created
  + resource "aws_kms_ciphertext" "encrypt" {
      + ciphertext_blob = (known after apply)
      + id              = (known after apply)
      + key_id          = (known after apply)
      + plaintext       = (sensitive value)
    }

  # aws_kms_key.xfusion_kms_key will be created
  + resource "aws_kms_key" "xfusion_kms_key" {
      + arn                                = (known after apply)
      + bypass_policy_lockout_safety_check = false
      + customer_master_key_spec           = "SYMMETRIC_DEFAULT"
      + deletion_window_in_days            = 20
      + description                        = "An example symmetric encryption KMS key"
      + enable_key_rotation                = true
      + id                                 = (known after apply)
      + is_enabled                         = true
      + key_id                             = (known after apply)
      + key_usage                          = "ENCRYPT_DECRYPT"
      + multi_region                       = (known after apply)
      + policy                             = (known after apply)
      + rotation_period_in_days            = (known after apply)
      + tags                               = {
          + "Name" = "xfusion-kms-key"
        }
      + tags_all                           = {
          + "Name" = "xfusion-kms-key"
        }
    }

  # local_file.decrypted_data will be created
  + resource "local_file" "decrypted_data" {
      + content              = (sensitive value)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "/home/bob/terraform/DecryptedData.txt"
      + id                   = (known after apply)
    }

  # local_file.encrypted_data will be created
  + resource "local_file" "encrypted_data" {
      + content              = (known after apply)
      + content_base64sha256 = (known after apply)
      + content_base64sha512 = (known after apply)
      + content_md5          = (known after apply)
      + content_sha1         = (known after apply)
      + content_sha256       = (known after apply)
      + content_sha512       = (known after apply)
      + directory_permission = "0777"
      + file_permission      = "0777"
      + filename             = "/home/bob/terraform/EncryptedData.bin"
      + id                   = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + kke_kms_key_name = "xfusion-kms-key"
aws_kms_key.xfusion_kms_key: Creating...
aws_kms_key.xfusion_kms_key: Creation complete after 8s [id=f8e98d70-5ed4-4e80-a1b4-28a820e62d54]
aws_kms_ciphertext.encrypt: Creating...
aws_kms_alias.xfusion_kms_key_alias: Creating...
aws_kms_alias.xfusion_kms_key_alias: Creation complete after 0s [id=alias/xfusion-kms-key]
aws_kms_ciphertext.encrypt: Creation complete after 0s [id=2026-04-22 14:56:35.775721346 +0000 UTC]
data.aws_kms_secrets.decrypt: Reading...
local_file.encrypted_data: Creating...
local_file.encrypted_data: Creation complete after 0s [id=b71b30b709f6abd5f16fa2439b7b2b674063ddbc]
data.aws_kms_secrets.decrypt: Read complete after 0s [id=us-east-1]
local_file.decrypted_data: Creating...
local_file.decrypted_data: Creation complete after 0s [id=33629e1969e087f33d261aa7324ea8f4b5507821]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

kke_kms_key_name = "xfusion-kms-key"
```

## Verfication

```bash
bob@iac-server ~/terraform via 💠 default ➜  terraform show
# data.aws_kms_secrets.decrypt:
data "aws_kms_secrets" "decrypt" {
    id        = "us-east-1"
    plaintext = (sensitive value)

    secret {
        context              = {}
        encryption_algorithm = null
        grant_tokens         = []
        key_id               = null
        name                 = "decrypted_data"
        payload              = "ZjhlOThkNzAtNWVkNC00ZTgwLWExYjQtMjhhODIwZTYyZDU0wDlI56cMCD84crSTjS8LSuAP+hXhfw+3UtJy9mYGmDjmga6UGQiqHxvemQbIWvsRFLuixpgjVpNMa8k7BtO5Og=="
    }
}

# aws_kms_alias.xfusion_kms_key_alias:
resource "aws_kms_alias" "xfusion_kms_key_alias" {
    arn            = "arn:aws:kms:us-east-1:000000000000:alias/xfusion-kms-key"
    id             = "alias/xfusion-kms-key"
    name           = "alias/xfusion-kms-key"
    name_prefix    = null
    target_key_arn = "arn:aws:kms:us-east-1:000000000000:key/f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
    target_key_id  = "f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
}

# aws_kms_ciphertext.encrypt:
resource "aws_kms_ciphertext" "encrypt" {
    ciphertext_blob = "ZjhlOThkNzAtNWVkNC00ZTgwLWExYjQtMjhhODIwZTYyZDU0wDlI56cMCD84crSTjS8LSuAP+hXhfw+3UtJy9mYGmDjmga6UGQiqHxvemQbIWvsRFLuixpgjVpNMa8k7BtO5Og=="
    id              = "2026-04-22 14:56:35.775721346 +0000 UTC"
    key_id          = "f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
    plaintext       = (sensitive value)
}

# aws_kms_key.xfusion_kms_key:
resource "aws_kms_key" "xfusion_kms_key" {
    arn                                = "arn:aws:kms:us-east-1:000000000000:key/f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
    bypass_policy_lockout_safety_check = false
    custom_key_store_id                = null
    customer_master_key_spec           = "SYMMETRIC_DEFAULT"
    deletion_window_in_days            = 20
    description                        = "An example symmetric encryption KMS key"
    enable_key_rotation                = true
    id                                 = "f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
    is_enabled                         = true
    key_id                             = "f8e98d70-5ed4-4e80-a1b4-28a820e62d54"
    key_usage                          = "ENCRYPT_DECRYPT"
    multi_region                       = false
    policy                             = jsonencode(
        {
            Id        = "key-default-1"
            Statement = [
                {
                    Action    = "kms:*"
                    Effect    = "Allow"
                    Principal = {
                        AWS = "arn:aws:iam::000000000000:root"
                    }
                    Resource  = "*"
                    Sid       = "Enable IAM User Permissions"
                },
            ]
            Version   = "2012-10-17"
        }
    )
    rotation_period_in_days            = 365
    tags                               = {
        "Name" = "xfusion-kms-key"
    }
    tags_all                           = {
        "Name" = "xfusion-kms-key"
    }
    xks_key_id                         = null
}

# local_file.decrypted_data:
resource "local_file" "decrypted_data" {
    content              = (sensitive value)
    content_base64sha256 = "v/KmeQqMArGTSFTMAZERJYZuKezDN2kwKDPKrDhEpgk="
    content_base64sha512 = "wGn5IGMHscwyqgjwvy11t+0Apr8jMw25uQB1bgT4bEc70/cDbKSfltAwhXdsXUEVlvE/7q1Cdry4P/TlAfvLrA=="
    content_md5          = "fb78248c0fdf1e8cc7d9b81af2423b16"
    content_sha1         = "33629e1969e087f33d261aa7324ea8f4b5507821"
    content_sha256       = "bff2a6790a8c02b1934854cc01911125866e29ecc33769302833caac3844a609"
    content_sha512       = "c069f9206307b1cc32aa08f0bf2d75b7ed00a6bf23330db9b900756e04f86c473bd3f7036ca49f96d03085776c5d411596f13feead4276bcb83ff4e501fbcbac"
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "/home/bob/terraform/DecryptedData.txt"
    id                   = "33629e1969e087f33d261aa7324ea8f4b5507821"
}

# local_file.encrypted_data:
resource "local_file" "encrypted_data" {
    content              = "ZjhlOThkNzAtNWVkNC00ZTgwLWExYjQtMjhhODIwZTYyZDU0wDlI56cMCD84crSTjS8LSuAP+hXhfw+3UtJy9mYGmDjmga6UGQiqHxvemQbIWvsRFLuixpgjVpNMa8k7BtO5Og=="
    content_base64sha256 = "QHySCl3CLlqdsxTLYQKS9RN3xuJECyeBotwiPejRy08="
    content_base64sha512 = "uYWTt7spAHQyIYy/MzgFB5iDngrx5KCJ2WyFtGnF1rE956j1tI7pML7R1crfbxxkXhwPZ5avRSYVxk6s5GtraA=="
    content_md5          = "720deac59ad33e27040ac6b734ea001d"
    content_sha1         = "b71b30b709f6abd5f16fa2439b7b2b674063ddbc"
    content_sha256       = "407c920a5dc22e5a9db314cb610292f51377c6e2440b2781a2dc223de8d1cb4f"
    content_sha512       = "b98593b7bb29007432218cbf3338050798839e0af1e4a089d96c85b469c5d6b13de7a8f5b48ee930bed1d5cadf6f1c645e1c0f6796af452615c64eace46b6b68"
    directory_permission = "0777"
    file_permission      = "0777"
    filename             = "/home/bob/terraform/EncryptedData.bin"
    id                   = "b71b30b709f6abd5f16fa2439b7b2b674063ddbc"
}


Outputs:

kke_kms_key_name = "xfusion-kms-key"
```