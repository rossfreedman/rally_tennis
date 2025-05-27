# OpenAI Functionality Disabled for Railway Deployment

This document outlines all the OpenAI functionality that has been disabled to allow deployment to Railway without OpenAI API key requirements.

## What Was Disabled

### 1. Core OpenAI Dependencies
- **File**: `requirements.txt`
- **Change**: Commented out `openai>=1.2.3` dependency
- **Impact**: OpenAI package will not be installed

### 2. Server Configuration
- **File**: `server.py`
- **Changes**:
  - Commented out OpenAI import: `from openai import OpenAI`
  - Disabled OpenAI API key validation
  - Disabled OpenAI client initialization
  - Disabled assistant initialization
- **Impact**: Server starts without requiring OpenAI credentials

### 3. AI Utilities
- **File**: `utils/ai.py`
- **Changes**:
  - Commented out OpenAI import
  - Created mock OpenAI client for compatibility
  - Disabled `get_or_create_assistant()` function
  - Disabled `update_assistant_instructions()` function
- **Impact**: All AI utility functions now raise exceptions when called

### 4. Configuration
- **File**: `config.py`
- **Changes**:
  - Disabled OpenAI API key requirement
  - Commented out API key validation
- **Impact**: Application doesn't require OPENAI_API_KEY environment variable

### 5. Route Modules
- **File**: `routes/act/__init__.py`
- **Changes**:
  - Commented out rally_ai routes import and initialization
- **Impact**: All AI chat endpoints are disabled

### 6. Lineup Generation
- **File**: `routes/act/lineup.py`
- **Changes**:
  - Commented out AI utilities import
  - Replaced AI lineup generation with disabled message
- **Impact**: `/api/generate-lineup` returns 503 error with explanation

## Disabled Features

### User-Facing Features
1. **AI Chat** (`/mobile/ask-ai`) - Page not accessible
2. **AI Lineup Generation** - Returns error message
3. **Tennis Insights API** - May have reduced functionality

### API Endpoints
1. `/api/chat` - Not available
2. `/api/generate-lineup` - Returns 503 with disabled message
3. `/mobile/ask-ai` - Route not registered

## How to Re-enable OpenAI Functionality

### 1. Restore Dependencies
```bash
# In requirements.txt, uncomment:
openai>=1.2.3
```

### 2. Restore Server Configuration
In `server.py`, uncomment all OpenAI-related code:
- OpenAI import
- API key validation
- Client initialization
- Assistant initialization

### 3. Restore AI Utilities
In `utils/ai.py`, uncomment all OpenAI-related code:
- OpenAI import
- Client initialization
- Function implementations

### 4. Restore Configuration
In `config.py`, uncomment:
- OpenAI API key loading
- API key validation

### 5. Restore Routes
In `routes/act/__init__.py`, uncomment:
- Rally AI import
- Rally AI route initialization

### 6. Restore Lineup Generation
In `routes/act/lineup.py`:
- Uncomment AI utilities import
- Restore original `generate_lineup()` function

### 7. Set Environment Variables
```bash
OPENAI_API_KEY=your_api_key_here
OPENAI_ASSISTANT_ID=your_assistant_id_here
OPENAI_ORG_ID=your_org_id_here  # Optional
```

## Testing

After making changes, test that the server starts successfully:

```bash
python -c "import server; print('✅ Server imports successfully')"
```

## Notes

- All disabled code is marked with `# DISABLED FOR RAILWAY DEPLOYMENT`
- Mock OpenAI client prevents import errors in existing code
- Disabled endpoints return appropriate error messages
- No data or functionality is lost - only AI features are temporarily unavailable

## Railway Deployment

With these changes, the application can be deployed to Railway without:
- OpenAI API keys
- OpenAI package dependencies
- Assistant configuration

The core tennis application functionality remains fully operational. 