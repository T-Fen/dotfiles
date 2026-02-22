#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — CachyOS Fresh Install Bootstrap
#
# This is the ONE script to run on a fresh CachyOS machine.
# It handles everything: packages, dotfiles, shell, configs.
#
# Usage:
#   bash bootstrap.sh
#
# Or run directly from GitHub:
#   bash <(curl -fsSL https://raw.githubusercontent.com/YOURUSERNAME/dotfiles/master/bootstrap.sh)
# =============================================================================

set -euo pipefail

# ── Config — edit these ───────────────────────────────────────────────────────
GITHUB_USERNAME="T-Fen"
DOTFILES_REPO="git@github.com:${GITHUB_USERNAME}/dotfiles.git"
DOTFILES_PATH="${HOME}/dotfiles"
YOUR_NAME="Trey"
YOUR_EMAIL="hjsizemore@gmail.com"

# ── Colors ────────────────────────────────────────────────────────────────────
C_GREEN="\e[0;32;1m"
C_CYAN="\e[0;36;1m"
C_YELLOW="\e[0;33;1m"
C_RED="\e[0;31;1m"
C_RESET="\e[0m"

info() { printf "\n%b▶ %s%b\n" "${C_CYAN}" "${1}" "${C_RESET}"; }
success() { printf "%b✓ %s%b\n" "${C_GREEN}" "${1}" "${C_RESET}"; }
warn() { printf "%b⚠ %s%b\n" "${C_YELLOW}" "${1}" "${C_RESET}"; }
error() { printf "%b✗ %s%b\n" "${C_RED}" "${1}" "${C_RESET}"; }

LOG_FILE="${HOME}/bootstrap-$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

echo "╔══════════════════════════════════════════════════════╗"
echo "║        CachyOS Bootstrap — Full System Setup        ║"
echo "╚══════════════════════════════════════════════════════╝"
echo "  Log: ${LOG_FILE}"
echo ""

# ── Step 1: System update ─────────────────────────────────────────────────────
info "Step 1: System update"
sudo pacman -Syu --noconfirm
success "System updated"

# ── Step 2: Base dependencies ─────────────────────────────────────────────────
info "Step 2: Installing base dependencies"
sudo pacman -S --needed --noconfirm git base-devel ansible
success "Base dependencies installed"

# ── Step 3: Fix pacman.conf wildcard Include ──────────────────────────────────
info "Step 3: Fixing pacman.conf"
if grep -q "Include = /etc/pacman.d/\*.conf" /etc/pacman.conf; then
  sudo sed -i '/^Include = \/etc\/pacman\.d\/\*\.conf/d' /etc/pacman.conf
  success "Removed wildcard Include from pacman.conf"
else
  success "pacman.conf already clean"
fi

# ── Step 4: Install CachyOS kernel headers ────────────────────────────────────
info "Step 4: Installing kernel headers"
sudo pacman -S --needed --noconfirm linux-cachyos-headers || warn "Could not install linux-cachyos-headers"
success "Kernel headers done"

# ── Step 5: SSH key ───────────────────────────────────────────────────────────
info "Step 5: Setting up SSH key"
if [[ ! -f "${HOME}/.ssh/id_ed25519" ]]; then
  ssh-keygen -t ed25519 -C "${YOUR_EMAIL}" -N "" -f "${HOME}/.ssh/id_ed25519"
  echo ""
  warn "Add this SSH key to GitHub before continuing:"
  echo "https://github.com/settings/keys"
  echo ""
  cat "${HOME}/.ssh/id_ed25519.pub"
  echo ""
  read -rp "Press Enter once you've added the key to GitHub..."
else
  success "SSH key already exists"
fi

# Test GitHub connection
ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" &&
  success "GitHub SSH connection verified" ||
  warn "Could not verify GitHub SSH — continuing anyway"

# ── Step 6: Clone dotfiles ────────────────────────────────────────────────────
info "Step 6: Cloning dotfiles"
if [[ -d "${DOTFILES_PATH}" ]]; then
  success "Dotfiles already cloned at ${DOTFILES_PATH}"
else
  git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}"
  success "Dotfiles cloned"
fi

