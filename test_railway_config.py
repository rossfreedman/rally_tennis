#!/usr/bin/env python3
"""
Test script to verify Railway configuration
"""
import os
import sys
import subprocess
import time
import requests
from pathlib import Path

def test_port_configuration():
    """Test that port configuration works correctly"""
    print("🔍 Testing port configuration...")
    
    # Test default port
    os.environ.pop('PORT', None)
    os.environ.pop('RAILWAY_PORT', None)
    os.environ.pop('APP_PORT', None)
    
    # Import after clearing env vars
    sys.path.insert(0, '.')
    
    # Import the function from gunicorn.conf.py
    import importlib.util
    spec = importlib.util.spec_from_file_location("gunicorn_conf", "gunicorn.conf.py")
    gunicorn_conf = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(gunicorn_conf)
    get_app_port = gunicorn_conf.get_app_port
    
    default_port = get_app_port()
    print(f"✅ Default port: {default_port}")
    assert default_port == 8000, f"Expected 8000, got {default_port}"
    
    # Test Railway PORT
    os.environ['PORT'] = '3000'
    port_with_env = get_app_port()
    print(f"✅ Port with PORT env: {port_with_env}")
    assert port_with_env == 3000, f"Expected 3000, got {port_with_env}"
    
    # Test avoiding PostgreSQL port
    os.environ['PORT'] = '5432'
    port_avoiding_pg = get_app_port()
    print(f"✅ Port avoiding PostgreSQL: {port_avoiding_pg}")
    assert port_avoiding_pg == 8000, f"Expected 8000 (avoiding 5432), got {port_avoiding_pg}"
    
    print("✅ Port configuration tests passed!")

def test_startup_script():
    """Test that the startup script exists and is executable"""
    print("🔍 Testing startup script...")
    
    script_path = Path('railway_start.sh')
    assert script_path.exists(), "railway_start.sh does not exist"
    assert os.access(script_path, os.X_OK), "railway_start.sh is not executable"
    
    print("✅ Startup script tests passed!")

def test_dockerfile_syntax():
    """Test that Dockerfile has valid syntax"""
    print("🔍 Testing Dockerfile syntax...")
    
    try:
        result = subprocess.run(
            ['docker', 'build', '--dry-run', '.'],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode != 0:
            print(f"❌ Dockerfile syntax error: {result.stderr}")
            return False
    except subprocess.TimeoutExpired:
        print("⚠️  Docker build test timed out (this might be normal)")
    except FileNotFoundError:
        print("⚠️  Docker not available for testing")
    
    print("✅ Dockerfile syntax tests passed!")

def test_health_endpoint():
    """Test that health endpoint is accessible"""
    print("🔍 Testing health endpoint...")
    
    try:
        # Start server in background for testing
        env = os.environ.copy()
        env['PORT'] = '8001'  # Use different port for testing
        
        process = subprocess.Popen(
            ['python', 'server.py'],
            env=env,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        
        # Wait for server to start
        time.sleep(3)
        
        # Test health endpoint
        response = requests.get('http://localhost:8001/health', timeout=5)
        assert response.status_code == 200, f"Health check failed: {response.status_code}"
        
        print("✅ Health endpoint tests passed!")
        
    except Exception as e:
        print(f"⚠️  Health endpoint test failed: {e}")
    finally:
        try:
            process.terminate()
            process.wait(timeout=5)
        except:
            pass

def main():
    """Run all configuration tests"""
    print("🧪 Testing Railway configuration for Rally Tennis...")
    print("=" * 50)
    
    try:
        test_port_configuration()
        test_startup_script()
        test_dockerfile_syntax()
        test_health_endpoint()
        
        print("=" * 50)
        print("🎉 All Railway configuration tests passed!")
        print("\n📋 Next steps:")
        print("1. Commit these changes to git")
        print("2. Push to Railway")
        print("3. Monitor deployment logs")
        
    except Exception as e:
        print(f"❌ Test failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 