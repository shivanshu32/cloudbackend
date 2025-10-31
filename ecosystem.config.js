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
      
      // Auto restart configuration - CRITICAL for voting continuity
      autorestart: true,
      watch: false,
      max_restarts: 50,  // Increased to handle more restarts
      min_uptime: '10s',
      restart_delay: 3000,  // 3 seconds delay before restart
      
      // Resource-based restart thresholds (90% CPU/Memory monitoring)
      max_memory_restart: '900M',  // Restart if memory exceeds 900MB (~90% of 1GB)
      
      // PM2 Plus monitoring (optional but recommended for CPU/Memory tracking)
      // This helps monitor resource usage in real-time
      pmx: true,
      
      // Logging - Essential for debugging
      error_file: './logs/cloudvoter-error.log',
      out_file: './logs/cloudvoter-out.log',
      log_file: './logs/cloudvoter-combined.log',
      time: true,
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      max_size: '10M',  // Rotate logs at 10MB
      retain: 5,  // Keep 5 rotated log files
      
      // Environment variables
      env: {
        NODE_ENV: 'production',
        PYTHONUNBUFFERED: '1',
        PYTHONIOENCODING: 'utf-8',
        FLASK_ENV: 'production'
      },
      
      // Process management
      kill_timeout: 5000,
      listen_timeout: 10000,
      shutdown_with_message: false,
      
      // Exponential backoff for restart delays
      exp_backoff_restart_delay: 100,
      
      // Optional: Restart daily at 4 AM to clear memory and ensure fresh state
      // Uncomment if you want scheduled restarts
      // cron_restart: '0 4 * * *',
      
      // Stop signals
      stop_exit_codes: [0],
      
      // Process title
      instance_var: 'INSTANCE_ID',
      
      // Error handling - Never give up on restarts
      wait_ready: false,
      
      // Additional options
      vizion: false,
      post_update: [],
      force: true,
      
      // Crash handling - Restart on any crash
      restart_on_error: true,
      
      // Keep process alive even if it crashes repeatedly
      min_restart_time: 0
    }
  ]
};
