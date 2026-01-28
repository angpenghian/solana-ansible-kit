# solana-ansible-kit

**Production-grade Ansible automation for Solana validator fleet operations**

Provision, harden, and operate Solana validator infrastructure at scale. Supports Agave, Jito, and Firedancer with idempotent, tag-based workflows.

## The Problem

Operating validator fleets at scale requires:
- **Consistent provisioning**: Identical security hardening and system tuning across all hosts
- **Safe upgrade workflows**: Zero-downtime updates without manual intervention
- **Configuration management**: Version-controlled infrastructure as code
- **Operational discipline**: Rollback paths, preflight checks, audit trails

Manual server setup is error-prone, time-consuming, and doesn't scale beyond a few nodes.

## The Solution

**Ansible-based fleet automation** that:
- Transforms bare Linux servers into production-ready validator nodes in one playbook run
- Applies security hardening, performance tuning, and service management consistently
- Supports multiple validator clients (Agave, Jito, Firedancer) with client-specific roles
- Enables tag-based operations (compile, upgrade, validate) for granular control
- Provides preflight checks to catch configuration issues before production

## Why This Matters for Validator Operations

**Fleet Consistency**: Provision 10 servers identically with the same playbook

**Operational Safety**: Idempotent roles mean you can re-run without side effects

**Audit Trail**: Version-controlled configuration shows what changed and when

**Team Onboarding**: New operators can understand and modify the stack through code

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│ Ansible Control Node (Local Machine)                          │
│ • inventory/hosts.yml   • playbooks/   • roles/               │
└─────────────────────────┬──────────────────────────────────────┘
                          │
                          │ SSH (Ansible Automation)
                          ▼
┌────────────────────────────────────────────────────────────────┐
│ Validator Fleet (Target Servers)                              │
│ • validator-01  • validator-02  • validator-03  ...           │
└──────────┬─────────────────────────────────────────────────────┘
           │
           │ Ansible Roles Applied
           ▼
┌────────────────────────────────────────────────────────────────┐
│ Phase 1: Common Hardening (11 Roles)                          │
│ • create_users     • ssh_keys          • fail2ban             │
│ • server_settings  • ntp               • rpc_firewall         │
│ • ring_buffers     • docker            • github               │
│ • sol_bashrc       • ssh_keys_github                          │
└──────────┬─────────────────────────────────────────────────────┘
           │
           ▼
┌────────────────────────────────────────────────────────────────┐
│ Phase 2: Validator Client Build (Client-Specific)             │
│                                                                │
│  Agave Role          Jito Role          Firedancer Role       │
│  • Clone repo        • Clone repo       • Clone repo          │
│  • Install deps      • Install deps     • Run deps.sh         │
│  • Compile binary    • Compile binary   • Build with LLVM     │
│  • systemd service   • systemd service  • systemd service     │
│  • Log rotation      • Upgrade workflow • Testnet config      │
│  • Cron tasks        • Preflight checks                       │
└──────────┬─────────────────────────────────────────────────────┘
           │
           ▼
┌────────────────────────────────────────────────────────────────┐
│ Result: Production-Ready Validator                            │
│ • Hardened OS        • Tuned performance  • Service managed   │
│ • Validated config   • Audit trail       • Rollback capable   │
└────────────────────────────────────────────────────────────────┘
```

## Features

### Security & Hardening
- **User management**: Provision operator accounts with SSH key deployment
- **Intrusion prevention**: Fail2ban protection against brute-force attacks
- **Firewall rules**: RPC endpoint access control
- **SSH hardening**: Key-based auth, GitHub key integration

### System Optimization
- **Time synchronization**: NTP configuration for consensus accuracy
- **Network tuning**: Ring buffer optimization for high throughput
- **Kernel tuning**: sysctl settings and ulimits for validator workloads
- **Custom environment**: Bash configuration for operational workflows

### Validator Operations
- **Multi-client support**: Agave, Jito, and Firedancer in single playbook
- **Tag-based workflows**: Granular control (compile, upgrade, preflight)
- **Zero-downtime upgrades**: Side-by-side version deployment with graceful restart
- **Service management**: systemd integration with automatic restarts
- **Log management**: Logrotate configuration prevents disk exhaustion

### Deployment Validation
- **Preflight checks**: Validate Rust toolchain, dependencies, binaries, configuration
- **System resource checks**: Verify memory, CPU, disk space requirements
- **Network validation**: Confirm entrypoints and RPC configurations
- **Pre-production safety**: Catch issues before going live

## Quick Start

### Prerequisites
- Ansible 2.9+ on control node
- Ubuntu/Debian target servers with SSH access
- Sudo privileges on target servers

### 1. Install Dependencies

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### 2. Configure Inventory

**Edit [inventory/hosts.yml](inventory/hosts.yml)**:
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

### 3. Configure Variables

**Set users and SSH keys in [playbooks/vars/common_vars.yml](playbooks/vars/common_vars.yml)**:
```yaml
server_users:
  - alice
  - bob
