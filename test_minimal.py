#!/usr/bin/env python3
"""
Minimal Flask app for testing Railway deployment
"""
import os
from flask import Flask

app = Flask(__name__)

@app.route('/simple-health')
def health():
    return "OK", 200

@app.route('/')
def home():
    return "Rally Tennis - Minimal Test", 200

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    print(f"Starting minimal test app on port {port}")
    app.run(host='0.0.0.0', port=port, debug=False) 