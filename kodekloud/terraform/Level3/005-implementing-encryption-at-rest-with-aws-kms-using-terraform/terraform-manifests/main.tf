# 1. Create a symmetric KMS key named `xfusion-kms-key` to manage encryption and decryption.
resource "aws_kms_key" "xfusion_kms_key" {
  description             = "An example symmetric encryption KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  tags = {
    Name = "xfusion-kms-key"
  }
}

# Create an alias named `alias/xfusion-kms-key` for the KMS key created in step 1.
resource "aws_kms_alias" "xfusion_kms_key_alias" {
  name          = "alias/xfusion-kms-key"
  target_key_id = aws_kms_key.xfusion_kms_key.key_id
}

# 2. Encrypt the provided `SensitiveData.txt` file (located in `/home/bob/terraform`), base64 encode the ciphertext, and save the encrypted version as `EncryptedData.bin` in the `/home/bob/terraform` directory.
resource "aws_kms_ciphertext" "encrypt" {
  key_id = aws_kms_key.xfusion_kms_key.key_id
  plaintext = file("/home/bob/terraform/SensitiveData.txt")
}

resource "local_file" "encrypted_data" {
  content  = aws_kms_ciphertext.encrypt.ciphertext_blob
  filename = "/home/bob/terraform/EncryptedData.bin"
}

# 3. Try to decrypt the same and verify that the decrypted data matches the original file.
data "aws_kms_secrets" "decrypt" {
  secret {
    name = "decrypted_data"
    payload = aws_kms_ciphertext.encrypt.ciphertext_blob
  }
}

resource "local_file" "decrypted_data" {
  content  = data.aws_kms_secrets.decrypt.plaintext["decrypted_data"]
  filename = "/home/bob/terraform/DecryptedData.txt"
}