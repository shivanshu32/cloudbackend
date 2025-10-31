#!/bin/bash

# CloudVoter Backend - Quick Deployment Script
# Run this script after initial setup to update and restart the application

set -e  # Exit on error

echo "🚀 Starting CloudVoter Backend Deployment..."

# Navigate to project directory
cd ~/cloudvoter-backend

# Pull latest changes
echo "📥 Pulling latest changes from Git..."
git pull origin main

# Activate virtual environment
echo "🐍 Activating virtual environment..."
source venv/bin/activate

# Update dependencies
echo "📦 Installing/updating dependencies..."
pip install -r requirements.txt

# Restart PM2 process
echo "🔄 Restarting application with PM2..."
pm2 restart cloudvoter-backend

# Show status
echo "✅ Deployment complete!"
echo ""
echo "📊 Application Status:"
pm2 status

echo ""
echo "📝 Recent Logs:"
pm2 logs cloudvoter-backend --lines 20 --nostream

echo ""
echo "💡 Useful commands:"
echo "  - View logs: pm2 logs cloudvoter-backend"
echo "  - Monitor: pm2 monit"
echo "  - Stop: pm2 stop cloudvoter-backend"
echo "  - Restart: pm2 restart cloudvoter-backend"
