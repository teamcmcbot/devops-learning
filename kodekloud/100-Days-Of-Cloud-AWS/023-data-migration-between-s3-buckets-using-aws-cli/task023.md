# Task 023: Data Migration between S3 Buckets using AWS CLI

As part of a data migration project, the team lead has tasked the team with migrating data from an existing S3 bucket to a new S3 bucket. The existing bucket contains a substantial amount of data that must be accurately transferred to the new bucket. The team is responsible for creating the new S3 bucket and ensuring that all data from the existing bucket is copied or synced to the new bucket completely and accurately. It is imperative to perform thorough verification steps to confirm that all data has been successfully transferred to the new bucket without any loss or corruption.

As a member of the Nautilus DevOps Team, your task is to perform the following:

Create a New Private S3 Bucket: Name the bucket `nautilus-sync-23504`.

Data Migration: Migrate the entire data from the existing `nautilus-s3-23353` bucket to the new `nautilus-sync-23504` bucket.

Ensure Data Consistency: Ensure that both buckets have the same data.

Use AWS CLI: Use the AWS CLI to perform the creation and data migration tasks.

## Solution

### Step 1: Create a New Private S3 Bucket

```bash
~ on ☁️  (us-east-1) ➜  aws s3 ls
2025-12-26 04:05:31 nautilus-s3-23353

~ on ☁️  (us-east-1) ➜  aws s3 mb s3://nautilus-sync-23504
make_bucket: nautilus-sync-23504

~ on ☁️  (us-east-1) ➜  aws s3 ls
2025-12-26 04:05:31 nautilus-s3-23353
2025-12-26 04:06:51 nautilus-sync-23504
```

### Step 2: Migrate Data from Existing Bucket to New Bucket

```bash
~ on ☁️  (us-east-1) ➜  aws s3 sync s3://nautilus-s3-23353 s3://nautilus-sync-23504
```

**NOTE:** There are about 1000 files in the source bucket, so the sync command may take some time to complete.

### Step 3: Verify Data Consistency Between Both Buckets

```bash
~ on ☁️  (us-east-1) ➜  aws s3 ls s3://nautilus-s3-23353 --recursive --summarize | tail -5
2025-12-26 04:06:04       5214 wp-trackback.php
2025-12-26 04:06:04       3205 xmlrpc.php

Total Objects: 3349
   Total Size: 76133582

~ on ☁️  (us-east-1) ➜  aws s3 ls s3://nautilus-sync-23504 --recursive --summarize | tail -5
2025-12-26 04:09:58       5214 wp-trackback.php
2025-12-26 04:09:58       3205 xmlrpc.php

Total Objects: 3349
   Total Size: 76133582
```

Both buckets have the same number of objects (3349) and the same total size (76133582 bytes), confirming that the data migration was successful and consistent.
