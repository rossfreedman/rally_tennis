import multiprocessing
import os

# Server socket settings - be defensive about port selection
def get_app_port():
    """Get the application port, avoiding PostgreSQL port conflicts"""
    port = os.environ.get("PORT", "")
    railway_port = os.environ.get("RAILWAY_PORT", "")
    app_port = os.environ.get("APP_PORT", "")
    
    # Try APP_PORT first (our custom variable)
    if app_port and app_port.isdigit():
        port_num = int(app_port)
        if port_num != 5432:  # Avoid PostgreSQL port
            return port_num
    
    # Try RAILWAY_PORT
    if railway_port and railway_port.isdigit():
        port_num = int(railway_port)
        if port_num != 5432:  # Avoid PostgreSQL port
            return port_num
    
    # Try PORT but avoid PostgreSQL port
    if port and port.isdigit():
        port_num = int(port)
        if port_num != 5432:  # Avoid PostgreSQL port
            return port_num
    
    # Default to 8000 (Railway standard)
    return 8000

port = get_app_port()
bind = f"0.0.0.0:{port}"
backlog = 2048

# Worker processes
workers = 1  # Single worker for Railway deployment
worker_class = "sync"
timeout = 120  # Reasonable timeout for Railway
worker_tmp_dir = "/dev/shm"  # Use memory for worker temp files
worker_connections = 1000

# Logging
accesslog = "-"
errorlog = "-"
loglevel = "debug"
capture_output = True
enable_stdio_inheritance = True

# Process naming
proc_name = "rally"

# SSL (if needed)
keyfile = None
certfile = None

# Server mechanics
daemon = False
pidfile = None
umask = 0
user = None
group = None

# Performance tuning
keepalive = 65
forwarded_allow_ips = '*'

# Prevent long-running requests from blocking workers
graceful_timeout = 60

# Ensure proper startup
preload_app = True
reload = False  # Disable auto-reload in production

# Restart workers periodically to prevent memory leaks
max_requests = 1000
max_requests_jitter = 50

# Ensure proper proxy handling
proxy_protocol = True
proxy_allow_ips = '*' 