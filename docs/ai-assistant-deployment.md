# LA Toolkit AI Assistant - Deployment Guide

## Overview

The LA Toolkit AI Assistant provides intelligent, context-aware help for deploying Living Atlas portals. It uses ChromaDB as a vector database to store and retrieve knowledge from LA/GBIF documentation and code.

**Status**: Production-ready ✅  
**Availability**: Web UI at `/#!/ai-assistant`

---

## Architecture

### Components

- **Frontend**: Flutter web page with chat interface
- **Backend**: Sails.js REST API (`POST /api/v1/ai/query`)
- **Database**: ChromaDB vector store (1,227+ indexed documents)
- **Knowledge Base**: LA/GBIF deployment, configuration, and troubleshooting docs

### ChromaDB Modes

| Mode | Environment | Configuration | Use Case |
|------|-------------|---------------|----------|
| **Embedded Local** | Production | `CHROMA_DB_PATH=/home/ubuntu/kb-data` | Containerized, no external deps |
| **HTTP Remote** | Development | `CHROMA_DB_PATH=http://localhost:8000` | Local testing with separate server |
| **SSH Tunnel** | Development | SSH port forward + HTTP config | Remote KB access |

---

## Development Setup

### Prerequisites

- Node.js v20+
- Python 3.9+ (for ChromaDB)
- MongoDB 8.0+ running on `localhost:27017`
- Docker + Docker Compose (optional, for full stack)

### Quick Start (Local Development)

#### 1. Start Backend Services

**Terminal 1**: Start MongoDB
```bash
docker-compose -f docker-compose.develop.yml up mongo
```

**Terminal 2**: Start ChromaDB
```bash
cd la_toolkit_backend
pip install chromadb
chroma run --path ./kb-data --port 8000
```

**Terminal 3**: Start Sails Backend
```bash
cd la_toolkit_backend
npm run dev
# Loads .env.development with CHROMA_DB_PATH=http://localhost:8000
```

#### 2. Start Frontend

**Terminal 4**: Start Flutter web
```bash
cd la_toolkit
flutter run -d chrome --web-port 5000
```

#### 3. Access AI Assistant

Navigate to: `http://localhost:5000/#!/ai-assistant`

Test query: *"How do I deploy a minimal Living Atlas?"*

### Environment File (Development)

**File**: `la_toolkit_backend/.env.development`

```bash
# Database connection
DATABASE_URL=mongodb://la_toolkit_user:la_toolkit_changeme@localhost:27017/la_toolkit

# ChromaDB - Points to local HTTP server on port 8000
CHROMA_DB_PATH=http://localhost:8000

# Node environment
NODE_ENV=development
```

---

## Production Deployment

### Docker Compose (Recommended)

**File**: `docker-compose.yml`

```yaml
services:
  la-toolkit:
    image: livingatlases/la-toolkit:latest
    environment:
      DATABASE_URL: mongodb://la_toolkit_user:la_toolkit_changeme@mongo:27017/la_toolkit
      CHROMA_DB_PATH: /home/ubuntu/kb-data  # Embedded in container
      NODE_ENV: production
    depends_on:
      mongo:
        condition: service_healthy
    volumes:
      - /data/la-toolkit/config/:/home/ubuntu/ansible/la-inventories/:rw
      - /data/la-toolkit/logs/:/home/ubuntu/ansible/logs/:rw
      # Optional: Mount external KB for live updates
      # - /data/la-toolkit/kb-data:/home/ubuntu/kb-data:ro
```

### Deployment Steps

```bash
# 1. Copy docker-compose.yml to your server
scp docker-compose.yml user@server:/data/la-toolkit/

# 2. Create directories
ssh user@server "mkdir -p /data/la-toolkit/{config,logs,ssh,mongo,backups}"

# 3. Start services
ssh user@server "cd /data/la-toolkit && docker-compose up -d"

# 4. Verify AI Assistant is working
curl http://server:2011/api/v1/ai/query \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"question":"What is Living Atlas?"}'
```

### Environment Variables (Production)

| Variable | Default | Description |
|----------|---------|-------------|
| `CHROMA_DB_PATH` | `/home/ubuntu/kb-data` | Path to ChromaDB data (embedded in container) |
| `DATABASE_URL` | (required) | MongoDB connection string |
| `NODE_ENV` | `production` | Set to "production" |
| `TOOLKIT_PUBLIC_URL` | `localhost:2010` | Public URL for external access |
| `TOOLKIT_HTTPS` | `false` | Enable HTTPS (requires proxy) |

---

## Troubleshooting

### AI Assistant Shows "Not Available"

**Issue**: Chrome DB client is null, endpoint disabled

**Solution**:
1. Check backend logs: `docker-compose logs la-toolkit | grep AI`
2. Verify ChromaDB is running: `curl http://localhost:8000/api/v2/heartbeat`
3. Check `CHROMA_DB_PATH` environment variable is set
4. Restart backend: `docker-compose restart la-toolkit`

### Connection Refused on Port 8000

**Issue**: ChromaDB server not running

**Solution** (Development):
```bash
# Kill old processes
pkill -f "chroma run"

# Restart ChromaDB
cd la_toolkit_backend
chroma run --path ./kb-data --port 8000
```

