#!/usr/bin/env bash
# =============================================================================
# bootstrap.sh — CachyOS Fresh Install Bootstrap
#
# Run this on any fresh CachyOS machine to fully replicate your environment.
#
# Usage (from USB):
#   bash /run/media/trey/PATRIOT/bootstrap.sh
#
# Usage (from GitHub):
#   bash <(curl -fsSL https://raw.githubusercontent.com/T-Fen/dotfiles/master/bootstrap.sh)
# =============================================================================

set -euo pipefail

# ── Config — edit these ───────────────────────────────────────────────────────
GITHUB_USERNAME="T-Fen"
GITHUB_EMAIL="hjsizemore@gmail.com"
GITHUB_NAME="Trey"
DOTFILES_REPO="git@github.com:${GITHUB_USERNAME}/dotfiles.git"
DOTFILES_PATH="${HOME}/dotfiles"

# ── Colors ────────────────────────────────────────────────────────────────────
C_GREEN="\e[0;32;1m"
C_CYAN="\e[0;36;1m"
C_YELLOW="\e[0;33;1m"
C_RED="\e[0;31;1m"
C_RESET="\e[0m"

info()    { printf "\n%b▶ %s%b\n" "${C_CYAN}"   "${1}" "${C_RESET}"; }
success() { printf "%b  ✓ %s%b\n" "${C_GREEN}"  "${1}" "${C_RESET}"; }
warn()    { printf "%b  ⚠ %s%b\n" "${C_YELLOW}" "${1}" "${C_RESET}"; }
error()   { printf "%b  ✗ %s%b\n" "${C_RED}"    "${1}" "${C_RESET}"; }
header()  {
  printf "\n%b╔══════════════════════════════════════════════════════╗%b\n" "${C_CYAN}" "${C_RESET}"
  printf "%b║  %-52s║%b\n" "${C_CYAN}" "${1}" "${C_RESET}"
  printf "%b╚══════════════════════════════════════════════════════╝%b\n" "${C_CYAN}" "${C_RESET}"
}

LOG_FILE="${HOME}/bootstrap-$(date +%Y-%m-%d_%H-%M-%S).log"
exec > >(tee -a "${LOG_FILE}") 2>&1

header "CachyOS Bootstrap — Full System Setup"
echo "  Log: ${LOG_FILE}"
echo "  Started: $(date)"

# ── Step 1: System update ─────────────────────────────────────────────────────
info "Step 1/12: System update"
sudo pacman -Syu --noconfirm
success "System updated"

# ── Step 2: Base dependencies ─────────────────────────────────────────────────
info "Step 2/12: Installing base dependencies"
sudo pacman -S --needed --noconfirm git base-devel ansible python3
success "Base dependencies installed"

# ── Step 3: Fix pacman.conf ───────────────────────────────────────────────────
info "Step 3/12: Fixing pacman.conf"
if grep -q "^Include = /etc/pacman.d/\*.conf" /etc/pacman.conf; then
  sudo sed -i '/^Include = \/etc\/pacman\.d\/\*\.conf/d' /etc/pacman.conf
  success "Removed wildcard Include from pacman.conf"
else
  success "pacman.conf already clean"
fi

# ── Step 4: Kernel headers ────────────────────────────────────────────────────
info "Step 4/12: Installing CachyOS kernel headers"
sudo pacman -S --needed --noconfirm linux-cachyos-headers && \
  success "Kernel headers installed" || \
  warn "Could not install linux-cachyos-headers — continuing"

# ── Step 5: SSH key ───────────────────────────────────────────────────────────
info "Step 5/12: Setting up SSH key"
if [[ ! -f "${HOME}/.ssh/id_ed25519" ]]; then
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"
  ssh-keygen -t ed25519 -C "${GITHUB_EMAIL}" -N "" -f "${HOME}/.ssh/id_ed25519"
  echo ""
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  warn "Add this SSH key to GitHub:"
  warn "https://github.com/settings/keys"
  warn "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  cat "${HOME}/.ssh/id_ed25519.pub"
  echo ""
  read -rp "  Press Enter once you've added the key to GitHub..."
else
  success "SSH key already exists"
fi

# Add GitHub to known hosts to avoid interactive prompt
ssh-keyscan github.com >> "${HOME}/.ssh/known_hosts" 2>/dev/null
chmod 600 "${HOME}/.ssh/known_hosts"

# Test connection
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  success "GitHub SSH connection verified"
else
  warn "Could not verify GitHub SSH — you may need to add your key at https://github.com/settings/keys"
  read -rp "  Press Enter to continue anyway or Ctrl+C to abort..."
fi

# ── Step 6: Clone dotfiles ────────────────────────────────────────────────────
info "Step 6/12: Cloning dotfiles"
if [[ -d "${DOTFILES_PATH}/.git" ]]; then
  success "Dotfiles already cloned — pulling latest"
  git -C "${DOTFILES_PATH}" pull
else
  git clone "${DOTFILES_REPO}" "${DOTFILES_PATH}"
  success "Dotfiles cloned"
fi

