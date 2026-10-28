# Slack Notification Role

Sends formatted notification messages to Slack via incoming webhook.

## Description

This role provides a standardized way to send rich, formatted notifications to Slack channels from Ansible playbooks and AAP workflows. It supports different message types (info, success, warning, error) with appropriate color coding and includes AAP job context automatically.

## Requirements

- Slack incoming webhook URL
- Ansible 2.9+
- `ansible.builtin.uri` module

## Role Variables

### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `slack_webhook_url` | string | Slack incoming webhook URL (injected via AAP credential) |
| `notification_message` | string | Main notification message body |

### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `notification_title` | string | `"Ansible Job Notification"` | Title of the notification message |
| `notification_status` | string | `"info"` | Status type: `info`, `success`, `warning`, `error` |
| `notification_details` | list | `[]` | List of additional detail lines |
| `infrastructure_details` | dict | `{}` | Dictionary of infrastructure details (VPC ID, etc.) |
| `slack_channel` | string | `"#ansible-notifications"` | Slack channel to post to |
| `slack_username` | string | `"Ansible Automation Platform"` | Display name for the bot |
| `slack_icon_emoji` | string | `":ansible:"` | Emoji icon for the bot |

### AAP Context Variables (Auto-populated)

| Variable | AAP Variable | Description |
|----------|--------------|-------------|
| `awx_job_id` | `tower_job_id` | Job ID |
| `awx_job_template_name` | `tower_job_template_name` | Job template name |
| `awx_job_url` | `tower_job_launch_url` | Job URL |

## Message Status Types

| Status | Color | Icon | Use Case |
|--------|-------|------|----------|
| `info` | Blue (#439FE0) | :information_source: | General information |
| `success` | Green | :white_check_mark: | Successful operations |
| `warning` | Orange | :warning: | Warning conditions |
| `error` | Red | :x: | Failures and errors |

## Dependencies

None

## Example Usage

### Basic Notification

```yaml
- name: Send basic notification
  ansible.builtin.import_role:
    name: slack_notification
  vars:
    notification_message: "Deployment completed successfully"
    notification_status: success
```

### Notification with Details

```yaml
- name: Send detailed notification
  ansible.builtin.import_role:
    name: slack_notification
  vars:
    notification_title: "Infrastructure Provisioning Complete"
    notification_status: success
    notification_message: "AWS infrastructure has been successfully provisioned"
    notification_details:
      - "Region: us-east-1"
      - "Environment: production"
      - "Duration: 5 minutes"
    infrastructure_details:
      vpc_id: "vpc-123456"
      subnet_id: "subnet-789012"
      instance_id: "i-345678"
```

### Error Notification

```yaml
- name: Send error notification
  ansible.builtin.import_role:
    name: slack_notification
  vars:
    notification_title: "Deployment Failed"
    notification_status: error
    notification_message: "Infrastructure provisioning failed. Rollback initiated."
    notification_details:
      - "Failed at: Terraform apply"
      - "Action: Automatic rollback triggered"
```

## Playbooks

The following playbooks are provided for common notification scenarios:

- **`notify_provision_success.yml`** - Infrastructure provisioning success
- **`notify_provision_failure.yml`** - Infrastructure provisioning failure
- **`notify_config_failure.yml`** - Configuration failure
- **`notify_rollback_complete.yml`** - Rollback completion
- **`notify_generic.yml`** - Custom notification with user-defined content

## AAP Integration

### Credential Setup

1. Create a Slack incoming webhook in your Slack workspace
2. In AAP, create a credential using the "Slack Webhook" credential type
3. Enter the webhook URL in the credential
4. Attach the credential to notification job templates

### Workflow Integration

Add notification job templates to your AAP workflows:

```
Provision → [Success] → Notify Success
         → [Failure] → Notify Failure → Rollback → Notify Rollback Complete
```

## Message Format

The role sends a Slack message with the following structure:

- **Title**: With clickable link to AAP job
- **Message**: Main notification content
- **Details**: Bulleted list of additional information
- **Infrastructure**: Infrastructure-specific details
- **Footer**: AAP branding with timestamp
- **Fields**: Job template name and job ID

## Error Handling

The role includes error handling and will not fail the playbook if the Slack notification fails. Failures are logged but do not interrupt the workflow.

## License

MIT

## Author Information

Created for Terraform + Ansible Automated Rollback Demo
