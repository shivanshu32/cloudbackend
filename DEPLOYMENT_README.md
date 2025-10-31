# CloudVoter Backend - Deployment Documentation

## 📚 Documentation Overview

This directory contains comprehensive deployment documentation for running CloudVoter backend on DigitalOcean.

### Available Guides

1. **[DIGITALOCEAN_DEPLOYMENT.md](./DIGITALOCEAN_DEPLOYMENT.md)** - Complete step-by-step guide
   - Detailed instructions for every step
   - Troubleshooting section
   - Security best practices
   - Monitoring and management

2. **[QUICK_DEPLOY.md](./QUICK_DEPLOY.md)** - Fast track deployment (15 minutes)
   - Condensed instructions
   - Quick reference commands
   - Essential checklist

### Deployment Scripts

1. **setup_droplet.sh** - Automated server setup
   - Installs all system dependencies
   - Configures firewall
   - Sets up monitoring tools
   - Run once on fresh droplet

2. **monitor_resources.sh** - Resource monitoring daemon
   - Monitors CPU and Memory usage
   - Automatically restarts app at 90% threshold
   - Logs all restart events
   - Ensures no voting opportunities are missed

### Configuration Files

1. **ecosystem.config.js** - PM2 process manager configuration
   - Auto-restart on crashes
   - Memory-based restart (900MB threshold)
   - Log rotation
   - Process monitoring

2. **cloudvoter.service** - Systemd service file (alternative to PM2)
   - Native Linux service
   - Resource limits
   - Auto-restart on failure

## 🚀 Quick Start

### Option 1: Using PM2 (Recommended)

```bash
# 1. SSH into droplet
ssh root@YOUR_DROPLET_IP

# 2. Run setup script
curl -o setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/backend/setup_droplet.sh
chmod +x setup.sh
./setup.sh

# 3. Clone and deploy
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO/backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
playwright install chromium
mkdir -p logs

# 4. Start with PM2
pm2 start ecosystem.config.js
pm2 startup
pm2 save

# 5. Optional: Start resource monitor
chmod +x monitor_resources.sh
pm2 start monitor_resources.sh --name resource-monitor
pm2 save
```

### Option 2: Using Systemd

```bash
# 1-3. Same as above

# 4. Install systemd service
sudo cp cloudvoter.service /etc/systemd/system/
sudo nano /etc/systemd/system/cloudvoter.service  # Update paths
sudo systemctl daemon-reload
sudo systemctl enable cloudvoter
sudo systemctl start cloudvoter
```

## 🎯 Deployment Architecture

```
┌─────────────────────────────────────────┐
│     DigitalOcean Droplet (Ubuntu)       │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │         PM2 Process Manager       │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │   CloudVoter Backend        │ │ │
│  │  │   (Flask + SocketIO)        │ │ │
│  │  │   Port: 5000                │ │ │
│  │  └─────────────────────────────┘ │ │
│  │                                   │ │
│  │  ┌─────────────────────────────┐ │ │
│  │  │   Resource Monitor          │ │ │
│  │  │   (CPU/Memory Watcher)      │ │ │
│  │  └─────────────────────────────┘ │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Playwright Browsers             │ │
│  │   (Chromium instances)            │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │   Firewall (UFW)                  │ │
│  │   - Port 22 (SSH)                 │ │
│  │   - Port 5000 (Flask)             │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
           │
           │ HTTP on port 5000
           ▼
    http://YOUR_IP:5000
```

## 📊 Resource Management

### Automatic Restart Triggers

1. **Memory > 900MB** (PM2 built-in)
   - Configured in `ecosystem.config.js`
   - `max_memory_restart: '900M'`

2. **CPU > 90%** (Resource Monitor)
   - Monitored by `monitor_resources.sh`
   - Checks every 30 seconds

3. **Application Crash** (PM2 built-in)
   - Automatic restart with exponential backoff
   - Up to 50 restart attempts

4. **System Reboot** (PM2 startup)
   - Application starts automatically
   - Configured via `pm2 startup`

### Resource Monitoring

```bash
# Real-time monitoring
pm2 monit

# View resource monitor logs
tail -f logs/resource-monitor.log

# Check system resources
htop

# View PM2 process info
pm2 info cloudvoter-backend
```

## 🔄 Update Process

```bash
# 1. SSH into droplet
ssh cloudvoter@YOUR_DROPLET_IP

# 2. Navigate to project
cd ~/YOUR_REPO/backend

# 3. Pull latest changes
git pull origin main

# 4. Update dependencies (if needed)
source venv/bin/activate
pip install -r requirements.txt

# 5. Restart application
pm2 restart cloudvoter-backend

# 6. Verify
pm2 logs cloudvoter-backend --lines 50
```

## 🛡️ High Availability Features

### Never Miss a Vote

1. **Continuous Operation**
   - PM2 keeps process running 24/7
   - Auto-restart on any failure
   - Non-daemon threads prevent premature exit

2. **Resource Protection**
   - Automatic restart before resource exhaustion
   - Memory threshold: 900MB (90% of 1GB)
   - CPU threshold: 90%

3. **Crash Recovery**
   - Instant restart on application crash
   - Exponential backoff prevents restart loops
   - Up to 50 restart attempts

4. **System Reboot Recovery**
   - PM2 startup script ensures auto-start
   - Application resumes voting automatically

