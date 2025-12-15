#!/bin/bash
#
# Darwin installer
# Clones the repository and adds to PATH
#

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="${DARWIN_INSTALL_DIR:-$HOME/.darwin}"
REPO_URL="https://github.com/dontoisme/darwin.git"

echo ""
echo -e "${GREEN}🧬 Darwin Installer${NC}"
echo "   Watch your iOS app evolve"
echo ""

# Check for git
if ! command -v git &> /dev/null; then
    echo "Error: git is required but not installed."
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}Warning: jq is required for Darwin to work.${NC}"
    echo "Install with: brew install jq"
    echo ""
fi

# Clone or update
if [ -d "$INSTALL_DIR" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull origin main
else
    echo "Installing to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/bin/"*

# Detect shell and config file
SHELL_CONFIG=""
if [ -n "$ZSH_VERSION" ] || [ "$SHELL" = "/bin/zsh" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$SHELL" = "/bin/bash" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
    # Also check for .bash_profile on macOS
    if [ -f "$HOME/.bash_profile" ]; then
        SHELL_CONFIG="$HOME/.bash_profile"
    fi
fi

# Add to PATH
PATH_LINE="export PATH=\"\$PATH:$INSTALL_DIR/bin\""

if [ -n "$SHELL_CONFIG" ]; then
    if ! grep -q "darwin/bin" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# Darwin - iOS visual regression testing" >> "$SHELL_CONFIG"
        echo "$PATH_LINE" >> "$SHELL_CONFIG"
        echo -e "${GREEN}Added Darwin to PATH in $SHELL_CONFIG${NC}"
    else
        echo "Darwin already in PATH"
    fi
fi

echo ""
echo -e "${GREEN}=== Installation Complete ===${NC}"
echo ""
echo "To use Darwin now, run:"
echo -e "  ${BLUE}$PATH_LINE${NC}"
echo ""
echo "Or restart your terminal, then:"
echo -e "  ${BLUE}darwin --help${NC}"
echo ""
echo "Quick start:"
echo "  cd /path/to/your/ios/project"
echo "  darwin init"
echo "  darwin capture --baseline"
echo ""
echo -e "${GREEN}🧬 Ready to evolve!${NC}"
