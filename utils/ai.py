# DISABLED FOR RAILWAY DEPLOYMENT - All OpenAI functionality removed
import os
import traceback
import logging
# from openai import OpenAI

# Reduce OpenAI HTTP logging verbosity in production
is_development = os.environ.get('FLASK_ENV') == 'development'
# if not is_development:
#     logging.getLogger("openai").setLevel(logging.WARNING)
#     logging.getLogger("httpcore").setLevel(logging.WARNING)
#     logging.getLogger("httpx").setLevel(logging.WARNING)

# Initialize OpenAI client
# client = OpenAI(
#     api_key=os.getenv('OPENAI_API_KEY'),
#     organization=os.getenv('OPENAI_ORG_ID')
# )

# Stub client for compatibility
class MockOpenAIClient:
    def __init__(self):
        pass

client = MockOpenAIClient()

# Get assistant ID from environment variable
# assistant_id = os.getenv('OPENAI_ASSISTANT_ID')

def get_or_create_assistant():
    """DISABLED: Get the paddle tennis assistant (do not set or update instructions here)"""
    raise Exception("OpenAI functionality has been disabled for Railway deployment. AI features are not available.")

def update_assistant_instructions(new_instructions):
    """DISABLED: Update the assistant's instructions"""
    raise Exception("OpenAI functionality has been disabled for Railway deployment. AI features are not available.") 