ssh_public_keys:
  - "ssh-ed25519 AAAA... alice@example.com"
  - "ssh-ed25519 AAAA... bob@example.com"
```

**Set validator versions in [playbooks/sol_validator.yml](playbooks/sol_validator.yml)**:
```yaml
vars:
  agave_install_version: v2.3.6
  jito_install_version: v2.3.9-jito
  firedancer_install_version: v0.708.20306
```

### 4. Provision Validators

**Full provisioning** (bare server → running validator):
```bash
ansible-playbook playbooks/sol_validator.yml --limit primary_validators
```

**Targeted operations** using tags:
```bash
# Compile specific client
ansible-playbook playbooks/sol_validator.yml --tags agave-compile
ansible-playbook playbooks/sol_validator.yml --tags jito-compile
ansible-playbook playbooks/sol_validator.yml --tags firedancer-compile

# Zero-downtime Jito upgrade
ansible-playbook playbooks/sol_validator.yml --tags jito-upgrade

# Apply only hardening (no validator build)
ansible-playbook playbooks/sol_validator.yml --tags common

# Run preflight validation
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight
```

## Repository Structure

```
solana-ansible-kit/
├── inventory/
│   └── hosts.yml                      # Target server definitions
├── playbooks/
│   ├── sol_validator.yml              # Main provisioning playbook
│   └── vars/
│       ├── common_vars.yml            # Users, SSH keys, system settings
│       ├── agave_vars.yml             # Agave-specific configuration
│       ├── jito_vars.yml              # Jito-specific configuration
│       └── firedancer_vars.yml        # Firedancer-specific configuration
├── roles/
│   ├── common/                        # 11 hardening & optimization roles
│   │   ├── create_users/
│   │   ├── ssh_keys/
│   │   ├── fail2ban/
│   │   ├── server_settings/
│   │   ├── ntp/
│   │   ├── rpc_firewall/
│   │   ├── ring_buffers/
│   │   ├── docker/
│   │   ├── github/
│   │   ├── sol_bashrc/
│   │   └── ssh_keys_github/
│   ├── agave/                         # Agave build + service setup
│   │   ├── agave_compile/
│   │   └── agave_systemd/
│   ├── jito/                          # Jito build + upgrade workflows
│   │   ├── jito_compile/
│   │   ├── jito_systemd/
│   │   ├── jito_upgrade/
│   │   └── jito_preflight/
│   └── firedancer/                    # Firedancer build automation
│       ├── frankendancer_compile/
│       └── frankendancer_systemd/
└── collections/
    └── requirements.yml               # Ansible collection dependencies
```

## Real-World Workflows

### Scenario 1: New Validator Fleet
Provision 5 fresh Ubuntu servers:
```bash
# Single command: bare server → production validator
ansible-playbook playbooks/sol_validator.yml --limit primary_validators

# Result:
# - Users created with SSH access
# - System hardened (fail2ban, firewall, sysctl tuning)
# - Validator compiled from source
# - systemd service configured
# - Log rotation enabled
# - Ready to start validating
```

### Scenario 2: Zero-Downtime Jito Upgrade
```bash
# 1. Update version in playbook
vim playbooks/sol_validator.yml  # Change jito_upgrade_version

# 2. Run upgrade workflow
ansible-playbook playbooks/sol_validator.yml --tags jito-upgrade

# What happens:
# - New version compiles alongside existing binary
# - Validator service stops gracefully
# - Binaries swapped atomically
# - Service restarts with new version
# - Old version retained for rollback
```

### Scenario 3: Onboard New Team Member
```bash
# 1. Add to common_vars.yml
server_users:
  - alice
  - bob
  - charlie  # new

# 2. Add SSH public key
ssh_public_keys:
  - "ssh-ed25519 AAAA... charlie@example.com"

# 3. Apply changes (idempotent)
ansible-playbook playbooks/sol_validator.yml --tags create_users,ssh_keys

