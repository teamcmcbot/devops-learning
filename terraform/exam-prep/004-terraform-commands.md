# Terraform Associate (004) — Terraform CLI Commands Cheat Sheet

Source objectives: https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004

This file lists Terraform CLI commands that commonly appear (directly or indirectly) in the Terraform Associate (004) exam objectives, with a short “when to use it” description.

## Core workflow commands (Objectives 3a–3g)

| Command              | Short use-case (when to use)                                                                                           | Maps to objective(s) |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `terraform init`     | Initialize a working directory: installs providers/modules, configures backend, and creates `.terraform/` + lock file. | 3b, 2a, 6a, 6c       |
| `terraform validate` | Check configuration syntax and internal consistency (catches many errors early).                                       | 3c, 4g               |
| `terraform fmt`      | Auto-format configuration to canonical style (use `-check` in CI).                                                     | 3g                   |
| `terraform plan`     | Preview changes Terraform would make; validate the execution plan before applying.                                     | 3d                   |
| `terraform apply`    | Apply the planned changes to real infrastructure and update state.                                                     | 3e                   |
| `terraform destroy`  | Remove Terraform-managed infrastructure (often used for lab cleanup).                                                  | 3f                   |

### High-signal flags/options to recognize

| Command/area                  | Flag / option         | Short use-case                                                                                     |
| ----------------------------- | --------------------- | -------------------------------------------------------------------------------------------------- |
| `terraform init`              | `-upgrade`            | Upgrade provider/module versions within allowed constraints (and update the dependency lock file). |
| `terraform init`              | `-reconfigure`        | Reinitialize backend/provider settings (use when backend config changed).                          |
| `terraform init`              | `-backend-config=...` | Supply backend configuration values at init time (common with remote state backends).              |
| `terraform plan` / `apply`    | `-var`, `-var-file`   | Provide input variables from CLI / a tfvars file.                                                  |
| `terraform plan` / `apply`    | `-target=...`         | Force planning/applying a specific resource (generally avoid unless necessary).                    |
| `terraform plan`              | `-out tfplan`         | Save a plan to a file so you can apply exactly what you reviewed.                                  |
| `terraform apply`             | `tfplan`              | Apply a previously saved plan file.                                                                |
| `terraform apply` / `destroy` | `-auto-approve`       | Skip interactive approval (common in automation).                                                  |
| `terraform plan` / `apply`    | `-refresh-only`       | Only reconcile state with real infrastructure (drift-focused), without proposing changes.          |

## Providers (Objectives 2a–2c)

| Command                    | Short use-case (when to use)                                                           | Maps to objective(s) |
| -------------------------- | -------------------------------------------------------------------------------------- | -------------------- |
| `terraform providers`      | Show which providers are required by configuration and which are present in state.     | 2b                   |
| `terraform providers lock` | Create/update the dependency lock file (`.terraform.lock.hcl`) for specific platforms. | 2a                   |

Notes:

- Provider version constraints live in `required_providers` (Terraform configuration), while the lock file pins exact selections.

## State & drift management (Objectives 2d, 6a–6d, 7b)

| Command           | Short use-case (when to use)                                            | Maps to objective(s) |
| ----------------- | ----------------------------------------------------------------------- | -------------------- |
| `terraform state` | Inspect and manipulate Terraform state via subcommands (see below).     | 7b, 6d               |
| `terraform show`  | Render a human-readable view of the current state or a saved plan file. | 3d, 7b               |

### `terraform state` subcommands to know

| Command                                        | Short use-case                                                            |
| ---------------------------------------------- | ------------------------------------------------------------------------- |
| `terraform state list`                         | List resource addresses currently tracked in state.                       |
| `terraform state show <addr>`                  | Show attributes for a single tracked resource.                            |
| `terraform state mv <src> <dst>`               | Move/rename state entries (refactors without recreation).                 |
| `terraform state rm <addr>`                    | Stop tracking an object in state (does not delete remote infrastructure). |
| `terraform state pull`                         | Download and print remote state (useful for debugging).                   |
| `terraform state push <statefile>`             | Upload a state file (dangerous; typically for recovery).                  |
| `terraform state replace-provider <from> <to>` | Migrate state between provider source addresses.                          |

## Import existing infrastructure (Objective 7a)

| Command                        | Short use-case (when to use)                                                                                                    | Maps to objective(s) |
| ------------------------------ | ------------------------------------------------------------------------------------------------------------------------------- | -------------------- |
| `terraform import <addr> <id>` | Bring an existing real-world object under Terraform management by creating state for it (you still must write matching config). | 7a                   |

## Modules & values (Objectives 4c–4e, 5a–5d)

| Command             | Short use-case (when to use)                                                 | Maps to objective(s) |
| ------------------- | ---------------------------------------------------------------------------- | -------------------- |
| `terraform console` | Evaluate expressions/functions interactively (great for learning/debugging). | 4e                   |
| `terraform output`  | Read output values from state (useful after apply or in scripts).            | 4c                   |

Notes:

- Module installation typically happens during `terraform init`.

## Resource graph (Objective 3d / 4f)

| Command           | Short use-case (when to use)                                                       | Maps to objective(s) |
| ----------------- | ---------------------------------------------------------------------------------- | -------------------- |
| `terraform graph` | Output a dependency graph in DOT format (visualize resource/module relationships). | 3d, 4f               |

## HCP Terraform integration (Objectives 8a–8d)

| Command           | Short use-case (when to use)                                                               | Maps to objective(s) |
| ----------------- | ------------------------------------------------------------------------------------------ | -------------------- |
| `terraform login` | Authenticate the CLI for use with HCP Terraform (e.g., remote operations, cloud settings). | 8d                   |

## Verbose logging (Objective 7c)

Terraform verbose logging is controlled by environment variables (not a Terraform subcommand):

| Env var       | Short use-case                                                       |
| ------------- | -------------------------------------------------------------------- |
| `TF_LOG`      | Set log verbosity (e.g., `TRACE`, `DEBUG`, `INFO`, `WARN`, `ERROR`). |
| `TF_LOG_PATH` | Write logs to a file (useful in CI or when troubleshooting).         |
