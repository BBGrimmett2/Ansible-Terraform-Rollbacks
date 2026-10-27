# Terraform + Ansible Automated Rollback Demo

> Demonstration of automated infrastructure rollback using Terraform, Ansible, and AAP Automation Orchestrator

## Overview

This project demonstrates automated, unattended rollback when provisioning AWS infrastructure fails at any stage. It showcases how to integrate Terraform with Ansible via AAP Automation Orchestrator to provide:

- Automated infrastructure provisioning (VPC, Subnet, EC2)
- Configuration management with Ansible
- Automatic rollback on any failure (Terraform or configuration)
- Minimal state file complexity (local backend + destroy pattern)
- Demo failure simulation for presentations

---

<!-- ## Quick Start

### Prerequisites

- Ansible Automation Platform 2.6+ with Automation Orchestrator
- AWS account with API credentials
- GitHub/GitLab repository

### Setup Steps

1. **Configure Credentials:**
   ```bash
   vim vault.yml  # Add AWS, AAP, GitHub credentials
   ansible-vault encrypt vault.yml
   ```

2. **Update Configuration:**
   - Edit `aap_config/common_vars.yml` to set organization name and resource names
   - Edit `aap_config/controller/projects.yml` to set your Git repository URL
   - Edit workflow JSON to update AAP credential IDs

3. **Deploy to AAP:**
   ```bash
   ansible-playbook playbooks/configure_aap.yml -e @vault.yml --ask-vault-pass
   ```

4. **Create Workflow in AAP UI:**
   - Follow instructions in `WORKFLOW_MAP.md`
   - Manually create the workflow using the visual editor

5. **Test the Demo:**
   - Launch workflow with `simulate_tf_failure: true` to test Terraform rollback
   - Launch workflow with `simulate_config_failure: true` to test config rollback

--- -->

## Project Structure

```
.
├── terraform/                          # Terraform infrastructure code
│   ├── main.tf                         # VPC, Subnet, EC2 definitions
│   ├── variables.tf                    # Input variables (incl. simulate_tf_failure)
│   ├── outputs.tf                      # Resource IDs and IPs
│   └── terraform.tfvars.example        # Example variable values
│
├── roles/                              # Ansible roles (AGENTS.md compliant)
│   ├── terraform_executor/             # Execute Terraform operations
│   │   ├── defaults/main.yml
│   │   ├── meta/argument_specs.yml     # Schema validation
│   │   └── tasks/
│   │       ├── validate.yml            # Input validation
│   │       ├── provision.yml           # Terraform apply
│   │       └── destroy.yml             # Terraform destroy (rollback)
│   │
│   └── aws_resource_config/            # Configure AWS resources
│       ├── defaults/main.yml
│       ├── meta/argument_specs.yml     # Schema validation
│       └── tasks/
│           ├── validate.yml            # Input validation
│           ├── configure.yml           # Configuration tasks
│           └── rollback.yml            # Configuration rollback
│
├── playbooks/                          # Thin playbook wrappers for AAP
│   ├── terraform_provision.yml         # Provision infrastructure
│   ├── terraform_destroy.yml           # Destroy infrastructure (rollback)
│   ├── configure_resources.yml         # Configure resources
│   └── configure_aap.yml               # Deploy AAP config-as-code
│
├── aap_config/                         # AAP configuration as code
│   ├── common_vars.yml                 # Centralized AAP resource names
│   ├── all/
│   │   ├── organizations.yml           # Organizations
│   │   └── execution_environments.yml  # Execution environments
│   └── controller/
│       ├── credentials.yml             # AWS, GitHub, AAP credentials
│       ├── projects.yml                # AAP project definition
│       ├── inventories.yml             # Localhost + AWS dynamic inventory
│       ├── job_templates.yml           # Job template definitions
│
├── collections/requirements.yml        # Ansible Galaxy collections
├── execution-environment/              # EE dependencies
├── vault.yml                           # Encrypted credentials
│
├── NEXT_STEPS.md                       # Setup guide
├── WORKFLOW_MAP.md                     # Workflow creation guide
├── DEMO_README.md                      # Demo documentation
└── README.md                           # This file
```