# ── Step 7: Configure install-config ─────────────────────────────────────────
info "Step 7/12: Configuring install-config"
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
grep -q "^export DOTFILES_PATH=" "${DOTFILES_PATH}/install-config" || \
  echo 'export DOTFILES_PATH="${HOME}/dotfiles"' >> "${DOTFILES_PATH}/install-config"

success "install-config configured"

# ── Step 8: Patch install script for CachyOS kernel ──────────────────────────
info "Step 8/12: Patching install script for CachyOS kernel"
if ! grep -q "cachyos" "${DOTFILES_PATH}/install"; then
  python3 - <<'PYEOF'
import os
path = os.path.expanduser("~/dotfiles/install")
content = open(path).read()
old = '  *zen*)\n    kernel_package="linux-zen-headers"\n    ;;'
new = '  *zen*)\n    kernel_package="linux-zen-headers"\n    ;;\n  *cachyos*)\n    kernel_package="linux-cachyos-headers"\n    ;;'
if old in content:
    open(path, 'w').write(content.replace(old, new))
    print("  Patched successfully")
else:
    print("  Pattern not found — may already be patched or script changed")
PYEOF
  success "Install script patched"
else
  success "Install script already supports CachyOS kernel"
fi

# ── Step 9: Run Ansible playbook ─────────────────────────────────────────────
info "Step 9/12: Running Ansible playbook (this will take 20-40 minutes)"
if [[ -f "${DOTFILES_PATH}/ansible/playbook.yml" ]]; then
  ANSIBLE_CONFIG="${DOTFILES_PATH}/ansible/ansible.cfg" ansible-playbook -v \
    -i "${DOTFILES_PATH}/ansible/inventory.ini" \
    "${DOTFILES_PATH}/ansible/playbook.yml" \
    --extra-vars "github_username=${GITHUB_USERNAME}"
  success "Ansible playbook complete"
else
  warn "Ansible playbook not found at ${DOTFILES_PATH}/ansible/playbook.yml"
  warn "Skipping package installation"
fi

# ── Step 10: Run nickjj dotfiles install ─────────────────────────────────────
info "Step 10/12: Running dotfiles install script"
export DOTFILES_PATH="${DOTFILES_PATH}"
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_STATE_HOME="${HOME}/.local/state"
export PACKAGES_AUTO_CONFIRM="1"

cd "${DOTFILES_PATH}"
./install --skip-system-packages
success "Dotfiles install complete"

# ── Step 11: Install chezmoi and apply ───────────────────────────────────────
info "Step 11/12: Installing chezmoi and applying dotfiles"
if ! command -v chezmoi &>/dev/null && [[ ! -f "${HOME}/.local/bin/chezmoi" ]]; then
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
fi

CHEZMOI="${HOME}/.local/bin/chezmoi"
if [[ -d "${DOTFILES_PATH}/chezmoi" ]]; then
  "${CHEZMOI}" init --source "${DOTFILES_PATH}/chezmoi" --apply
  success "chezmoi dotfiles applied"
else
  warn "No chezmoi directory found — skipping"
fi

# ── Step 12: Post-install config ─────────────────────────────────────────────
info "Step 12/12: Post-install configuration"

# Set zsh as default shell
if [[ "${SHELL}" != "/usr/bin/zsh" ]]; then
  sudo usermod -s /usr/bin/zsh "${USER}"
  success "Default shell set to zsh"
else
  success "zsh already default shell"
fi

# XDG vars in .zshenv
for line in \
  'export XDG_CONFIG_HOME="$HOME/.config"' \
  'export XDG_DATA_HOME="$HOME/.local/share"' \
  'export XDG_STATE_HOME="$HOME/.local/state"'; do
  grep -qF "${line}" "${HOME}/.zshenv" 2>/dev/null || \
    echo "${line}" >> "${HOME}/.zshenv"
done
success "XDG vars set in .zshenv"

# offlineimap symlink
if [[ -f "${DOTFILES_PATH}/.config/offlineimap/offlineimaprc" ]] && \
   [[ ! -f "${HOME}/.offlineimaprc" ]]; then
  ln -s "${DOTFILES_PATH}/.config/offlineimap/offlineimaprc" "${HOME}/.offlineimaprc"
  success "offlineimap symlink created"
fi

# Font cache
fc-cache -fv &>/dev/null
success "Font cache rebuilt"

# ── Done ──────────────────────────────────────────────────────────────────────
header "Bootstrap Complete!"
echo ""
echo "  Log saved to: ${LOG_FILE}"
echo "  Finished: $(date)"
echo ""
echo "  Next steps:"
echo "  1. Log out and log back in (activates zsh)"
echo "  2. Open Kitty — fastfetch should run automatically"
echo "  3. Check log for any ⚠ warnings about failed packages:"
echo "     grep '⚠' ${LOG_FILE}"
echo ""
echo "  Manual steps remaining:"
echo "  • Espanso AppImage: https://github.com/espanso/espanso/releases"
echo "    → Download, move to ~/Applications/, chmod +x"
echo ""
