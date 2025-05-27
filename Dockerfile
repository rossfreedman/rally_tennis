# Use Python 3.12 slim image as base
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Make startup script executable
RUN chmod +x railway_start.sh

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV FLASK_ENV=production
ENV FLASK_APP=server.py
ENV WEB_CONCURRENCY=1
ENV EVENTLET_NO_GREENDNS=yes
ENV PGCONNECT_TIMEOUT=30
ENV DISABLE_SELENIUM=true

# Create necessary directories with appropriate permissions
RUN mkdir -p data logs \
    && touch logs/server.log \
    && chown -R nobody:nogroup /app \
    && chmod -R 755 /app \
    && chmod 777 data logs logs/server.log

# Switch to non-root user
USER nobody

# Expose the default port
EXPOSE 8000

# Command to run the application using Railway startup script
CMD ["./railway_start.sh"] 