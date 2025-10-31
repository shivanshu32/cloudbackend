#!/bin/bash

# CloudVoter Backend - DigitalOcean Droplet Setup Script
# This script automates the initial setup of your droplet
# Run this after SSH-ing into your fresh Ubuntu droplet

set -e  # Exit on any error

echo "================================================"
echo "CloudVoter Backend - Droplet Setup Script"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this script as root. Run as a regular user with sudo privileges."
    exit 1
fi

print_info "Starting setup process..."
echo ""

# Step 1: Update system
print_info "Step 1: Updating system packages..."
sudo apt update && sudo apt upgrade -y
print_success "System packages updated"
echo ""

# Step 2: Install Python
print_info "Step 2: Installing Python 3 and pip..."
sudo apt install -y python3 python3-pip python3-venv
PYTHON_VERSION=$(python3 --version)
print_success "Python installed: $PYTHON_VERSION"
echo ""

# Step 3: Install Node.js and npm
print_info "Step 3: Installing Node.js and npm..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
print_success "Node.js installed: $NODE_VERSION"
print_success "npm installed: $NPM_VERSION"
echo ""

# Step 4: Install PM2
print_info "Step 4: Installing PM2..."
sudo npm install -g pm2
PM2_VERSION=$(pm2 --version)
print_success "PM2 installed: $PM2_VERSION"
echo ""

# Step 5: Install Git
print_info "Step 5: Installing Git..."
sudo apt install -y git
GIT_VERSION=$(git --version)
print_success "Git installed: $GIT_VERSION"
echo ""

# Step 6: Install Playwright dependencies
print_info "Step 6: Installing Playwright system dependencies..."
sudo apt install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libdbus-1-3 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libpango-1.0-0 \
    libcairo2 \
    libasound2 \
    libatspi2.0-0 \
    libxshmfence1
print_success "Playwright dependencies installed"
echo ""

# Step 7: Configure firewall
print_info "Step 7: Configuring firewall..."
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 5000/tcp # Flask app
echo "y" | sudo ufw enable
print_success "Firewall configured (SSH: 22, Flask: 5000)"
echo ""

# Step 8: Install monitoring tools
print_info "Step 8: Installing monitoring tools..."
sudo apt install -y htop
print_success "Monitoring tools installed"
echo ""

print_success "Base system setup complete!"
echo ""
echo "================================================"
echo "Next Steps:"
echo "================================================"
echo ""
echo "1. Clone your repository:"
echo "   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git"
echo ""
echo "2. Navigate to backend directory:"
echo "   cd YOUR_REPO/backend"
echo ""
echo "3. Create virtual environment:"
echo "   python3 -m venv venv"
echo ""
echo "4. Activate virtual environment:"
echo "   source venv/bin/activate"
echo ""
echo "5. Install Python dependencies:"
echo "   pip install -r requirements.txt"
echo ""
echo "6. Install Playwright browsers:"
echo "   playwright install chromium"
echo "   playwright install-deps chromium"
echo ""
echo "7. Create logs directory:"
echo "   mkdir -p logs"
echo ""
echo "8. Configure your settings in config.py or .env file"
echo ""
echo "9. Start application with PM2:"
echo "   pm2 start ecosystem.config.js"
echo ""
echo "10. Set PM2 to start on boot:"
echo "    pm2 startup"
echo "    pm2 save"
echo ""
echo "================================================"
echo "Your droplet is ready for deployment!"
echo "================================================"
