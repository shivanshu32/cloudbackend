# CloudVoter Backend Deployment Guide - DigitalOcean Ubuntu 22.04

## Prerequisites
- DigitalOcean Droplet with Ubuntu 22.04 LTS
- Root or sudo access
- Your Git repository URL
- Domain name (optional, but recommended)

---

## Step 1: Initial Server Setup

### 1.1 Connect to Your Droplet
```bash
ssh root@your_droplet_ip
```

### 1.2 Update System Packages
```bash
apt update && apt upgrade -y
```

### 1.3 Create a Non-Root User (Recommended)
```bash
adduser cloudvoter
usermod -aG sudo cloudvoter
su - cloudvoter
```

---

## Step 2: Install Required Dependencies

### 2.1 Install Python 3.11+
```bash
sudo apt install -y python3 python3-pip python3-venv
python3 --version  # Verify installation
```

### 2.2 Install Node.js and PM2
```bash
# Install Node.js 18.x LTS
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installation
node --version
npm --version

# Install PM2 globally
sudo npm install -g pm2
pm2 --version
```

### 2.3 Install Playwright Dependencies
```bash
# Install system dependencies for Playwright browsers
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
```

### 2.4 Install Nginx (Optional - for reverse proxy)
```bash
sudo apt install -y nginx
```

---

## Step 3: Clone and Setup Your Backend

### 3.1 Clone Your Repository
```bash
cd ~
git clone YOUR_GIT_REPOSITORY_URL cloudvoter-backend
cd cloudvoter-backend
```

### 3.2 Create Python Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3.3 Install Python Dependencies
```bash
pip install --upgrade pip
pip install -r requirements.txt
```

### 3.4 Install Playwright Browsers
```bash
# This will download Chromium, Firefox, and WebKit
playwright install chromium

# If you need all browsers
# playwright install
```

---

## Step 4: Configure Environment

### 4.1 Create Environment File (Optional)
```bash
nano .env
```

Add your environment variables:
```env
SECRET_KEY=your-super-secret-key-change-this
FLASK_ENV=production
PORT=5000
```

### 4.2 Update Configuration (if needed)
```bash
nano config.py
```

Make sure to:
- Update `BRIGHT_DATA_USERNAME` and `BRIGHT_DATA_PASSWORD`
- Update `TARGET_URLS` with your voting URLs
- Set `HEADLESS_MODE = True` for production

### 4.3 Create Logs Directory
```bash
mkdir -p logs
```

---

## Step 5: Setup PM2

### 5.1 Update ecosystem.config.js
The file is already configured, but verify the interpreter path:
```bash
which python3
```

If the path is different from `/usr/bin/python3`, update `ecosystem.config.js`:
```bash
nano ecosystem.config.js
```

### 5.2 Start Application with PM2
```bash
# Make sure you're in the virtual environment
source venv/bin/activate

# Start the application
pm2 start ecosystem.config.js

# Check status
pm2 status

# View logs
pm2 logs cloudvoter-backend

# Monitor in real-time
pm2 monit
```

### 5.3 Setup PM2 Startup Script
```bash
# Generate startup script
pm2 startup

# Copy and run the command it outputs (it will look like):
# sudo env PATH=$PATH:/usr/bin pm2 startup systemd -u cloudvoter --hp /home/cloudvoter

# Save PM2 process list
pm2 save
```

---

## Step 6: Configure Firewall

### 6.1 Setup UFW Firewall
```bash
# Allow SSH
sudo ufw allow OpenSSH

# Allow your Flask app port (if accessing directly)
sudo ufw allow 5000/tcp

# Allow Nginx (if using reverse proxy)
sudo ufw allow 'Nginx Full'

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## Step 7: Setup Nginx Reverse Proxy (Optional but Recommended)

### 7.1 Create Nginx Configuration
```bash
sudo nano /etc/nginx/sites-available/cloudvoter
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your_domain.com;  # Replace with your domain or droplet IP

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support for SocketIO
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}
```

### 7.2 Enable the Site
```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/cloudvoter /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 7.3 Setup SSL with Let's Encrypt (Optional)
```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your_domain.com

# Auto-renewal is setup automatically
sudo certbot renew --dry-run
```

