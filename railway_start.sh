#!/bin/bash

# Railway startup script for Rally Tennis app
set -e

echo "🚀 Starting Rally Tennis on Railway..."
echo "📅 Current time: $(date)"
echo "🐍 Python version: $(python --version)"
echo "📁 Current directory: $(pwd)"
echo "📋 Directory contents:"
ls -la

# Set port with priority: APP_PORT > PORT > default 8000
export PORT=${APP_PORT:-${PORT:-8000}}
echo "📡 Using port: $PORT"

# Ensure database connection variables are set
if [ -z "$DATABASE_URL" ]; then
    echo "⚠️  WARNING: DATABASE_URL not set"
else
    echo "✅ DATABASE_URL is set"
fi

# Set production environment
export FLASK_ENV=production
export PYTHONUNBUFFERED=1
export DISABLE_SELENIUM=true

echo "🔍 Environment variables:"
echo "FLASK_ENV=$FLASK_ENV"
echo "PYTHONUNBUFFERED=$PYTHONUNBUFFERED"
echo "DISABLE_SELENIUM=$DISABLE_SELENIUM"
echo "SKIP_DB_HEALTH_CHECK=$SKIP_DB_HEALTH_CHECK"

# Test if server.py can be imported
echo "🧪 Testing Python import..."
python -c "import server; print('✅ Server import successful')" || echo "❌ Server import failed"

# Start Gunicorn with Railway-optimized settings
echo "🔧 Starting Gunicorn..."
exec gunicorn server:app \
    --bind "0.0.0.0:$PORT" \
    --workers 1 \
    --worker-class sync \
    --timeout 120 \
    --keep-alive 65 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --preload \
    --log-level info \
    --access-logfile - \
    --error-logfile - \
    --capture-output \
    --enable-stdio-inheritance \
    --forwarded-allow-ips='*' 