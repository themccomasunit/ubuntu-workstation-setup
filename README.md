# Ubuntu Workstation Setup

Automated Ansible configuration for Ubuntu development environments with MATE desktop and RDP support. This is the Ubuntu equivalent of the [Windows Workstation Setup](https://github.com/themccomasunit/windows-workstation-setup) repository.

## What Gets Installed

### Development Tools
- **Git** - Version control (configured with your identity)
- **GitHub CLI (gh)** - Command-line interface for GitHub
- **Visual Studio Code** - Code editor
- **Claude Code Extension** - AI coding assistant for VS Code
- **Python 3** - Python programming language with pip and venv
- **Google Chrome** - Web browser
- **Azure CLI** - Command-line interface for Azure

### Desktop Environment
- **Ubuntu MATE Desktop** - Lightweight, traditional desktop environment
- **LightDM** - Display manager
- **xrdp** - Remote Desktop Protocol server for remote access

### User Configuration
- **RDP User** - Dedicated user account for remote desktop access
- **Git Configuration** - Pre-configured with your name and email
- **Desktop Session** - Properly configured MATE session for RDP

## Quick Start

### One-Line Install (from SSH)

Connect to your Ubuntu system via SSH and run:

```bash
curl -fsSL https://raw.githubusercontent.com/themccomasunit/ubuntu-workstation-setup/main/bootstrap.sh | sudo bash
```

**Important:** This uses default settings. For production use, customize the configuration first (see Manual Installation below).

### Manual Installation (Recommended)

For full control over configuration:

```bash
# Clone the repository
git clone https://github.com/themccomasunit/ubuntu-workstation-setup.git
cd ubuntu-workstation-setup

# IMPORTANT: Edit configuration with your settings
nano group_vars/all.yml

# Update these values:
# - git_user_name: Your name
# - git_user_email: Your email
# - rdp_user: Username for RDP access
# - rdp_password: CHANGE THIS TO A SECURE PASSWORD!

# Run the setup
sudo ./bootstrap.sh
```

## Requirements

- **Ubuntu 20.04 LTS or later** (tested on Ubuntu 24.04)
- **Root or sudo access**
- **Internet connection**
- **Minimum 4GB RAM** (8GB+ recommended for desktop environment)
- **20GB free disk space** (for desktop environment and tools)

## Project Structure

```
ubuntu-workstation-setup/
├── bootstrap.sh                     # Bootstrap script for easy deployment
├── playbook.yml                     # Main Ansible playbook
├── ansible.cfg                      # Ansible configuration
├── group_vars/
│   └── all.yml                     # Configuration variables (EDIT THIS!)
└── roles/
    ├── common/
    │   └── tasks/
    │       └── main.yml            # System updates and prerequisites
    ├── software/
    │   └── tasks/
    │       └── main.yml            # Software installation
    ├── desktop/
    │   └── tasks/
    │       └── main.yml            # MATE desktop installation
    └── rdp/
        └── tasks/
            └── main.yml            # RDP configuration
```

## Configuration

All configuration is managed through [group_vars/all.yml](group_vars/all.yml):

```yaml
# Git configuration
git_user_name: "Your Name"
git_user_email: "your.email@example.com"

# RDP user configuration
rdp_user: "rdpuser"
rdp_password: "ChangeMe123!"  # CHANGE THIS!

# Desktop environment
desktop_environment: "ubuntu-mate-desktop"
```

### Security Best Practices

1. **Change the default RDP password** before running the playbook
2. Use a strong password (12+ characters, mixed case, numbers, symbols)
3. Consider using SSH key authentication instead of passwords
4. Configure firewall rules to restrict RDP access to known IP addresses
5. Keep your system updated regularly

## Post-Installation

After the setup completes and you reboot:

### 1. Connect via RDP

Use any RDP client (Microsoft Remote Desktop, Remmina, etc.):

- **Host:** `<your-server-ip>:3389`
- **Username:** Value from `rdp_user` in config (default: `rdpuser`)
- **Password:** Value from `rdp_password` in config

#### RDP Client Downloads:
- **Windows:** Built-in Remote Desktop Connection (`mstsc.exe`)
- **macOS:** [Microsoft Remote Desktop](https://apps.apple.com/app/microsoft-remote-desktop/id1295203466)
- **Linux:** Remmina (pre-installed on many distributions)
- **iOS/Android:** Microsoft Remote Desktop app

### 2. Authenticate GitHub CLI

In a terminal (locally or via RDP):

```bash
gh auth login
```

Follow the prompts to authenticate with your GitHub account.

### 3. Authenticate Claude Code

In Visual Studio Code:
1. Open VS Code
2. Click the Claude Code icon in the left sidebar
3. Sign in with your Anthropic account

### 4. Authenticate Azure CLI (Optional)

If you need Azure access:

```bash
az login
```

## Usage from Bastion Host

This setup is ideal for deployment via bastion hosts or jump servers:

```bash
# SSH to your target Ubuntu system
ssh user@target-system

# Run the bootstrap script
curl -fsSL https://raw.githubusercontent.com/themccomasunit/ubuntu-workstation-setup/main/bootstrap.sh | sudo bash

# Or with custom configuration:
git clone https://github.com/themccomasunit/ubuntu-workstation-setup.git
cd ubuntu-workstation-setup
nano group_vars/all.yml  # Edit configuration
sudo ./bootstrap.sh
```

## Firewall Configuration

If you need to configure firewall rules for RDP access:

```bash
# Allow RDP from specific IP
sudo ufw allow from 192.168.1.0/24 to any port 3389 proto tcp

# Or allow RDP from anywhere (not recommended for production)
sudo ufw allow 3389/tcp

# Enable firewall
sudo ufw enable
```

## Troubleshooting

### RDP Connection Fails

1. Check if xrdp is running:
   ```bash
   sudo systemctl status xrdp
   ```

2. Restart xrdp service:
   ```bash
   sudo systemctl restart xrdp
   ```

3. Check firewall settings:
   ```bash
   sudo ufw status
   ```

4. Verify port 3389 is listening:
   ```bash
   sudo ss -tlnp | grep 3389
   ```

### Desktop Environment Not Loading

1. Check .xsessionrc file exists:
   ```bash
   cat ~/.xsessionrc
   ```

2. Ensure MATE is installed:
   ```bash
   dpkg -l | grep ubuntu-mate-desktop
   ```

3. Check logs:
   ```bash
   cat ~/.xsession-errors
   ```

### VS Code Extension Install Fails

Install manually:
```bash
code --install-extension anthropic.claude-code --force
```

Or install through VS Code GUI:
1. Open VS Code
2. Press `Ctrl+Shift+X` (Extensions)
3. Search "Claude Code"
4. Click Install

### GitHub CLI Not Working

Reinstall GitHub CLI:
```bash
sudo apt update
sudo apt install --reinstall gh
```

### Azure CLI Issues

Reinstall via official script:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Customization

### Adding Additional Software

Edit [roles/software/tasks/main.yml](roles/software/tasks/main.yml) and add tasks following this pattern:

```yaml
- name: Install additional package
  apt:
    name: package-name
    state: present
```

### Using Different Desktop Environment

Edit [group_vars/all.yml](group_vars/all.yml):

```yaml
desktop_environment: "ubuntu-desktop"  # or "xubuntu-desktop", "kubuntu-desktop"
```

### Skipping Desktop/RDP Installation

Edit [playbook.yml](playbook.yml) and comment out unwanted roles:

```yaml
roles:
  - common
  - software
  # - desktop  # Skip desktop installation
  # - rdp      # Skip RDP configuration
```

## Comparison with Windows Setup

| Feature | Windows Setup | Ubuntu Setup |
|---------|--------------|--------------|
| Configuration Method | PowerShell | Ansible |
| Package Manager | winget | apt |
| Desktop Environment | Windows UI | Ubuntu MATE |
| Remote Access | Built-in RDP | xrdp |
| Automation Approach | PowerShell scripts | Ansible playbooks |
| One-line Install | ✅ Bootstrap script | ✅ Bootstrap script |

## Maintenance

### Update All Software

```bash
sudo apt update && sudo apt upgrade -y
```

### Re-run Playbook

Ansible is idempotent, so you can safely re-run the playbook:

```bash
cd ubuntu-workstation-setup
sudo ansible-playbook playbook.yml
```

### Update from Repository

```bash
cd ubuntu-workstation-setup
git pull
sudo ansible-playbook playbook.yml
```

## Performance Considerations

- **Headless Mode:** If you don't need GUI, skip desktop/RDP roles to save ~2GB RAM
- **Lightweight Alternative:** Consider XFCE instead of MATE for lower resource usage
- **Cloud Optimization:** For cloud VMs, consider using X2Go instead of RDP for better performance

## Security Notes

- RDP is exposed on port 3389 by default
- Use firewall rules to restrict access
- Consider VPN or SSH tunneling for RDP in production
- Regularly update system packages
- Monitor `/var/log/auth.log` for unauthorized access attempts

## License

MIT License - Feel free to use and modify for your needs.

## Contributing

Issues and pull requests welcome at [github.com/themccomasunit/ubuntu-workstation-setup](https://github.com/themccomasunit/ubuntu-workstation-setup)

## Related Projects

- [Windows Workstation Setup](https://github.com/themccomasunit/windows-workstation-setup) - PowerShell-based Windows development environment setup

---

**Author:** themccomasunit
**Last Updated:** 2026-01-19