---

## Step 8: Verify Deployment

### 8.1 Check Application Status
```bash
pm2 status
pm2 logs cloudvoter-backend --lines 50
```

### 8.2 Test the Application
```bash
# Test locally
curl http://localhost:5000

# Test via Nginx (if configured)
curl http://your_domain.com
```

### 8.3 Check System Resources
```bash
pm2 monit
htop  # Install with: sudo apt install htop
```

---

## Step 9: Useful PM2 Commands

```bash
# View logs
pm2 logs cloudvoter-backend
pm2 logs cloudvoter-backend --lines 100
pm2 logs cloudvoter-backend --err  # Only errors

# Restart application
pm2 restart cloudvoter-backend

# Stop application
pm2 stop cloudvoter-backend

# Delete from PM2
pm2 delete cloudvoter-backend

# Reload (zero-downtime restart)
pm2 reload cloudvoter-backend

# Monitor resources
pm2 monit

# Show detailed info
pm2 show cloudvoter-backend

# Save current process list
pm2 save

# Resurrect saved processes
pm2 resurrect
```

---

## Step 10: Updating Your Application

### 10.1 Pull Latest Changes
```bash
cd ~/cloudvoter-backend
git pull origin main  # or your branch name
```

### 10.2 Update Dependencies (if changed)
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### 10.3 Restart Application
```bash
pm2 restart cloudvoter-backend
```

---

## Troubleshooting

### Check Application Logs
```bash
pm2 logs cloudvoter-backend
tail -f logs/cloudvoter-combined.log
tail -f cloudvoter.log
```

### Check Nginx Logs
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

### Check System Resources
```bash
free -h  # Memory usage
df -h    # Disk usage
pm2 monit  # PM2 monitoring
```

### Playwright Issues
If Playwright browsers fail to launch:
```bash
# Reinstall browsers
source venv/bin/activate
playwright install chromium --with-deps
```

### Port Already in Use
```bash
# Find process using port 5000
sudo lsof -i :5000

# Kill the process
sudo kill -9 PID
```

### PM2 Not Starting on Boot
```bash
# Regenerate startup script
pm2 unstartup
pm2 startup
# Run the command it outputs
pm2 save
```

---

## Security Recommendations

1. **Change Default Credentials**: Update `SECRET_KEY` in config or .env
2. **Use Firewall**: Only open necessary ports
3. **Regular Updates**: Keep system and packages updated
4. **Use SSL**: Setup Let's Encrypt for HTTPS
5. **Limit SSH Access**: Use SSH keys instead of passwords
6. **Monitor Logs**: Regularly check application and system logs
7. **Backup Data**: Backup your voting logs and session data regularly

---

## Performance Optimization

### For Low-Memory Droplets (1GB RAM)
The `ecosystem.config.js` is already configured with:
- `max_memory_restart: '900M'` - Restarts if memory exceeds 900MB
- Single instance mode to avoid memory issues

### Monitor Memory Usage
```bash
pm2 monit
free -h
```

### Adjust Browser Instances
Edit `config.py` to reduce concurrent browser instances if needed.

---

## Quick Deployment Script

Save this as `deploy.sh` for quick deployments:
```bash
#!/bin/bash
cd ~/cloudvoter-backend
git pull origin main
source venv/bin/activate
pip install -r requirements.txt
pm2 restart cloudvoter-backend
pm2 logs cloudvoter-backend --lines 20
```

Make it executable:
```bash
chmod +x deploy.sh
```

Run it:
```bash
./deploy.sh
```

---

## Support

- Check logs: `pm2 logs cloudvoter-backend`
- Monitor: `pm2 monit`
- Status: `pm2 status`
- Application logs: `tail -f cloudvoter.log`

---

**Deployment Complete! 🚀**

Your CloudVoter backend should now be running on your DigitalOcean droplet with PM2 managing the process.
