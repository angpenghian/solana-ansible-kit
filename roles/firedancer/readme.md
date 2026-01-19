# Firedancer Validator Role

This role automates the installation, configuration, and management of the Firedancer Solana validator implementation. Firedancer is a high-performance validator client optimized for speed and efficiency.

## Overview

The Firedancer role consists of two main components:
- **`prereqs_install`**: Installs Firedancer-specific dependencies and build requirements
- **`validator_compile`**: Compiles, configures, and sets up Firedancer validator with optimized settings

## Current Configuration

- **Version**: v0.708.20306 (testnet)
- **Network**: Testnet
- **User**: sol
- **Installation Path**: `/home/sol/firedancer`
- **Configuration**: `/home/sol/firedancer/config.toml`
- **Service**: `frankendancer.service`

## Prerequisites

- Ubuntu/Debian system
- Root access for system configuration
- Minimum 32GB RAM recommended
- Multi-core CPU (AMD EPYC 7402P 24C/48T or AMD Ryzen 9 9950X 16C/32T)
- SSD storage for ledger and accounts

## Installation Process

### 1. Dependencies Installation
The role installs required build dependencies:
- Rust toolchain (latest stable)
- Build tools: gcc, clang, cmake, make
- Libraries: libssl-dev, libudev-dev, libprotobuf-dev, libgmp-dev
- Development tools: pkg-config, autoconf, automake, bison, flex

### 2. Firedancer Compilation
```bash
# Clone repository with submodules
git clone --recurse-submodules https://github.com/firedancer-io/firedancer.git

# Checkout specific version
git checkout tags/v0.708.20306

# Update submodules
git submodule update --init --recursive

# Install additional dependencies
./deps.sh

# Compile fdctl and solana binaries
make -j fdctl solana
```

### 3. Configuration
The role creates a comprehensive `config.toml` with:
- Testnet entrypoints
- CPU affinity settings
- Memory and storage paths
- RPC configuration
- Consensus settings

## Usage Commands

### 1. Memory Layout Check
Check memory layout and CPU affinity configuration:
```bash
/home/sol/firedancer/build/native/gcc/bin/fdctl mem --config /home/sol/firedancer/config.toml
```

**Important**: Ensure `affinity` and `solana_labs_affinity` do not overlap in the `[layout]` section.

### 2. Compilation
Build the required binaries:
```bash
make -j fdctl solana
```

### 3. System Initialization
Configure system settings (must be run as root after building):
```bash
sudo /home/sol/firedancer/build/native/gcc/bin/fdctl configure init all --config /home/sol/firedancer/config.toml
```

This command configures:
- Huge pages
- Kernel parameters
- CPU affinities
- Network device settings

### 4. Verify Initialization
Check if initialization was successful:
```bash
/home/sol/firedancer/build/native/gcc/bin/fdctl configure check all
```

Reference: [Firedancer Initialization Guide](https://docs.firedancer.io/guide/initializing.html)

### 5. Run Validator
Start the Firedancer validator:
```bash
sudo /home/sol/firedancer/build/native/gcc/bin/fdctl run --config /home/sol/firedancer/config.toml
```

### 6. Monitoring

#### View Logs
Monitor validator logs using systemd journal:
```bash
journalctl -f -u frankendancer
```

#### Real-time Monitoring
Monitor Firedancer performance and status:
```bash
fdctl monitor --config config.toml
```

## Configuration Details

### CPU Affinity (AMD EPYC 7402P - 24C/48T)
```toml
[layout]
    affinity = "0-35"                    # Firedancer cores
    agave_affinity = "36-43"            # Solana Labs cores (no overlap!)
    agave_unified_scheduler_handler_threads = 0
    net_tile_count = 1
    quic_tile_count = 1
    resolv_tile_count = 1
    verify_tile_count = 5
    bank_tile_count = 15
    shred_tile_count = 2
```

### Alternative Configuration (AMD Ryzen 9 9950X - 16C/32T)
```toml
[layout]
    affinity = "0-25"                    # Firedancer cores
    agave_affinity = "26-29"            # Solana Labs cores (no overlap!)
    # ... other settings
```

### Network Configuration
- **Testnet Entrypoints**:
  - entrypoint.testnet.solana.com:8001
  - entrypoint2.testnet.solana.com:8001
  - entrypoint3.testnet.solana.com:8001

### Storage Paths
- **Ledger**: `/mnt/ledger`
- **Accounts**: `/mnt/accounts`
- **Snapshots**: `/mnt/snapshots`
- **Logs**: `/var/log/solana/solana-validator.log`

## Service Management

The role creates a systemd service `frankendancer.service`:

```bash
# Start service
sudo systemctl start frankendancer

# Stop service
sudo systemctl stop frankendancer

# Enable auto-start
sudo systemctl enable frankendancer

# Check status
sudo systemctl status frankendancer
```

## Troubleshooting

### Common Issues

1. **Memory Layout Conflicts**
   - Check CPU affinity overlap: `fdctl mem --config config.toml`
   - Ensure `affinity` and `agave_affinity` don't overlap

2. **Initialization Failures**
   - Run as root: `sudo fdctl configure init all --config config.toml`
   - Check system requirements: `fdctl configure check all`

3. **Service Startup Issues**
   - Check logs: `journalctl -u frankendancer -f`
   - Verify configuration: `fdctl configure check all`

4. **Build Failures**
   - Ensure all dependencies installed: `./deps.sh`
   - Check Rust version: `rustc --version`
   - Clean and rebuild: `make clean && make -j fdctl solana`

### Log Locations
- **Service Logs**: `journalctl -u frankendancer`
- **Validator Logs**: `/var/log/solana/solana-validator.log`
- **Build Logs**: Check terminal output during compilation

## Ansible Integration

### Tags
- `firedancer-compile`: Compile and configure Firedancer

### Variables
- `firedancer_install_version`: v0.708.20306
- `firedancer_network`: testnet
- `firedancer_dependencies`: List of required packages

### Usage in Playbook
```yaml
- role: firedancer/prereqs_install
  tags: [firedancer-compile]
- role: firedancer/validator_compile
  tags: [firedancer-compile]
```

## Performance Optimization

### CPU Affinity
- **Critical**: Ensure Firedancer and Solana Labs affinities don't overlap
- Use `fdctl mem` command to verify configuration
- Adjust based on your CPU architecture

### Memory Requirements
- Minimum 32GB RAM recommended
- Configure huge pages during initialization
- Monitor memory usage with `fdctl monitor`

### Storage
- Use high-performance SSD storage
- Separate drives for ledger and accounts recommended
- Monitor disk I/O during operation

## Security Considerations

- Run validator as dedicated `sol` user
- Initialization requires root privileges
- Secure validator keypairs in `/home/sol/peng-keys/`
- Monitor system resources and network connections

## References

- [Firedancer Documentation](https://docs.firedancer.io/)
- [Firedancer GitHub Repository](https://github.com/firedancer-io/firedancer)
- [Solana Documentation](https://docs.solana.com/)
- [Firedancer Configuration Guide](https://docs.firedancer.io/guide/configuring.html)
- [Firedancer Initialization Guide](https://docs.firedancer.io/guide/initializing.html)

## Support

For issues specific to this Ansible role, check:
1. Ansible playbook execution logs
2. Systemd service status and logs
3. Firedancer configuration validation
4. System resource availability

For Firedancer-specific issues, refer to the official documentation and community resources.