5. **Monitoring Loop**
   - Continuous session scanning
   - Automatic instance launching
   - Real-time status updates via WebSocket

## 📝 Configuration Files Explained

### ecosystem.config.js
- **Purpose**: PM2 process configuration
- **Key Features**:
  - Memory-based restart
  - Log rotation
  - Auto-restart on crash
  - Environment variables

### monitor_resources.sh
- **Purpose**: Additional CPU/Memory monitoring
- **Key Features**:
  - 30-second check interval
  - 90% CPU threshold
  - 90% Memory threshold
  - Detailed logging

### cloudvoter.service
- **Purpose**: Systemd service (alternative to PM2)
- **Key Features**:
  - Native Linux service
  - Resource limits (MemoryMax, CPUQuota)
  - Auto-restart policy
  - Security hardening

## 🔍 Monitoring and Logs

### Log Locations

```
backend/
├── logs/
│   ├── cloudvoter-combined.log    # PM2 combined logs
│   ├── cloudvoter-error.log       # PM2 error logs
│   ├── cloudvoter-out.log         # PM2 output logs
│   └── resource-monitor.log       # Resource monitor logs
├── cloudvoter.log                 # Flask application logs
└── voting_logs.csv                # Voting history
```

### Viewing Logs

```bash
# PM2 logs (real-time)
pm2 logs cloudvoter-backend

# Application logs
tail -f cloudvoter.log

# Resource monitor logs
tail -f logs/resource-monitor.log

# Voting history
cat voting_logs.csv
```

## 🐛 Troubleshooting

### Application Won't Start

```bash
# Check PM2 status
pm2 status

# View error logs
pm2 logs cloudvoter-backend --err --lines 100

# Try manual start
source venv/bin/activate
python3 app.py
```

### Port Not Accessible

```bash
# Check firewall
sudo ufw status

# Open port if needed
sudo ufw allow 5000/tcp

# Check if app is listening
sudo netstat -tulpn | grep 5000
```

### High Memory Usage

```bash
# Check current usage
pm2 monit

# Restart application
pm2 restart cloudvoter-backend

# Check for memory leaks
pm2 logs cloudvoter-backend | grep -i memory
```

### Playwright Issues

```bash
# Reinstall browsers
source venv/bin/activate
playwright install chromium
playwright install-deps chromium

# Check dependencies
ldd $(which chromium) | grep "not found"
```

## 📞 Support Checklist

Before seeking help, gather this information:

```bash
# 1. PM2 status
pm2 status

# 2. Recent logs
pm2 logs cloudvoter-backend --lines 100

# 3. System resources
free -h
df -h

# 4. Application info
pm2 info cloudvoter-backend

# 5. Python version
python3 --version

# 6. Playwright version
playwright --version

# 7. Network status
curl http://localhost:5000/api/health
```

## ✅ Production Checklist

- [ ] Droplet has minimum 2GB RAM
- [ ] All system packages updated
- [ ] Python 3.11+ installed
- [ ] Node.js and PM2 installed
- [ ] Repository cloned from GitHub
- [ ] Virtual environment created
- [ ] All dependencies installed
- [ ] Playwright browsers installed
- [ ] Configuration file updated (config.py or .env)
- [ ] Logs directory created
- [ ] Firewall configured (ports 22, 5000)
- [ ] PM2 application started
- [ ] PM2 startup configured
- [ ] Resource monitor started (optional)
- [ ] Application accessible at http://YOUR_IP:5000
- [ ] Health endpoint responding: /api/health
- [ ] WebSocket connection working
- [ ] Voting functionality tested
- [ ] Logs being written correctly
- [ ] Auto-restart tested (kill process)
- [ ] System reboot tested

## 🎯 Expected Performance

### Normal Operation
- **Memory Usage**: 300-600MB
- **CPU Usage**: 10-40% (spikes during voting)
- **Response Time**: < 100ms for API calls
- **Uptime**: 99.9%+ with auto-restart

### During Voting
- **Memory Usage**: 500-800MB (multiple browsers)
- **CPU Usage**: 40-80% (browser automation)
- **Browser Instances**: 1-5 concurrent
- **Vote Success Rate**: 95%+

## 📚 Additional Resources

- [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [Flask Documentation](https://flask.palletsprojects.com/)
- [Playwright Documentation](https://playwright.dev/python/)
- [DigitalOcean Tutorials](https://www.digitalocean.com/community/tutorials)
- [Ubuntu Server Guide](https://ubuntu.com/server/docs)

## 🔐 Security Notes

1. **Never commit credentials** to Git
2. **Use environment variables** for sensitive data
3. **Keep system updated**: `sudo apt update && sudo apt upgrade`
4. **Use SSH keys** instead of passwords
5. **Configure fail2ban** to prevent brute force attacks
6. **Disable root login** after creating user account
7. **Use strong passwords** for all accounts
8. **Monitor logs** for suspicious activity

---

**Ready to deploy?** Start with [QUICK_DEPLOY.md](./QUICK_DEPLOY.md) for fast deployment or [DIGITALOCEAN_DEPLOYMENT.md](./DIGITALOCEAN_DEPLOYMENT.md) for detailed instructions.

**Questions?** Check the troubleshooting section or review the logs.

**Happy Voting! 🗳️**
