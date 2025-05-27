#!/bin/bash

# Minimal Railway startup script for testing
set -e

echo "🚀 Starting MINIMAL Rally Tennis test..."
echo "📅 Current time: $(date)"
echo "🐍 Python version: $(python --version)"

# Set port
export PORT=${PORT:-8000}
echo "📡 Using port: $PORT"

# Test minimal app
echo "🧪 Testing minimal app import..."
python -c "import test_minimal; print('✅ Minimal app import successful')" || echo "❌ Minimal app import failed"

# Start with Gunicorn
echo "🔧 Starting Gunicorn with minimal app..."
exec gunicorn test_minimal:app \
    --bind "0.0.0.0:$PORT" \
    --workers 1 \
    --timeout 120 \
    --log-level info \
    --access-logfile - \
    --error-logfile - 