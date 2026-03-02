#!/data/data/com.termux/files/usr/bin/bash
#
# Ubuntu Termux VM - Auto Push to GitHub
# =======================================
# Just run: ./push.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

echo -e "${CYAN}╔════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}║     Ubuntu Termux VM - Auto Push to GitHub    ║${RESET}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${RESET}"
echo ""

# Get GitHub username
echo -e "${YELLOW}Enter your GitHub username:${RESET}"
read -p "> " GITHUB_USERNAME

if [ -z "$GITHUB_USERNAME" ]; then
    echo -e "${RED}Error: Username cannot be empty!${RESET}"
    exit 1
fi

echo ""
echo -e "${GREEN}Username: $GITHUB_USERNAME${RESET}"
echo ""

# Get token
echo -e "${YELLOW}Enter your GitHub Personal Access Token:${RESET}"
echo -e "${DIM}(Token will be hidden as you type)${RESET}"
read -s -p "> " GITHUB_TOKEN

echo ""
echo ""

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: Token cannot be empty!${RESET}"
    exit 1
fi

echo -e "${GREEN}Token received (hidden for security)${RESET}"
echo ""

# Set git config
echo -e "${CYAN}Configuring git...${RESET}"
git config user.email "developer@ubuntu-termux-vm.com"
git config user.name "Ubuntu Termux VM Developer"

# Initialize if needed
if [ ! -d ".git" ]; then
    echo -e "${CYAN}Initializing git repository...${RESET}"
    git init
fi

# Add files
echo -e "${CYAN}Adding all files...${RESET}"
git add .

# Commit
echo -e "${CYAN}Committing changes...${RESET}"
git commit -m "Ubuntu Termux VM - Complete Android Virtualization Solution" || echo "No changes to commit"

# Set branch
git branch -M main 2>/dev/null || true

# Remove existing remote if exists
git remote remove origin 2>/dev/null || true

# Add remote
echo -e "${CYAN}Connecting to GitHub repository...${RESET}"
git remote add origin "https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/ubuntu-termux-vm.git"

# Push
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${CYAN}Pushing to GitHub...${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""

git push -u origin main --force

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║     ✅ PUSH SUCCESSFUL!                       ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${WHITE}Your repository is now live at:${RESET}"
    echo -e "${CYAN}https://github.com/$GITHUB_USERNAME/ubuntu-termux-vm${RESET}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT: Delete your token now!${RESET}"
    echo -e "${DIM}Go to: https://github.com/settings/tokens${RESET}"
    echo ""
    echo -e "${WHITE}Next steps:${RESET}"
    echo -e "  1. Visit your repository URL above"
    echo -e "  2. Delete/revoke the token you used"
    echo -e "  3. Generate a new token for future use"
    echo -e "  4. Share your repository! 🎉"
    echo ""
else
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════╗${RESET}"
    echo -e "${RED}║     ✗ PUSH FAILED                             ║${RESET}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "${YELLOW}Possible reasons:${RESET}"
    echo -e "  • Invalid token"
    echo -e "  • Username incorrect"
    echo -e "  • Network issue"
    echo -e "  • Repository name already exists"
    echo ""
    echo -e "${YELLOW}Try again or check your credentials.${RESET}"
fi