**Solution** (Production):
```bash
# KB-data should be embedded in container at /home/ubuntu/kb-data
# If not, build Dockerfile with KB included:
docker build -t livingatlases/la-toolkit:latest \
  -f docker/u22/Dockerfile .

docker-compose up -d --build
```

### Knowledge Base is Outdated

**Development**: Replace `kb-data/` directory and restart ChromaDB

**Production**: Three options:
1. Mount external volume:
   ```yaml
   volumes:
     - /data/la-toolkit/kb-data:/home/ubuntu/kb-data:ro
   ```
2. Rebuild Docker image with new KB
3. Use SSH tunnel to remote KB server

---

## API Reference

### Query Endpoint

**POST** `/api/v1/ai/query`

**Request**:
```json
{
  "question": "How do I set up authentication?",
  "context": {
    "service": "collectory",
    "deploymentType": "docker-compose"
  }
}
```

**Response**:
```json
{
  "answer": "To set up authentication in Living Atlas...",
  "sources": [
    {
      "document": "CAS-5 Configuration",
      "relevance": 0.95,
      "url": "https://..."
    }
  ],
  "confidence": 0.92
}
```

**Error Responses**:
- `503`: ChromaDB not initialized
- `400`: Invalid question format
- `500`: Backend error

---

## Development: Backend Bootstrap Process

When the Sails backend starts, it:

1. Checks MongoDB connection
2. Initializes ChromaDB (config/bootstrap.js)
   - Reads `CHROMA_DB_PATH` env variable
   - If HTTP URL → connects to remote ChromaDB server
   - If local path → initializes embedded ChromaDB
3. Stores client reference in `sails.config.custom.chromaClient`
4. Uses client in AI query endpoint

**Log Output** (success):
```
[AI] Initializing ChromaDB from: http://localhost:8000
[AI] Using remote ChromaDB at localhost:8000
[AI] ChromaDB initialized successfully
```

**Log Output** (failure):
```
[AI] ChromaDB initialization failed: Connection refused
[AI] AI Assistant will not be available
[AI] To enable: use CHROMA_DB_PATH=/path/to/kb-data or CHROMA_DB_PATH=http://host:8000
```

---

## Knowledge Base Management

### KB Structure

```
kb-data/
├── 109f3ec9-cad8-4e47-a2bc-ace13a979f42/    # Collection 1
├── 27a8e066-3e03-4c17-8c0b-d3974d27bef3/    # Collection 2
├── 41e66235-aabc-452d-a730-75762e8b9d30/    # Collection 3
└── 5050619b-e2f6-448a-a11a-f1db617f0f5f/    # Collection 4
```

Each collection contains:
- `chroma.parquet` - Vector embeddings
- `metadata.parquet` - Document metadata
- `data_level_0.bin` - Binary data

### Updating KB

1. **Development**:
   ```bash
   # Stop ChromaDB
   pkill -f "chroma run"
   
   # Replace kb-data
   rm -rf la_toolkit_backend/kb-data/*
   # ... restore or download new KB ...
   
   # Restart
   chroma run --path ./la_toolkit_backend/kb-data --port 8000
   ```

2. **Production with Volume Mount**:
   ```bash
   # Stop containers
   docker-compose down
   
   # Update volume
   rm -rf /data/la-toolkit/kb-data/*
   # ... restore or download new KB ...
   
   # Restart
   docker-compose up -d
   ```

3. **Production (Rebuild Image)**:
   ```bash
   # Include new KB-data in Dockerfile
   # Build new image
   docker build -t livingatlases/la-toolkit:v1.6.10 \
     -f docker/u22/Dockerfile .
   
   # Update docker-compose.yml
   # Restart services
   docker-compose up -d --build
   ```

---

## Performance Tuning

### ChromaDB Query Performance

- **Number of results**: Default 3, adjustable in `api/helpers/ai-query.js`
- **Similarity threshold**: 0.5 (minimum relevance score)
- **Embedding dimension**: 384 (default, depends on model)

### Optimization Tips

1. **Reduce KB size**: Remove irrelevant documents
2. **Enable caching**: Use `node-cache` in backend
3. **Parallel queries**: Implement request queuing
4. **Index optimization**: Rebuild ChromaDB periodically

---

## References

- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Sails.js Hooks](https://sailsjs.com/documentation/concepts/models-and-orm/lifecycle-callbacks)
- [LA Toolkit GitHub](https://github.com/living-atlases/la-toolkit)
- [Flutter Web Deployment](https://flutter.dev/docs/deployment/web)

---

## FAQ

**Q: Can I use the AI Assistant without internet?**  
A: Yes! It runs entirely locally. ChromaDB doesn't require external APIs.

**Q: How often is the KB updated?**  
A: Currently manual. We're working on automated updates from LA/GBIF repos.

**Q: Can I add custom KB documents?**  
A: Yes, by updating kb-data and restarting ChromaDB/backend.

**Q: What if ChromaDB runs out of memory?**  
A: Reduce KB size or increase Docker memory limit.

**Q: Can I use a separate ChromaDB server?**  
A: Yes! Set `CHROMA_DB_PATH=http://chroma-server:8000`

---

**Last Updated**: 2026-03-17  
**Maintainer**: LA Toolkit Development Team
