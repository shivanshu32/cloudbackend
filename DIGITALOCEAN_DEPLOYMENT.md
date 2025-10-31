# DigitalOcean Droplet Deployment Guide for CloudVoter Backend

This guide provides step-by-step instructions to deploy your CloudVoter backend on a DigitalOcean droplet with automatic restarts on high CPU/memory usage.

## 📋 Prerequisites

- DigitalOcean account
- GitHub repository with your code pushed
- SSH key configured for GitHub access (or use HTTPS)

## 🚀 Step-by-Step Deployment

### Step 1: Create DigitalOcean Droplet

1. **Log in to DigitalOcean** and click "Create" → "Droplets"

2. **Choose Configuration:**
   - **Image:** Ubuntu 22.04 LTS (recommended)
   - **Plan:** Basic
   - **CPU Options:** Regular (Shared CPU)
   - **Size:** Minimum 2GB RAM / 1 vCPU ($12/month) or 4GB RAM / 2 vCPU ($24/month) recommended
     - *Note: 1GB RAM may be insufficient for Playwright browsers*
   - **Datacenter Region:** Choose closest to your target audience
   - **Authentication:** SSH Key (recommended) or Password
   - **Hostname:** cloudvoter-backend (or your preference)

3. **Create Droplet** and note the IP address

### Step 2: Initial Server Setup

1. **SSH into your droplet:**
   ```bash
   ssh root@YOUR_DROPLET_IP
   ```

2. **Update system packages:**
   ```bash
   apt update && apt upgrade -y
   ```

3. **Create a non-root user (recommended for security):**
   ```bash
   adduser cloudvoter
   usermod -aG sudo cloudvoter
   ```

4. **Switch to the new user:**
   ```bash
   su - cloudvoter
   ```

### Step 3: Install Required Software

1. **Install Python 3.11+ and pip:**
   ```bash
   sudo apt install -y python3 python3-pip python3-venv
   python3 --version  # Verify installation
   ```

2. **Install Node.js and npm (for PM2):**
   ```bash
   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
   sudo apt install -y nodejs
   node --version  # Verify installation
   npm --version
   ```

3. **Install PM2 globally:**
   ```bash
   sudo npm install -g pm2
   pm2 --version  # Verify installation
   ```

4. **Install Git:**
   ```bash
   sudo apt install -y git
   ```

5. **Install Playwright system dependencies:**
   ```bash
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

### Step 4: Clone Your Repository

1. **Navigate to home directory:**
   ```bash
   cd ~
   ```

2. **Clone your repository:**
   
   **Option A - HTTPS (easier, no SSH key needed):**
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO/backend
   ```
   
   **Option B - SSH (if you have SSH key configured):**
   ```bash
   git clone git@github.com:YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO/backend
   ```

### Step 5: Set Up Python Environment

1. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   ```

2. **Activate virtual environment:**
   ```bash
   source venv/bin/activate
   ```

3. **Install Python dependencies:**
   ```bash
   pip install --upgrade pip
   pip install -r requirements.txt
   ```

4. **Install Playwright browsers:**
   ```bash
   playwright install chromium
   playwright install-deps chromium
   ```

### Step 6: Configure Environment Variables

1. **Create configuration file (optional but recommended):**
   ```bash
   nano config.py
   ```
   
   Update the following values:
   ```python
   TARGET_URL = "https://your-voting-url.com"
   BRIGHT_DATA_USERNAME = "your-username"
   BRIGHT_DATA_PASSWORD = "your-password"
   ```

2. **Or create a .env file:**
   ```bash
   nano .env
   ```
   
   Add:
   ```
   BRIGHT_DATA_USERNAME=your-username
   BRIGHT_DATA_PASSWORD=your-password
   SECRET_KEY=your-secret-key-here
   ```

### Step 7: Create Logs Directory

```bash
mkdir -p logs
```

### Step 8: Configure Firewall

1. **Allow SSH, HTTP, and your Flask port:**
   ```bash
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 5000/tcp  # Flask app
   sudo ufw enable
   sudo ufw status
   ```

### Step 9: Start Application with PM2

1. **Start the application:**
   ```bash
   pm2 start ecosystem.config.js
   ```

2. **Verify it's running:**
   ```bash
   pm2 status
   pm2 logs cloudvoter-backend --lines 50
   ```

3. **Set PM2 to start on system boot:**
   ```bash
   pm2 startup
   # Copy and run the command that PM2 outputs
   pm2 save
   ```

### Step 10: Test Your Deployment

1. **Check if the app is accessible:**
   ```bash
   curl http://localhost:5000/api/health
   ```

2. **Access from your browser:**
   ```
   http://YOUR_DROPLET_IP:5000
   ```

3. **Check the health endpoint:**
   ```
   http://YOUR_DROPLET_IP:5000/api/health
   ```

## 🔄 Updating Your Application

When you push updates to GitHub:

1. **SSH into your droplet:**
   ```bash
   ssh cloudvoter@YOUR_DROPLET_IP
   ```

2. **Navigate to your project:**
   ```bash
   cd ~/YOUR_REPO/backend
   ```

3. **Pull latest changes:**
   ```bash
   git pull origin main
   ```

4. **Activate virtual environment (if not already active):**
   ```bash
   source venv/bin/activate
   ```

5. **Update dependencies (if requirements.txt changed):**
   ```bash
   pip install -r requirements.txt
   ```

6. **Restart the application:**
   ```bash
   pm2 restart cloudvoter-backend
   ```

7. **Check logs:**
   ```bash
   pm2 logs cloudvoter-backend --lines 50
   ```

## 📊 Monitoring and Management

### PM2 Commands

```bash
# View application status
pm2 status

# View logs (real-time)
pm2 logs cloudvoter-backend

# View last 100 lines of logs
pm2 logs cloudvoter-backend --lines 100

# View only error logs
pm2 logs cloudvoter-backend --err

# Monitor CPU and Memory usage
pm2 monit

# Restart application
pm2 restart cloudvoter-backend

# Stop application
pm2 stop cloudvoter-backend

# Delete from PM2
pm2 delete cloudvoter-backend

# View detailed info
pm2 info cloudvoter-backend
```

### Resource Monitoring

1. **Check system resources:**
   ```bash
   # CPU and Memory usage
   htop
   
   # Or use top
   top
   
   # Disk usage
   df -h
   
   # Memory usage
   free -h
   ```

2. **PM2 Plus (Optional - Advanced Monitoring):**
   - Sign up at https://pm2.io
   - Link your server: `pm2 link YOUR_SECRET_KEY YOUR_PUBLIC_KEY`
   - Get real-time CPU/Memory alerts and dashboards

### Log Management

```bash
# View application logs
tail -f logs/cloudvoter-combined.log

# View error logs
tail -f logs/cloudvoter-error.log

# View Flask application logs
tail -f cloudvoter.log

# Clear PM2 logs
pm2 flush
```

## 🔧 Automatic Restart Configuration

The `ecosystem.config.js` is configured to automatically restart the application when:

1. **Memory exceeds 900MB** (90% of 1GB RAM)
   - Configured via `max_memory_restart: '900M'`

2. **Application crashes**
   - Configured via `autorestart: true`
   - Will retry up to 50 times with exponential backoff

3. **CPU monitoring** (requires PM2 Plus for advanced CPU-based restarts)
   - Basic monitoring enabled via `pmx: true`

### Manual CPU/Memory Restart Script (Optional)

If you want explicit CPU monitoring without PM2 Plus, create a monitoring script:

```bash
nano ~/monitor_resources.sh
```

Add:
```bash
#!/bin/bash

# Thresholds
CPU_THRESHOLD=90
MEM_THRESHOLD=90

