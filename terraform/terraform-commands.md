# Terraform Commands Guide

## Terraform Workflow Overview

Terraform follows a structured workflow to manage infrastructure as code. The typical workflow consists of five main stages:

1. **Write** - Define infrastructure in configuration files
2. **Initialize** - Prepare the working directory
3. **Validate** - Check configuration syntax and structure
4. **Plan** - Preview changes before applying
5. **Apply** - Execute the planned changes
6. **Destroy** - Clean up resources when no longer needed

## Core Terraform Commands

### 1. `terraform init`

**Purpose**: Initializes a Terraform working directory by downloading required providers and modules.

```bash
terraform init
```

**What it does**:

- Downloads and installs provider plugins specified in configuration
- Sets up the backend for storing state files
- Downloads modules referenced in the configuration
- Creates a `.terraform` directory with necessary files

**Common flags**:

- `-upgrade`: Upgrade modules and plugins to newest versions
- `-backend=false`: Skip backend initialization
- `-get=false`: Skip downloading modules

### 2. `terraform validate`

**Purpose**: Validates the syntax and internal consistency of Terraform configuration files.

```bash
terraform validate
```

**What it does**:

- Checks for syntax errors in `.tf` files
- Validates configuration structure and required arguments
- Ensures provider and resource configurations are valid
- Does NOT check if resources can actually be created

**Benefits**:

- Catches errors early in the development cycle
- Ensures configuration follows Terraform syntax rules
- Can be integrated into CI/CD pipelines for automated validation

### 3. `terraform plan`

**Purpose**: Creates an execution plan showing what actions Terraform will take to reach the desired state.

```bash
terraform plan
```

**What it does**:

- Compares current state with desired configuration
- Shows which resources will be created, modified, or destroyed
- Identifies any potential issues before making changes
- Outputs a detailed plan of proposed changes

**Common flags**:

- `-out=planfile`: Save the plan to a file for later use
- `-var="key=value"`: Set variables from command line
- `-var-file="filename"`: Load variables from a file
- `-destroy`: Create a plan to destroy all resources

**Plan symbols**:

- `+` Resources to be created
- `-` Resources to be destroyed
- `~` Resources to be modified
- `<=` Resources to be read during apply

### 4. `terraform apply`

**Purpose**: Executes the actions proposed in the Terraform plan to create, update, or delete infrastructure.

```bash
terraform apply
```

**What it does**:

- Applies the changes outlined in the plan
- Creates, modifies, or destroys resources as needed
- Updates the Terraform state file
- Shows real-time progress of resource creation/modification

**Common flags**:

- `-auto-approve`: Skip interactive approval prompt
- `-var="key=value"`: Set variables from command line
- `-var-file="filename"`: Load variables from a file
- `planfile`: Apply a previously saved plan file

**Best practices**:

- Always run `terraform plan` before `apply`
- Review the plan output carefully
- Use `-auto-approve` cautiously, preferably in automated environments

### 5. `terraform destroy`

**Purpose**: Destroys all resources managed by the current Terraform configuration.

```bash
terraform destroy
```

**What it does**:

- Creates a destruction plan for all managed resources
- Removes resources in the correct order (considering dependencies)
- Updates the state file to reflect destroyed resources
- Prompts for confirmation before proceeding

**Common flags**:

- `-auto-approve`: Skip interactive approval prompt
- `-target=resource`: Destroy only specific resources
- `-var="key=value"`: Set variables from command line

**⚠️ Warning**: This command will destroy ALL resources defined in your configuration. Use with extreme caution!

## Additional Useful Commands

### State Management

- `terraform show`: Display current state or saved plan
- `terraform state list`: List all resources in the state
- `terraform state show <resource>`: Show details of a specific resource
- `terraform refresh`: Update state file with real infrastructure

### Formatting and Documentation

- `terraform fmt`: Format configuration files to canonical style
- `terraform providers`: Show required providers for configuration

### Workspace Management

- `terraform workspace list`: List available workspaces
- `terraform workspace new <name>`: Create a new workspace
- `terraform workspace select <name>`: Switch to a different workspace

## Best Practices

1. **Always run commands in sequence**: init → validate → plan → apply
2. **Use version control** for your Terraform configurations
3. **Store state files securely** (use remote backends for team environments)
4. **Review plans carefully** before applying changes
5. **Use meaningful resource names** and consistent naming conventions
6. **Implement proper access controls** for sensitive operations
7. **Regular backups** of state files and configurations

## Example Workflow

```bash
# 1. Initialize the working directory
terraform init

# 2. Validate configuration
terraform validate

# 3. Format code (optional but recommended)
terraform fmt

# 4. Create and review execution plan
terraform plan

# 5. Apply changes
terraform apply

# When done, destroy resources (if needed)
terraform destroy
```

This workflow ensures that your infrastructure changes are predictable, reviewable, and safely applied.
