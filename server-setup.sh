#!/bin/bash

# CloudVoter Backend - Initial Server Setup Script
# Run this script on a fresh Ubuntu 22.04 DigitalOcean droplet

set -e  # Exit on error

echo "🚀 CloudVoter Backend - Server Setup Script"
echo "==========================================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  Please run as root or with sudo"
    exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install Python
echo "🐍 Installing Python 3..."
apt install -y python3 python3-pip python3-venv

# Install Node.js and npm
echo "📗 Installing Node.js 18.x..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install PM2
echo "⚙️  Installing PM2..."
npm install -g pm2

# Install Playwright system dependencies
echo "🎭 Installing Playwright dependencies..."
apt install -y \
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

# Install Nginx
echo "🌐 Installing Nginx..."
apt install -y nginx

# Install useful utilities
echo "🛠️  Installing utilities..."
apt install -y git curl wget htop ufw

# Setup firewall
echo "🔥 Configuring firewall..."
ufw --force enable
ufw allow OpenSSH
ufw allow 5000/tcp
ufw allow 'Nginx Full'

echo ""
echo "✅ Server setup complete!"
echo ""
echo "📋 Installed versions:"
echo "  - Python: $(python3 --version)"
echo "  - Node.js: $(node --version)"
echo "  - npm: $(npm --version)"
echo "  - PM2: $(pm2 --version)"
echo ""
echo "🔐 Security recommendations:"
echo "  1. Create a non-root user: adduser cloudvoter"
echo "  2. Add to sudo group: usermod -aG sudo cloudvoter"
echo "  3. Setup SSH keys instead of password authentication"
echo ""
echo "📝 Next steps:"
echo "  1. Switch to non-root user: su - cloudvoter"
echo "  2. Clone your repository: git clone YOUR_REPO_URL cloudvoter-backend"
echo "  3. Follow the DEPLOYMENT_GUIDE.md for detailed instructions"
echo ""
echo "🎉 Ready to deploy CloudVoter!"
