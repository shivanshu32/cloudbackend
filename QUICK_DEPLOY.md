# Quick Deployment Guide - CloudVoter Backend on DigitalOcean

## 🚀 Fast Track Deployment (15 minutes)

### 1. Create Droplet (5 minutes)
- Go to DigitalOcean → Create Droplet
- Choose: Ubuntu 22.04 LTS, 2GB RAM minimum
- Note your droplet IP address

### 2. Run Setup Script (5 minutes)
```bash
# SSH into droplet
ssh root@YOUR_DROPLET_IP

# Create user (optional but recommended)
adduser cloudvoter
usermod -aG sudo cloudvoter
su - cloudvoter

# Download and run setup script
curl -o setup_droplet.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/backend/setup_droplet.sh
chmod +x setup_droplet.sh
./setup_droplet.sh
```

### 3. Deploy Application (5 minutes)
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/backend

# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Install Playwright
playwright install chromium
playwright install-deps chromium

# Create logs directory
mkdir -p logs

# Configure your settings (edit config.py or create .env)
nano config.py  # or nano .env

# Start with PM2
pm2 start ecosystem.config.js
pm2 startup
# Run the command PM2 outputs
pm2 save

# Optional: Start resource monitor
chmod +x monitor_resources.sh
pm2 start monitor_resources.sh --name resource-monitor
pm2 save
```

### 4. Verify Deployment
```bash
# Check status
pm2 status

# View logs
pm2 logs cloudvoter-backend --lines 50

# Test from browser
# Open: http://YOUR_DROPLET_IP:5000
```

## 🔄 Update Deployment

```bash
# SSH into droplet
ssh cloudvoter@YOUR_DROPLET_IP

# Navigate to project
cd ~/YOUR_REPO/backend

# Pull updates
git pull origin main

# Activate venv and update dependencies
source venv/bin/activate
pip install -r requirements.txt

# Restart
pm2 restart cloudvoter-backend
```

## 📊 Monitor Application

```bash
# View status
pm2 status

# View logs
pm2 logs cloudvoter-backend

# Monitor resources
pm2 monit

# View resource monitor logs
tail -f logs/resource-monitor.log
```

## 🛠️ Common Commands

```bash
# Restart app
pm2 restart cloudvoter-backend

# Stop app
pm2 stop cloudvoter-backend

# View detailed info
pm2 info cloudvoter-backend

# Clear logs
pm2 flush

# Save PM2 config
pm2 save
```

## ✅ Checklist

- [ ] Droplet created (2GB+ RAM)
- [ ] Setup script executed
- [ ] Repository cloned
- [ ] Python environment configured
- [ ] Dependencies installed
- [ ] Playwright installed
- [ ] Config file updated
- [ ] PM2 started
- [ ] PM2 startup configured
- [ ] Resource monitor started (optional)
- [ ] Application accessible at http://YOUR_IP:5000

## 🎯 Expected Result

- App runs on: `http://YOUR_DROPLET_IP:5000`
- Auto-restarts on high memory/CPU
- Auto-restarts on crashes
- Starts on server reboot
- Never misses voting opportunities

## 📞 Troubleshooting

**App not starting?**
```bash
pm2 logs cloudvoter-backend --lines 100
```

**Port not accessible?**
```bash
sudo ufw status
sudo ufw allow 5000/tcp
```

**High memory usage?**
```bash
pm2 monit
pm2 restart cloudvoter-backend
```

**Need to reinstall Playwright?**
```bash
source venv/bin/activate
playwright install chromium
playwright install-deps chromium
```

---

For detailed instructions, see [DIGITALOCEAN_DEPLOYMENT.md](./DIGITALOCEAN_DEPLOYMENT.md)
