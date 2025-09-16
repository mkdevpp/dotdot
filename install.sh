#!/bin/bash
#
# My Arch Linux Dotfiles Installer (Final Polished Version)
#
# This script automates the installation of packages (official & AUR)
# and the creation of symbolic links for configuration files. It then
# provides guidance for manual configurations that require user attention.
#

# 스크립트 실행 중 오류가 발생하면 즉시 중단합니다.
set -e

# --- 변수 및 함수 정의 ---

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 터미널 출력을 위한 색상 코드
YELLOW='\033[1;33m' # Warnings and backups
GREEN='\033[0;32m'  # Success messages
BLUE='\033[1;34m'   # Section headers and info text
NC='\033[0m'        # No Color

containsElement() {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

################################################################################################
# 패키지 설치
# 1. 먼저 PACKAGES 에 추가하고 이 파일을 실행하여 잘 설치되는 지 확인
# 2. 설정 파일이 있다면 DOTFILES 에 추가 (전역 설정 용이면 SYSTEM_LINUK에 추가)
#    DOTFILES(SYSTEM_LINKS) -> 관리 되는 실제 설정 파일
#    $HOME/.config -> 심볼릭 링크가 생성
# 3. 설치 후 수동 작업이 필요하다면 '수동 작업 안내' 섹션에 알림을 한다
#    ex) keyd 가 설치되었다면 다음 명령으로 데몬을 등록해야 한다
#        sudo systemctl enable keyd
#
#
# 기타 내용
# - archinstall 로 아치리눅스를 설치하고 profile 에서 niri 를 설치했다
# - 패키지는 paru 로 설치가 된다
# - LazyVim 설치는 별도 로직으로 관리한다
################################################################################################

# --- 1. 통합 패키지 목록 ---
PACKAGES=(
  'keyd'                         # -keyd
  'kime-bin'                     # -kime
  'zsh'                          # -zsh
  'zsh-autosuggestions'          # -zsh
  'zsh-fast-syntax-highlighting' # -zsh
  'starship'                     # -starship
  'ghostty'                      # -ghostty
  'neovim'                       # -neovim
  'eza'                          # -eza
  'bat'                          # -bat
  'zoxide'                       # -zoxide
  'fnm-bin'                      # -fnm
  'wl-clipboard'
  'ttf-cascadia-code-nerd'
  'uv'
)

# --- 2. 심볼릭 링크 목록 ---
declare -A DOTFILES
DOTFILES["keyd/app.conf"]="$HOME/.config/keyd/app.conf"             # -keyd
DOTFILES["kime"]="$HOME/.config/kime"                               # -kime
DOTFILES["zshrc/zshrc"]="$HOME/.zshrc"                              # -zsh
DOTFILES["starship/starship.toml"]="$HOME/.config/starship.toml"    # -starship
DOTFILES["ghostty"]="$HOME/.config/ghostty"                         # -ghostty
DOTFILES["eza"]="$HOME/.config/eza"                                 # -eza
DOTFILES["bat"]="$HOME/.config/bat"                                 # -bat
DOTFILES["nvim/lua"]="$HOME/.config/nvim/lua"                       # -neovim
DOTFILES["nvim/lazyvim.json"]="$HOME/.config/nvim/lazyvim.json"     # -neovim
DOTFILES["nvim/lazy-lock.json"]="$HOME/.config/nvim/lazy-lock.json" # -neovim
DOTFILES["environment.d"]="$HOME/.config/environment.d"             # -environment.d

declare -A SYSTEM_LINKS
SYSTEM_LINKS["system/etc/keyd/default.conf"]="/etc/keyd/default.conf" # -keyd

# --- 3. 자동화된 작업 실행 ---

echo -e "\n${BLUE}>>> Starting automated setup...${NC}"

# --- 단일 명령어로 모든 패키지 설치 ---
echo -e "\n${BLUE}>>> Installing all packages from the list (official & AUR)...${NC}"
yay -Syu --needed "${PACKAGES[@]}"

# --- LazyVim 설치 ---
echo -e "\n${BLUE}>>> Checking for LazyVim base installation...${NC}"
NVIM_CONFIG_DIR="$HOME/.config/nvim"

if containsElement "neovim" "${PACKAGES[@]}" && [ ! -d "$NVIM_CONFIG_DIR" ]; then
  echo -e "   ${YELLOW}LazyVim base directory not found at '$NVIM_CONFIG_DIR'.${NC}"
  echo -e "   ${YELLOW}Cloning the LazyVim starter template...${NC}"
  git clone https://github.com/LazyVim/starter "$NVIM_CONFIG_DIR"
  rm -rf "${NVIM_CONFIG_DIR}/.git"
  echo -e "   ${GREEN}LazyVim base successfully installed.${NC}"
else
  if containsElement "neovim" "${PACKAGES[@]}"; then
    echo -e "   ${GREEN}Found existing LazyVim base directory. Skipping clone.${NC}"
  fi
fi

# --- 심볼릭 링크 생성 ---
echo -e "\n${BLUE}>>> Creating user-level symbolic links...${NC}"
for src in "${!DOTFILES[@]}"; do
  dest="${DOTFILES[$src]}"
  src_path="$DOTFILES_DIR/$src"
  dest_path="$dest"

  mkdir -p "$(dirname "$dest_path")"
  if [ -L "$dest_path" ] && [ "$(readlink "$dest_path")" = "$src_path" ]; then
    continue
  fi
  if [ -e "$dest_path" ]; then
    echo -e "   ${YELLOW}Backing up:${NC} $dest_path -> $dest_path.bak"
    mv "$dest_path" "$dest_path.bak"
  fi
  ln -s "$src_path" "$dest_path"
  echo -e "   ${GREEN}Linked:${NC} $src_path -> $dest_path"
done

echo -e "\n${BLUE}>>> Creating system-level symbolic links...${NC}"
for src in "${!SYSTEM_LINKS[@]}"; do
  dest="${SYSTEM_LINKS[$src]}"
  src_path="$DOTFILES_DIR/$src"
  dest_path="$dest"

  sudo mkdir -p "$(dirname "$dest_path")"
  if [ -L "$dest_path" ] && [ "$(readlink "$dest_path")" = "$src_path" ]; then
    continue
  fi
  if [ -e "$dest_path" ]; then
    echo -e "   ${YELLOW}Backing up:${NC} $dest_path -> $dest_path.bak"
    sudo mv "$dest_path" "$dest_path.bak"
  fi
  sudo ln -s "$src_path" "$dest_path"
  echo -e "   ${GREEN}Linked (sudo):${NC} $src_path -> $dest_path"
done

# --- 4. 수동 작업 안내 ---

echo -e "\n${YELLOW}=======================================${NC}"
echo -e "${YELLOW}  MANUAL ACTIONS & IMPORTANT NOTES${NC}"
echo -e "${YELLOW}=======================================${NC}"

# -keyd
if containsElement "keyd" "${PACKAGES[@]}"; then
  echo -e "\n🟡 ${BLUE}Actions required for 'keyd' to function fully:${NC}"

  echo "   1. To have the main 'keyd' service start on boot, you must enable it."
  echo "      Please run the following command:"
  echo -e "         ${YELLOW}sudo systemctl enable keyd --now${NC}\n"

  echo "   2. For advanced features like application-specific mappings, 'keyd' needs direct"
  echo "      device access. Add your user to the 'keyd' group for this permission."
  echo -e "      Please run the following command and then ${YELLOW}re-login${NC}:"
  echo -e "         ${YELLOW}sudo usermod -aG keyd \$USER${NC}\n"

  echo "   3. To use the application-specific mapping feature, the 'keyd-application-mapper'"
  echo "      daemon must be running in your user session. Add the following command to your"
  echo "      preferred autostart method (e.g., niri config, .zshprofile, etc.):"
  echo "      ~/.config/autostart 를 사용한다"
  echo -e "         ${YELLOW}keyd-application-mapper -d${NC}\n"
fi

# -zsh
if containsElement "zsh" "${PACKAGES[@]}"; then
  echo -e "\n🟡 ${BLUE}zsh:${NC}"
  echo "   zsh 설치완료. 다음 명령으로 기본 쉘로 변경"
  echo -e "   ${YELLOW}chsh -s \$(which zsh)${NC}\n"
fi

# -neovim
if containsElement "neovim" "${PACKAGES[@]}"; then
  echo -e "\n🟡 ${BLUE}neovim 과 obsidian.nvim 을 사용한다면:${NC}"
  echo -e "   vaults/mk/* 디렉토리를 준비한다\n"
fi

echo -e "\n----------------------------------------"
echo -e "${GREEN}✅ Automated setup complete!${NC}"
echo "Please review the manual actions above and reboot or re-login if necessary."
echo "----------------------------------------"