while true; do
    # Get CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Get Memory usage
    MEM_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    
    # Check if CPU exceeds threshold
    if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
        echo "$(date): CPU usage is ${CPU_USAGE}% - Restarting application"
        pm2 restart cloudvoter-backend
        sleep 60  # Wait before checking again
    fi
    
    # Check if Memory exceeds threshold
    if (( $(echo "$MEM_USAGE > $MEM_THRESHOLD" | bc -l) )); then
        echo "$(date): Memory usage is ${MEM_USAGE}% - Restarting application"
        pm2 restart cloudvoter-backend
        sleep 60  # Wait before checking again
    fi
    
    sleep 30  # Check every 30 seconds
done
```

Make it executable and run:
```bash
chmod +x ~/monitor_resources.sh
pm2 start ~/monitor_resources.sh --name resource-monitor
pm2 save
```

## 🛡️ Security Best Practices

1. **Change default SSH port:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Change Port 22 to something else
   sudo systemctl restart sshd
   ```

2. **Disable root login:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   # Set: PermitRootLogin no
   sudo systemctl restart sshd
   ```

3. **Set up fail2ban:**
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Keep system updated:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

5. **Use strong passwords** for your Bright Data credentials

## 🐛 Troubleshooting

### Application won't start

1. **Check logs:**
   ```bash
   pm2 logs cloudvoter-backend --lines 100
   ```

2. **Verify Python dependencies:**
   ```bash
   source venv/bin/activate
   pip list
   ```

3. **Test manually:**
   ```bash
   source venv/bin/activate
   python3 app.py
   ```

### Port 5000 not accessible

1. **Check firewall:**
   ```bash
   sudo ufw status
   ```

2. **Check if app is listening:**
   ```bash
   sudo netstat -tulpn | grep 5000
   ```

3. **Check DigitalOcean firewall settings** in the dashboard

### High memory usage

1. **Check current usage:**
   ```bash
   pm2 monit
   ```

2. **Restart application:**
   ```bash
   pm2 restart cloudvoter-backend
   ```

3. **Consider upgrading droplet** to 4GB RAM

### Playwright browser issues

1. **Reinstall browsers:**
   ```bash
   source venv/bin/activate
   playwright install chromium
   playwright install-deps chromium
   ```

2. **Check system dependencies:**
   ```bash
   ldd $(which chromium) | grep "not found"
   ```

## 📝 Quick Reference

### Essential Commands
```bash
# SSH into droplet
ssh cloudvoter@YOUR_DROPLET_IP

# Navigate to project
cd ~/YOUR_REPO/backend

# Activate virtual environment
source venv/bin/activate

# Pull updates
git pull origin main

# Restart app
pm2 restart cloudvoter-backend

# View logs
pm2 logs cloudvoter-backend

# Check status
pm2 status

# Monitor resources
pm2 monit
```

## ✅ Deployment Checklist

- [ ] Droplet created with at least 2GB RAM
- [ ] SSH access configured
- [ ] Python 3.11+ installed
- [ ] Node.js and PM2 installed
- [ ] Repository cloned
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] Playwright browsers installed
- [ ] Configuration file updated
- [ ] Firewall configured
- [ ] Application started with PM2
- [ ] PM2 startup configured
- [ ] Application accessible at http://YOUR_IP:5000
- [ ] Logs directory created
- [ ] Resource monitoring configured

## 🎯 Expected Behavior

Once deployed:
- Application runs on `http://YOUR_DROPLET_IP:5000`
- Automatically restarts if memory exceeds 900MB
- Automatically restarts on crashes
- Logs are saved in `./logs/` directory
- Application starts automatically on server reboot
- Voting continues without interruption
- No voting opportunities are missed

## 📞 Support

If you encounter issues:
1. Check PM2 logs: `pm2 logs cloudvoter-backend`
2. Check application logs: `tail -f cloudvoter.log`
3. Check system resources: `pm2 monit`
4. Verify firewall: `sudo ufw status`
5. Test locally: `curl http://localhost:5000/api/health`

---

**Note:** This deployment does NOT use Nginx or reverse proxy as requested. The Flask application runs directly on port 5000 and is accessible via `http://YOUR_DROPLET_IP:5000`.
