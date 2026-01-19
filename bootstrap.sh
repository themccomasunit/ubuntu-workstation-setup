#!/bin/bash
#
# Ubuntu Workstation Setup - Bootstrap Script
#
# This script can be run directly from an SSH session to set up an Ubuntu
# workstation with XFCE desktop, RDP access, and development tools.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/themccomasunit/ubuntu-workstation-setup/main/bootstrap.sh | bash
#
# Or for custom configuration:
#   git clone https://github.com/themccomasunit/ubuntu-workstation-setup.git
#   cd ubuntu-workstation-setup
#   # Edit group_vars/all.yml with your settings
#   ./bootstrap.sh

set -e

# Color output functions
print_status() {
    echo -e "\n\033[1;36m[*] $1\033[0m"
}

print_success() {
    echo -e "\033[1;32m[+] $1\033[0m"
}

print_error() {
    echo -e "\033[1;31m[-] $1\033[0m"
}

print_warning() {
    echo -e "\033[1;33m[!] $1\033[0m"
}

# Banner
cat << "EOF"

╔═══════════════════════════════════════════════════════════════╗
║         Ubuntu Workstation Setup - Bootstrap                  ║
║                   themccomasunit                              ║
╚═══════════════════════════════════════════════════════════════╝

EOF

print_status "Starting bootstrap process..."

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root or with sudo"
    echo "Please run: sudo $0"
    exit 1
fi

# Check if this is Ubuntu
if [ ! -f /etc/lsb-release ]; then
    print_error "This script is designed for Ubuntu systems"
    exit 1
fi

source /etc/lsb-release
print_status "Detected: $DISTRIB_DESCRIPTION"

# Update package lists
print_status "Updating package lists..."
apt-get update -qq

# Install Ansible if not present
if ! command -v ansible-playbook &> /dev/null; then
    print_status "Installing Ansible..."
    apt-get install -y ansible
    print_success "Ansible installed successfully"
else
    print_success "Ansible is already installed"
fi

# Determine if we're running from a cloned repo or need to clone
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

if [ -f "$SCRIPT_DIR/playbook.yml" ]; then
    print_success "Running from local repository"
    PLAYBOOK_DIR="$SCRIPT_DIR"
else
    print_status "Cloning repository from GitHub..."
    TEMP_DIR=$(mktemp -d)
    git clone https://github.com/themccomasunit/ubuntu-workstation-setup.git "$TEMP_DIR"
    PLAYBOOK_DIR="$TEMP_DIR"
    print_success "Repository cloned to $TEMP_DIR"
fi

cd "$PLAYBOOK_DIR"

# Check if variables file exists
if [ ! -f "$PLAYBOOK_DIR/group_vars/all.yml" ]; then
    print_error "Configuration file not found: group_vars/all.yml"
    exit 1
fi

# Display important security notice
print_warning "IMPORTANT: Review and update your configuration before running!"
echo ""
echo "Configuration file: $PLAYBOOK_DIR/group_vars/all.yml"
echo ""
print_warning "Please ensure you have changed the default RDP password!"
echo ""

# Ask for confirmation
read -p "Continue with the setup? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    print_status "Setup cancelled by user"
    exit 0
fi

# Run the Ansible playbook
print_status "Running Ansible playbook..."
echo ""

ansible-playbook playbook.yml

# Capture exit code
PLAYBOOK_EXIT_CODE=$?

if [ $PLAYBOOK_EXIT_CODE -eq 0 ]; then
    print_success "Setup completed successfully!"
    echo ""
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════╗
║                    SETUP COMPLETE!                            ║
╚═══════════════════════════════════════════════════════════════╝

Your Ubuntu workstation has been configured with:
  - Development tools (Git, GitHub CLI, VS Code, Python, Azure CLI, Chrome)
  - XFCE Desktop Environment (optimized for RDP performance)
  - RDP access via xrdp (port 3389)

Post-Installation Steps:

  1. Reboot the system:
     sudo reboot

  2. Connect via RDP:
     - Use your RDP client to connect to this server's IP on port 3389
     - Login with the RDP user credentials from group_vars/all.yml

  3. Authenticate GitHub CLI (in terminal):
     gh auth login

  4. Authenticate Claude Code (in VS Code):
     - Open VS Code
     - Click Claude Code icon in sidebar
     - Sign in with your Anthropic account

  5. Authenticate Azure CLI (if needed):
     az login

Security Reminders:
  - Change the RDP user password if you haven't already
  - Configure firewall rules to restrict RDP access if needed
  - Keep your system updated: sudo apt update && sudo apt upgrade

EOF
else
    print_error "Setup encountered errors (exit code: $PLAYBOOK_EXIT_CODE)"
    print_status "Please review the output above for details"
    exit $PLAYBOOK_EXIT_CODE
fi

# Cleanup temp directory if used
if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    rm -rf "$TEMP_DIR"
fi

print_success "Bootstrap complete!"
