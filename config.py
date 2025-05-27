from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# DISABLED FOR RAILWAY DEPLOYMENT - OpenAI functionality removed
# Get OpenAI API key
# OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')

# Verify key is loaded
# if not OPENAI_API_KEY:
#     raise ValueError("OpenAI API key not found in .env file") 