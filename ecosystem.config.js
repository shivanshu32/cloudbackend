module.exports = {
  apps: [
    {
      name: 'cloudvoter-backend',
      script: 'app.py',
      interpreter: 'python3',
      cwd: './',
      
      // Instances and execution mode
      instances: 1,
      exec_mode: 'fork',
      
      // Auto restart configuration
      autorestart: true,
      watch: false,
      max_restarts: 10,
      min_uptime: '10s',
      restart_delay: 5000,
      
      // Memory management
      max_memory_restart: '900M',  // Restart if memory exceeds 900MB (safe for 1GB RAM)
      
      // Logging
      error_file: './logs/cloudvoter-error.log',
      out_file: './logs/cloudvoter-out.log',
      log_file: './logs/cloudvoter-combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      
      // Environment variables
      env: {
        NODE_ENV: 'production',
        PYTHONUNBUFFERED: '1',
        PYTHONIOENCODING: 'utf-8'
      },
      
      // Process management
      kill_timeout: 5000,
      listen_timeout: 10000,
      shutdown_with_message: false,
      
      // Advanced features
      exp_backoff_restart_delay: 100,
      
      // Cron restart (optional - restart daily at 4 AM to clear memory)
      // cron_restart: '0 4 * * *',
      
      // Stop signals
      stop_exit_codes: [0],
      
      // Process title
      instance_var: 'INSTANCE_ID',
      
      // Error handling
      wait_ready: false,
      autorestart: true,
      
      // Additional options
      vizion: false,
      post_update: [],
      force: true
    }
  ],
  
  // Deployment configuration (optional)
  deploy: {
    production: {
      user: 'node',
      host: 'localhost',
      ref: 'origin/main',
      repo: 'git@github.com:repo.git',
      path: '/var/www/cloudvoter',
      'post-deploy': 'npm install && pm2 reload ecosystem.config.js --env production'
    }
  }
};
