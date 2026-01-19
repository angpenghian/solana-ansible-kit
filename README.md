# Solana Ansible Kit

**Production-grade Ansible automation to provision, harden, and operate Solana validator fleets from bare Linux servers to running validators.**

Takes a fresh Linux server and transforms it into a secure, optimized validator node running Agave, Jito, or Firedancer with a single playbook run.

## What This Does

This isn't just a build script - it's a **complete validator fleet provisioning system** that handles:

### 🔐 Security & Hardening
- User provisioning with SSH key management
- Fail2ban intrusion prevention
- RPC firewall configuration
- GitHub SSH key deployment

### ⚙️ System Optimization
- NTP time synchronization for consensus accuracy
- Ring buffer tuning for network performance
- Server settings optimization (sysctl, limits)
- Custom bash environment for validator operations

### 🚀 Validator Operations
- **Build from source**: Compile Agave, Jito, or Firedancer validators
- **Multi-client support**: Run different validators on different nodes
- **Zero-downtime upgrades**: Tag-based upgrade workflows for Jito
- **Service management**: systemd integration with log rotation
- **Cron automation**: Scheduled maintenance tasks

### 📦 Infrastructure
- Docker setup for containerized tooling
- Dependency management (Rust, build tools, libraries)
- Version pinning and reproducible builds

## Why This Matters

Most validator guides show you how to compile a binary. This shows you how to **operate a fleet**:
- Provision 10 servers identically in one playbook run
- Upgrade validators with confidence using idempotent roles
- Audit every change through version-controlled configuration
- Onboard new team members with runnable documentation

## Complete Feature List

### Common Roles (Applied to All Validators)
| Role | Purpose |
|------|---------|
| `create_users` | Provision operator accounts with sudo access |
| `ssh_keys` | Deploy SSH public keys for team access |
| `ssh_keys_github` | Fetch and deploy SSH keys from GitHub users |
| `server_settings` | Optimize sysctl, ulimits, and kernel parameters |
| `ntp` | Configure time synchronization for consensus |
| `fail2ban` | Protect against brute-force SSH attacks |
| `docker` | Install Docker for containerized tooling |
| `rpc_firewall` | Configure firewall rules for RPC endpoints |
| `ring_buffers` | Tune network ring buffers for high throughput |
| `sol_bashrc` | Custom shell environment for validator ops |
| `github` | GitHub CLI and git configuration |

### Validator-Specific Roles
| Client | Compile | Upgrade | Preflight Checks | Features |
|--------|---------|---------|------------------|----------|
| **Agave** | ✅ | - | - | Mainnet/testnet, systemd service, log rotation, cron tasks |
| **Jito** | ✅ | ✅ | ✅ | Mainnet/testnet/BAM, zero-downtime upgrades, deployment validation |
| **Firedancer** | ✅ | - | - | Testnet, dependency automation (deps.sh), multi-architecture |

## Repository Structure
```
solana-ansible-kit/
├── inventory/hosts.yml              # Target servers and grouping
├── playbooks/
│   ├── sol_validator.yml            # Main provisioning playbook
│   └── vars/                        # Per-client configuration
│       ├── common_vars.yml          # Users, SSH keys, system settings
│       ├── agave_vars.yml           # Agave-specific config
│       ├── jito_vars.yml            # Jito-specific config
│       └── firedancer_vars.yml      # Firedancer-specific config
└── roles/
    ├── common/                      # 11 hardening & optimization roles
    ├── agave/                       # Agave build + service setup
    ├── jito/                        # Jito build + upgrade workflows
    └── firedancer/                  # Firedancer build automation
```

## Quick Start

### 1. Install Dependencies
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### 2. Configure Your Fleet
**Edit inventory** ([inventory/hosts.yml](inventory/hosts.yml)):
```yaml
all:
  children:
    primary_validators:
      hosts:
        validator-01:
          ansible_host: 203.0.113.10
        validator-02:
          ansible_host: 203.0.113.11
```

**Configure users and SSH keys** ([playbooks/vars/common_vars.yml](playbooks/vars/common_vars.yml)):
```yaml
server_users:
  - alice
  - bob
ssh_public_keys:
  - "ssh-ed25519 AAAA... alice@example.com"
```

**Set validator versions** ([playbooks/sol_validator.yml](playbooks/sol_validator.yml)):
```yaml
vars:
  agave_install_version: v2.3.6
  jito_install_version: v2.3.9-jito
  firedancer_install_version: v0.708.20306
```

### 3. Provision Your Validators

**Full provisioning** (bare server → running validator):
```bash
ansible-playbook playbooks/sol_validator.yml --limit primary_validators
```

