# Solana Ansible Kit

Ansible automation to provision and operate Solana validator fleets (Agave, Jito, Firedancer). The goal is a simple, resume-ready repo that demonstrates real-world infra patterns.

## Vision
Make validator fleet ops repeatable: compile, configure, harden, and upgrade in a clean, auditable way.

## Why this is trustworthy
- Idempotent roles and tagged runs for predictable changes
- Explicit variables and placeholders instead of hidden secrets
- Clear inventory structure and minimal assumptions

## How it works (high-level)
```
Inventory + vars
      |
      v
Common hardening + tuning
      |
      v
Validator compile + service setup
```

## Repository Structure
```
solana-ansible-kit/
├── ansible.cfg
├── collections/
│   └── requirements.yml
├── inventory/
│   └── hosts.yml
├── playbooks/
│   ├── fresh_validator.yml
│   └── vars/
│       ├── agave_vars.yml
│       ├── common_vars.yml
│       ├── firedancer_vars.yml
│       └── jito_vars.yml
├── roles/
│   ├── agave/
│   ├── common/
│   ├── firedancer/
│   └── jito/
└── README.md
```

## Quick Start
1) Install collections
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

2) Update inventory and vars
- Edit `inventory/hosts.yml`
- Add SSH keys and user list in `playbooks/vars/common_vars.yml`
- Adjust validator versions and networks in `playbooks/fresh_validator.yml`

3) Run preflight or a full provisioning (from repo root)
```bash
ansible-playbook playbooks/fresh_validator.yml --limit primary_validators
```

4) Use tags to target compiles/upgrades
```bash
ansible-playbook playbooks/fresh_validator.yml --tags agave-compile
ansible-playbook playbooks/fresh_validator.yml --tags jito-upgrade
ansible-playbook playbooks/fresh_validator.yml --tags firedancer-compile
```

## Notes
- `docs/` is local-only and gitignored by default for portfolio planning.
- This repo uses placeholder inventory entries; replace with your own targets.
- Keep changes minimal and auditable; prefer the simplest path that works.

## License
Internal portfolio use. Replace or add a license if you publish this publicly.
