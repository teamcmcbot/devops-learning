# Terraform Associate (004) — `for_each`, `toset()`, `tomap()` Cheatsheet

This is a quick exam-prep reference for **when** to use `for_each`, `toset()`, and `tomap()` and **how** they behave.

---

## `for_each`

### What it is

`for_each` is a **meta-argument** that tells Terraform to create **multiple instances** of a resource/module/data source from a **collection**.

- Allowed collection types:
  - `set(string)`
  - `map(any)`
  - (Terraform also commonly accepts expressions that evaluate to these)

Inside a `for_each` block:

- `each.key` is the instance key.
- `each.value` is the value associated with the key.

### When to use

Use `for_each` when you want **one instance per distinct key** and you care about **stable addressing**.

Typical use-cases:

- Create one resource per name (map keys).
- Create one resource per environment (`dev`, `stg`, `prod`).
- Iterate over availability zones or subnets.
- Create multiple data sources (one per AZ) and then aggregate the results.

### Why exam cares

It’s a core technique for:

- dynamic configuration (Objective 4e)
- modules (Objective 5c)
- working with collections and expressions (Objective 4d)

---

## `for_each` vs `count` (high-yield)

Use `count` when:

- You only need “N copies”
- Instances are naturally indexed (0..N-1)

Use `for_each` when:

- Instances have natural identities (names, IDs)
- You want fewer diffs when inserting/removing items

**Key difference:**

- `count` uses numeric addresses: `aws_instance.web[0]`
- `for_each` uses keyed addresses: `aws_instance.web["prod"]`

In practice, `for_each` often produces **more stable plans**.

---

## Example 1 — `for_each` with a map (most common)

Create one S3 bucket per environment, with environment-specific tags.

```hcl
locals {
  buckets = {
    dev  = { owner = "team-a" }
    prod = { owner = "team-a" }
  }
}

resource "aws_s3_bucket" "app" {
  for_each = local.buckets

  bucket = "myapp-${each.key}"  # each.key = dev/prod

  tags = {
    env   = each.key
    owner = each.value.owner
  }
}
```

**When to use:** when each instance should be keyed by something meaningful (`dev`, `prod`).

---

## Example 2 — `for_each` with a set of strings

Create one security group rule per allowed CIDR.

```hcl
variable "allowed_cidrs" {
  type    = list(string)
  default = ["10.0.0.0/16", "192.168.0.0/24"]
}

resource "aws_security_group_rule" "ingress" {
  for_each = toset(var.allowed_cidrs)

  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [each.key]   # for set(string), key == value
  security_group_id = aws_security_group.main.id
}
```

**Why `toset()` here:** `for_each` wants a set or map; converting from list ensures Terraform treats it as a set of unique items.

---

## Example 3 — `for_each` on a data source + aggregation

This mirrors a common exam-style pattern: one data lookup per AZ and build a map of results.

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ec2_instance_type_offerings" "offering" {
  for_each      = toset(data.aws_availability_zones.available.names)
  location_type = "availability-zone"

  filter {
    name   = "instance-type"
    values = ["t3.micro"]
  }

  filter {
    name   = "location"
    values = [each.key]
  }
}

output "supported_by_az" {
  value = {
    for az, details in data.aws_ec2_instance_type_offerings.offering :
    az => details.instance_types
  }
}

output "supported_azs" {
  value = keys({
    for az, details in data.aws_ec2_instance_type_offerings.offering :
    az => details.instance_types
    if length(details.instance_types) != 0
  })
}
```

---

## `toset()`

### What it is

`toset(x)` converts a compatible value into a **set**.

Important set behavior:

- Sets are **unordered**.
- Sets contain **unique** values (duplicates removed).

### When to use

Use `toset()` when:

- You want to use `for_each` over a list of strings.
- You want to deduplicate values.

### Example — dedupe input

```hcl
variable "names" {
  type    = list(string)
  default = ["a", "b", "b"]
}

output "unique" {
  value = toset(var.names)  # => {"a", "b"}
}
```

### Exam pitfall: ordering

Because sets are unordered, don’t write logic that depends on “first element” of a set.

- If you truly need ordering, use a list.

---

## `tomap()`

### What it is

`tomap(x)` converts a compatible value into a **map**.

Maps are key/value collections.

- Keys are strings.
- Values can be any type.

### When to use

Use `tomap()` when:

- You need to force a value to be treated as a map (often for input normalization).
- You’re building a map in locals/outputs and want it typed clearly.
- You want to use `for_each` with predictable keys.

### Example — normalize input to a map

```hcl
variable "tags" {
  # sometimes you may receive tags from another module/output as an untyped object
  type    = any
  default = {
    env  = "dev"
    team = "platform"
  }
}

locals {
  normalized_tags = tomap(var.tags)
}

output "tags" {
  value = local.normalized_tags
}
```

### Example — use `tomap()` + `for_each`

```hcl
locals {
  users = tomap({
    alice = { role = "admin" }
    bob   = { role = "reader" }
  })
}

resource "some_resource" "user" {
  for_each = local.users

  name = each.key
  role = each.value.role
}
```

---

## Other `to*` type conversion functions (quick reference)

Terraform includes several **type conversion** helpers you’ll see in real code and exam questions.

### `tolist(x)`

Converts a compatible value to a **list**.

When to use:

- You need a list-specific operation (e.g., indexing) and the value is currently a set.
- You want a predictable (list) type for an input/output.

Example — convert a set to a list for indexing:

```hcl
locals {
  azs_set  = toset(["us-east-1a", "us-east-1b"])
  azs_list = tolist(local.azs_set)
}

output "first_az" {
  value = local.azs_list[0]
}
```

Note: if you start from a **set**, the resulting list order is not something you should rely on.

### `tostring(x)`

Converts a compatible value to a **string**.

When to use:

- You need string interpolation or a provider argument expects a string.

Example:

```hcl
variable "port" {
  type    = number
  default = 443
}

output "port_as_string" {
  value = tostring(var.port) # "443"
}
```

### `tonumber(x)`

Converts a compatible value to a **number**.

When to use:

- You receive numeric input as a string (e.g., from a variable, file, or remote output) and need arithmetic.

Example:

```hcl
variable "desired" {
  type    = string
  default = "3"
}

locals {
  desired_plus_one = tonumber(var.desired) + 1
}

output "desired_plus_one" {
  value = local.desired_plus_one # 4
}
```

### `tobool(x)`

Converts a compatible value to a **bool**.

When to use:

- You accept a string input like `"true"` / `"false"` and need a real boolean for conditionals.

Example:

```hcl
variable "enabled" {
  type    = string
  default = "true"
}

locals {
  enabled_bool = tobool(var.enabled)
}

output "enabled_bool" {
  value = local.enabled_bool # true
}
```

Practical tip: prefer typing variables as `bool` / `number` directly when you control the input.

---

## Patterns to remember (exam quick hits)

- Prefer `for_each` when you can name instances with stable keys.
- Use `toset(list_of_strings)` to iterate with `for_each` when you don’t need per-item metadata.
- Use `tomap(...)` when you want predictable key/value iteration and stable addresses.
- With `for_each`:
  - map: `each.key` is the map key; `each.value` is the map value
  - set(string): `each.key` is the string value

---

## Quick self-check questions

- If I remove one item, will addresses shift? (If yes, consider `for_each` over `count`.)
- Do I need stable names/keys per instance? (If yes, prefer `for_each` with a map.)
- Am I converting a list to a set and then relying on ordering? (Avoid.)
