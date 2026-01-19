# Solana Ansible Kit

Ansible automation to provision and operate Solana validator fleets (Agave, Jito, Firedancer) with opinionated host hardening, performance tuning, and repeatable upgrades. This repo is intentionally simple and resume-ready: it shows real-world infra patterns without internal company details.

## Highlights
- Multi-validator support with tagged installs/upgrades
- Host hardening, baseline packages, and performance tuning
- Optional monitoring agent + health check integration
- Idempotent roles designed for repeatable runs

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
│       ├── jito_vars.yml
│       └── monitor.yml
├── roles/
│   ├── agave/
│   ├── common/
│   ├── firedancer/
│   ├── jito/
│   └── monitor/
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

3) Run preflight or a full provisioning
```bash
ansible-playbook playbooks/fresh_validator.yml --limit primary_validators
```

4) Use tags to target installs/upgrades
```bash
ansible-playbook playbooks/fresh_validator.yml --tags agave-install
ansible-playbook playbooks/fresh_validator.yml --tags jito-upgrade
ansible-playbook playbooks/fresh_validator.yml --tags firedancer-install
```

## Optional Integrations
- `monitor/site24x7_install`: vendor agent example (requires `site24x7_device_key`)
- `monitor/validator_health_check`: custom health check repo placeholder in `playbooks/vars/monitor.yml`

## Notes
- `docs/` is local-only and gitignored by default for portfolio planning.
- This repo uses placeholder inventory entries; replace with your own targets.

## License
Internal portfolio use. Replace or add a license if you publish this publicly.