**Targeted operations** using tags:
```bash
# Compile Agave on all hosts
ansible-playbook playbooks/sol_validator.yml --tags agave-compile

# Upgrade Jito validator to new version
ansible-playbook playbooks/sol_validator.yml --tags jito-upgrade

# Compile Firedancer from source
ansible-playbook playbooks/sol_validator.yml --tags firedancer-compile

# Apply only hardening roles
ansible-playbook playbooks/sol_validator.yml --tags common

# Run preflight checks only (validate deployment)
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight
```

## Production-Grade Features

### Deployment Validation (Preflight Checks)

Before running a validator in production, comprehensive validation ensures everything is correctly configured:

```bash
# Run Jito preflight checks
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight
```

**What gets validated**:
- ✓ Rust toolchain (rustc, cargo, rustfmt versions)
- ✓ System dependencies (all required packages installed)
- ✓ Repository state (correct version checked out)
- ✓ Binary installation (validator binary exists and matches expected version)
- ✓ Configuration files (validator script, .bashrc PATH)
- ✓ Network configuration (entrypoints, block engine URLs)
- ✓ Directory structure (required directories exist)
- ✓ System resources (memory, CPU cores)

**Output example**:
```
========== JITO PREFLIGHT SUMMARY ==========
Rust Toolchain: ✓
System Dependencies: ✓
Jito Repository: ✓
Jito Binary: ✓
Validator Script: ✓
Bashrc Config: ✓
Network Config: ✓
Directories: ✓
System Resources: ✓
============================================
```

This catches configuration issues **before** they cause production outages.

## Real-World Workflows

### Scenario 1: New Validator Fleet
Starting with 5 fresh Ubuntu servers:
```bash
# Single command provisions everything
ansible-playbook playbooks/sol_validator.yml --limit primary_validators

# Result:
# - Users created with SSH keys
# - System hardened (fail2ban, firewall, sysctl tuning)
# - Validator compiled from source
# - systemd service configured
# - Log rotation setup
# - Ready to start validating
```

### Scenario 2: Zero-Downtime Jito Upgrade
```bash
# 1. Update version in playbook
vim playbooks/sol_validator.yml  # Change jito_upgrade_version

# 2. Run upgrade workflow
ansible-playbook playbooks/sol_validator.yml --tags jito-upgrade

# Result:
# - New version compiled alongside existing binary
# - Service gracefully restarted
# - Old version retained as rollback option
```

### Scenario 3: Onboard New Team Member
```bash
# 1. Add to common_vars.yml
server_users:
  - alice
  - bob
  - charlie  # new member

# 2. Add SSH key
ssh_public_keys:
  - "ssh-ed25519 AAAA... charlie@example.com"

# 3. Apply changes
ansible-playbook playbooks/sol_validator.yml --tags create_users,ssh_keys

# Result: Charlie can now SSH to all validators
```

### Scenario 4: Pre-Production Validation
```bash
# After deploying Jito validator, validate before going live
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight --limit validator-01

# Preflight checks catch issues:
# - Missing dependencies
# - Wrong version checked out
# - Binary not compiled
# - Configuration file errors
# - Missing required directories

# Fix any issues, then re-validate
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight --limit validator-01

# All checks pass → Safe to start validator service
```

## Why This is Production-Ready

**Idempotency**: Run the same playbook 100 times, get the same result. Safe for automation.

**Auditability**: Every change is explicit in version control. No hidden state or magic.

**Modularity**: Use only what you need via Ansible tags and role selection.

**Transparency**: No secret managers or external dependencies. Bring your own keys and credentials.

**Maintainability**: Simple shell tasks and templates, not complex abstractions.

**Deployment Validation**: Preflight checks catch configuration issues before production.

## Technical Highlights for Reviewers

- **Multi-client architecture**: Single playbook supports Agave, Jito, and Firedancer with client-specific roles
- **Tag-based execution**: Granular control over what runs (compile, upgrade, hardening)
- **Version pinning**: Explicit version control for reproducible deployments
- **Systemd integration**: Proper service management with dependencies and restart policies
- **Log management**: Logrotate configuration prevents disk exhaustion
- **Security defaults**: Fail2ban, SSH hardening, firewall rules applied automatically
- **Performance tuning**: Ring buffers, sysctl settings, ulimits optimized for validators
- **Fleet operations**: Scale from 1 to N validators with identical configuration

## Limitations & Design Choices

- **Target**: Ubuntu/Debian x86_64 (can be extended to other distros)
- **Scope**: Provisioning and upgrades, not monitoring (see separate monitoring repo)
- **Secrets**: Expects SSH keys and credentials in vars files (adapt for your secret management)
- **Network**: Assumes outbound internet for package downloads (adjust for air-gapped)

## Notes
- This repo uses placeholder inventory entries; replace with your own targets
- `docs/` folder is local-only and gitignored for planning/notes
- Prefer the simplest path that works; avoid over-engineering

## License
Apache-2.0. See [LICENSE](LICENSE).