# ── Step 7: Set up install-config ────────────────────────────────────────────
info "Step 7: Configuring install-config"
if [[ ! -f "${DOTFILES_PATH}/install-config" ]]; then
  cp "${DOTFILES_PATH}/install-config.example" "${DOTFILES_PATH}/install-config"
fi

# Comment out empty arrays
sed -i 's/^export \(PACKAGES_\|MISE_\|CONFIG_INSTALL\|SYSTEMD_ENABLED_SERVICES\|SUDOERS_ENTRIES\)/#export \1/' \
  "${DOTFILES_PATH}/install-config"
sed -i 's/^declare -A \(MISE_\|SUDOERS_\)/#declare -A \1/' \
  "${DOTFILES_PATH}/install-config"

# Set GUI_LINUX=1
sed -i 's/^export GUI_LINUX=$/export GUI_LINUX=1/' "${DOTFILES_PATH}/install-config"

# Set DOTFILES_PATH
grep -q "DOTFILES_PATH" "${DOTFILES_PATH}/install-config" ||
  echo 'export DOTFILES_PATH="${HOME}/dotfiles"' >>"${DOTFILES_PATH}/install-config"

success "install-config configured"

# ── Step 8: Patch install script for CachyOS kernel ──────────────────────────
info "Step 8: Patching install script for CachyOS kernel"
if ! grep -q "cachyos" "${DOTFILES_PATH}/install"; then
  sed -i 's/\(\*zen\*)\n\s*kernel_package="linux-zen-headers"\n\s*;;\)/\1\n  *cachyos*)\n    kernel_package="linux-cachyos-headers"\n    ;;/' \
    "${DOTFILES_PATH}/install" ||
    # Fallback: Python-based sed for multiline
    python3 -c "
import re, sys
content = open('${DOTFILES_PATH}/install').read()
patch = '''  *zen*)
    kernel_package=\"linux-zen-headers\"
    ;;
  *cachyos*)
    kernel_package=\"linux-cachyos-headers\"
    ;;'''
content = content.replace('  *zen*)\n    kernel_package=\"linux-zen-headers\"\n    ;;', patch)
open('${DOTFILES_PATH}/install', 'w').write(content)
"
  success "Install script patched for CachyOS kernel"
else
  success "Install script already has CachyOS kernel support"
fi

# ── Step 9: Install packages via Ansible ─────────────────────────────────────
info "Step 9: Installing packages via Ansible"
if [[ -f "${DOTFILES_PATH}/ansible/playbook.yml" ]]; then
  ansible-playbook \
    -i "${DOTFILES_PATH}/ansible/inventory.ini" \
    "${DOTFILES_PATH}/ansible/playbook.yml" \
    --extra-vars "github_username=${GITHUB_USERNAME}"
  success "Ansible playbook complete"
else
  warn "Ansible playbook not found — skipping package installation"
fi

# ── Step 10: Apply chezmoi dotfiles ──────────────────────────────────────────
info "Step 10: Applying chezmoi dotfiles"
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
fi

if [[ -d "${DOTFILES_PATH}/chezmoi" ]]; then
  chezmoi init --source "${DOTFILES_PATH}/chezmoi" --apply
  success "chezmoi dotfiles applied"
else
  warn "No chezmoi directory found in dotfiles — skipping"
fi

# ── Step 11: Set zsh as default shell ────────────────────────────────────────
info "Step 11: Setting zsh as default shell"
if [[ "${SHELL}" != "/usr/bin/zsh" ]]; then
  sudo usermod -s /usr/bin/zsh "${USER}"
  success "Default shell set to zsh (takes effect on next login)"
else
  success "zsh already default shell"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║                  Bootstrap Complete!                 ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Log saved to: ${LOG_FILE}"
echo ""
echo "  Next steps:"
echo "  1. Log out and log back in (to activate zsh)"
echo "  2. Open Kitty — fastfetch should run automatically"
echo "  3. Check log for any [warn] messages about failed packages"
echo ""
echo "  AppImages to install manually:"
echo "  • Espanso: https://github.com/espanso/espanso/releases"
echo "  → Save to ~/Applications/ and chmod +x"