# Result: Charlie can SSH to all validators immediately
```

### Scenario 4: Pre-Production Validation
```bash
# After deploying Jito, validate before going live
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight --limit validator-01

# Preflight checks:
# ✓ Rust toolchain versions
# ✓ System dependencies installed
# ✓ Correct repository version
# ✓ Binary exists and matches version
# ✓ Configuration files valid
# ✓ Network settings correct
# ✓ Required directories present
# ✓ Sufficient system resources

# All checks pass → Safe to start validator
```

## Validator Client Support

| Client | Compile | Upgrade | Preflight | Networks | Status |
|--------|---------|---------|-----------|----------|--------|
| **Agave** | ✅ | - | - | Mainnet, Testnet | Production |
| **Jito** | ✅ | ✅ | ✅ | Mainnet, Testnet, BAM | Production |
| **Firedancer** | ✅ | - | - | Testnet | Beta |

### Agave Features
- Compile from anza-xyz/agave repository
- systemd service management
- Log rotation configuration
- Cron task automation
- Mainnet and testnet support

### Jito Features
- Compile from jito-foundation/jito-solana repository
- Zero-downtime upgrade workflow
- Comprehensive preflight validation
- systemd service management
- Mainnet, testnet, and BAM network support

### Firedancer Features
- Compile from firedancer-io/firedancer repository
- Automated dependency management (deps.sh)
- LLVM/Clang toolchain configuration
- systemd service management
- Testnet support (mainnet in development)

## Production-Ready Design

**Idempotency**: Run the same playbook 100 times → same result. Safe for automation.

**Modularity**: Use only what you need via Ansible tags and role selection.

**Auditability**: Every change explicit in version control. No hidden state.

**Transparency**: No secret managers or external dependencies. Bring your own credentials.

**Validation**: Preflight checks catch configuration issues before production impact.

**Maintainability**: Simple shell tasks and Jinja2 templates, not complex abstractions.

## Deployment Validation

Run preflight checks before starting validators:

```bash
ansible-playbook playbooks/sol_validator.yml --tags jito-preflight
```

**Validation coverage**:
- ✓ Rust toolchain (rustc, cargo, rustfmt)
- ✓ System packages (build dependencies)
- ✓ Repository state (correct version, clean working tree)
- ✓ Binary installation (exists, correct version)
- ✓ Configuration files (validator script, environment)
- ✓ Network settings (entrypoints, block engine URLs)
- ✓ Directory structure (ledger, accounts, snapshots)
- ✓ System resources (memory, CPU, disk)

**Output**:
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

## Tag-Based Operations

Ansible tags provide granular control over what runs:

```bash
# Common roles only (no validator build)
--tags common

# Specific validator builds
--tags agave-compile
--tags jito-compile
--tags firedancer-compile

# Jito operations
--tags jito-upgrade        # Zero-downtime version upgrade
--tags jito-preflight      # Pre-production validation

# Individual common roles
--tags create_users
--tags ssh_keys
--tags fail2ban
--tags server_settings
--tags ntp
--tags rpc_firewall
--tags ring_buffers
```

## Limitations

- **Platform**: Tested on Ubuntu 20.04/22.04 x86_64 (extensible to other Debian-based distros)
- **Scope**: Provisioning and upgrades only (monitoring requires separate tooling)
- **Secrets**: SSH keys and credentials in vars files (adapt for your secret management system)
- **Network**: Assumes outbound internet access for package downloads (adjust for air-gapped environments)
- **State**: No built-in rollback automation (manual service rollback supported via retained binaries)

## Roadmap

- [ ] Agave zero-downtime upgrade workflow
- [ ] Firedancer mainnet support and upgrade workflow
- [ ] Automated rollback on failed upgrades
- [ ] Snapshot management automation
- [ ] Ledger cleanup and disk management
- [ ] Multi-region deployment patterns
- [x] Jito zero-downtime upgrades
- [x] Preflight validation checks
- [x] Multi-client support (Agave, Jito, Firedancer)

## References

**Solana Validator Documentation:**
- [Solana Validator Guide](https://docs.solanalabs.com/operations/guides)
- [Agave Repository](https://github.com/anza-xyz/agave)
- [Jito Repository](https://github.com/jito-foundation/jito-solana)
- [Firedancer Repository](https://github.com/firedancer-io/firedancer)

**Ansible Best Practices:**
- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)

## Contributing

Issues and feedback are welcome. Not currently accepting pull requests.

## License

Apache-2.0. See [LICENSE](LICENSE).
