# Design Spec: living-atlas-kb

**Date:** 2026-04-27  
**Status:** Draft  
**Repo:** `living-atlases/living-atlas-kb` (to be created)

---

## Overview

A public, community-accessible knowledge base service for the Living Atlas / ALA ecosystem. Exposes a ChromaDB vector store (semantic search over ~4500 docs from ALA/GBIF repositories) via two interfaces:

1. **REST API** — for scripts, curl, and direct integration (e.g. la-toolkit frontend)
2. **MCP remote server** — for AI IDEs and agents (OpenCode, Claude Desktop, Cursor, Zed, Gemini CLI, Windsurf)

Target audience: 10–20 Living Atlas community members.  
Access: Public, no authentication required.  
Infrastructure: Existing IFCA VM `la-toolkit-kb-dev-2026` (Ubuntu 24.04).

---

## Architecture

```
la-toolkit-kb-dev-2026 (IFCA VM)
├── ChromaDB (PersistentClient, /opt/la-toolkit-kb/data/chromadb/)
│   ├── la_toolkit_kb        — 3671 docs (collectory, biocache, ala-bie, spatial, image-service, species-lists, ...)
│   └── la-toolkit-tier1     — 858 docs (ala-install, la-toolkit, gbif-pipelines)
│
├── FastAPI REST service (localhost:8080)
│   ├── POST /api/query      → semantic search, returns ranked results
│   └── GET  /api/collections → lists collections with doc counts
│
├── MCP HTTP server (localhost:3000, streamable-HTTP)
│   ├── tool: query_ala_kb
│   └── tool: list_ala_kb_collections
│   (internally calls FastAPI REST)
│
└── nginx (public, TLS)
    └── kb.living-atlas.org (or similar domain)
        ├── /api/*  → FastAPI REST
        ├── /mcp    → MCP HTTP server
        └── /       → redirect to GitHub Pages docs
```

The existing local MCP stdio server (`~/mcp-servers/ala-kb/server.py`) is kept for local SSH use. The new HTTP MCP server is a separate binary that calls the REST API.

---

## Repository Structure

```
living-atlas-kb/
├── README.md                        # Overview + quickstart table (one snippet per IDE)
├── docs/                            # GitHub Pages source
│   ├── index.md                     # What it is, quickstart
│   ├── usage.md                     # How to use: each IDE, curl, Python
│   ├── repos.md                     # Included repos table + update frequency
│   ├── adding-content.md            # How to add repos / re-index
│   └── deployment.md                # Self-hosting instructions
├── indexer/                         # ChromaDB population scripts
│   ├── config.yml                   # Repo list, patterns, collection mappings
│   ├── index_repo.py                # Clone + chunk + embed + upsert
│   └── requirements.txt
├── server/
│   ├── api.py                       # FastAPI REST service
│   ├── mcp_stdio.py                 # MCP local (stdio, SSH use)
│   ├── mcp_http.py                  # MCP remote (streamable-HTTP, public)
│   └── requirements.txt
├── ansible/
│   └── deploy.yml                   # Deploys server + nginx on target host
└── .github/
    └── workflows/
        └── reindex.yml              # Scheduled re-indexing (monthly or on push to config.yml)
```

---

## Components

### FastAPI REST (`server/api.py`)

- `POST /api/query` — body: `{ question, collection?, n_results? }` → returns list of `{ content, metadata: { repo, file, chunk }, relevance }`
- `GET /api/collections` — returns `[{ name, count }]`
- Runs as systemd service `la-toolkit-kb-api`
- Reads ChromaDB directly (same machine, no SSH needed)
- No auth. Rate limiting via nginx if needed.

### MCP HTTP Server (`server/mcp_http.py`)

- Streamable-HTTP transport (MCP spec 2025-03-26)
- Exposes same two tools as current stdio server
- Internally calls `http://localhost:8080/api/...`
- Runs as systemd service `la-toolkit-kb-mcp`
- IDE config snippet (example for OpenCode):

```json
"ala-kb": {
  "type": "remote",
  "url": "https://kb.living-atlas.org/mcp"
}
```

### MCP Stdio Server (`server/mcp_stdio.py`)

- Kept for local SSH use (existing workflow unchanged)
- Calls REST API at `http://localhost:8080` (no SSH, no ChromaDB direct)
- Users with SSH access to the server use this

### Indexer (`indexer/`)

- `config.yml` defines: repo URL, branch, file glob patterns, target collection, description
- `index_repo.py`: clones repo → splits files into chunks (by function/section or fixed size) → embeds with `sentence-transformers/all-MiniLM-L6-v2` → upserts into ChromaDB
- Idempotent: re-running updates existing chunks
- Can be run manually or via GitHub Actions

### GitHub Actions (`reindex.yml`)

- Triggers: monthly schedule + manual dispatch + push to `indexer/config.yml`
- SSH into server → runs `index_repo.py` for all repos in config
- Updates `docs/repos.md` with last-indexed timestamps

---

## Documentation (GitHub Pages)

Hosted at `https://living-atlases.github.io/living-atlas-kb/` (or custom domain).

Pages:
1. **index.md** — What is this, why it exists, quickstart snippets for each IDE
2. **usage.md** — Full usage guide:
   - OpenCode (`opencode.json` snippet)
   - Claude Desktop (`claude_desktop_config.json` snippet)
   - Cursor / Zed / Windsurf (MCP settings)
   - Gemini CLI (`settings.json` snippet)
   - `curl` examples
   - Python client example
3. **repos.md** — Table of included repos:
   | Repo | Description | Collection | Last indexed | Update frequency |
   |------|-------------|------------|-------------|-----------------|
   | collectory | ... | la_toolkit_kb | 2026-04-01 | monthly |
   | biocache-service | ... | la_toolkit_kb | 2026-04-01 | monthly |
   | ala-install | ... | la-toolkit-tier1 | 2026-04-01 | monthly |
   | ... | | | | |
4. **adding-content.md** — How to add a new repo to `config.yml`, test locally, open PR
5. **deployment.md** — How to deploy your own instance (ansible playbook, requirements)

---

## Deployment

- Ansible playbook `ansible/deploy.yml` handles:
  - Install Python venv + deps
  - Copy `server/api.py` and `server/mcp_http.py`
  - Create systemd services
  - Configure nginx with TLS (Let's Encrypt or provided cert)
- Target: `la-toolkit-kb-dev-2026` (existing VM, already has ChromaDB populated)
- Domain: TBD — needs DNS entry (e.g. `kb.living-atlas.org` or `kb.gbif.es`)

---

## Plan D: Chat Endpoint with Local LLM (Ollama)

> **Status:** Future scope — not blocking Plan A. Implement after REST + MCP are stable.

### Goal

Add `POST /api/chat` endpoint: user sends a question, the server runs RAG (semantic search → top-k chunks) and passes context + question to a local LLM (via Ollama). Returns a grounded answer with citations.

### Architecture Addition

```
la-toolkit-kb-dev-2026
├── ... (existing)
├── Ollama (localhost:11434)
│   └── model: qwen2.5:14b-instruct-q4_K_M  (recommended start)
│       or:   qwen3.6-35b-a3b:q3            (higher quality, 17GB RAM)
└── FastAPI: POST /api/chat
    1. embed question → ChromaDB query (top-5 chunks)
    2. build prompt: system + context chunks + question
    3. POST http://localhost:11434/api/chat
    4. stream or return answer + source citations
```

### Model Selection

| Model | Quantization | RAM needed | Fits 23GB? | Speed (CPU) | Quality |
|-------|-------------|------------|-----------|-------------|---------|
| Qwen2.5-3B-Instruct | Q4_K_M | ~3GB | ✅✅ | ~15 tok/s | Basic |
| Qwen2.5-7B-Instruct | Q4_K_M | ~5GB | ✅✅ | ~8 tok/s | Good |
| Qwen2.5-14B-Instruct | Q4_K_M | ~9GB | ✅✅ | ~4 tok/s | Very good |
| **Qwen3.6-35B-A3B** | **Q3_K_S** | **~17GB** | **✅** | **~3 tok/s** | **Excellent (MoE)** |
| Qwen3.6-35B-A3B | Q4_K_M | ~22GB | ⚠️ risky | ~2 tok/s | Excellent (MoE) |

**Recommended start:** `qwen2.5:14b-instruct-q4_K_M` — safe (9GB), fast enough, good domain quality.  
**Upgrade path:** `qwen3.6-35b-a3b:q3` once RAM confirmed (only 3B params active per token — MoE architecture).

> **Note on Qwen3.6-35B-A3B:** This is a Mixture-of-Experts model. Total parameters: 35B (needed in RAM). Active parameters per forward pass: ~3B. Result: memory of a 35B model, compute of a 3B. At Q3 quantization, fits in ~17GB leaving ~6GB for OS + ChromaDB + FastAPI.

### API Contract

```
POST /api/chat
{
  "question": "How do I configure the collectory database connection?",
  "collection": "la_toolkit_kb",   // optional, default la_toolkit_kb
  "n_context": 5,                  // optional, chunks to retrieve
  "model": "qwen2.5:14b",          // optional, override default model
  "stream": false                  // optional, stream response
}

→ 200 OK
{
  "answer": "To configure the collectory database...",
  "sources": [
    { "repo": "collectory", "file": "grails-app/conf/application.groovy", "relevance": 0.82 },
    { "repo": "ala-install", "file": "ansible/roles/collectory/defaults/main.yml", "relevance": 0.74 }
  ],
  "model": "qwen2.5:14b",
  "tokens_used": 1423
}
```

### New Files (Plan D)

```
living-atlas-kb/
└── server/
    └── chat.py          # /api/chat endpoint: RAG + Ollama integration
tests/
    └── test_chat.py     # Tests with mocked ChromaDB + mocked Ollama
ansible/
    └── install_ollama.yml  # Install Ollama + pull default model
```

### Prerequisites

1. Ollama installed on `la-toolkit-kb-dev-2026`: `curl -fsSL https://ollama.ai/install.sh | sh`
2. Model pulled: `ollama pull qwen2.5:14b`
3. Verify RAM headroom: `free -h` after API + MCP services are running
4. If RAM tight: use `qwen2.5:7b` or reduce to 14B-Q3

### Out of Scope for Plan D

- Streaming responses (can add later)
- Conversation history / multi-turn (stateless RAG only)
- Model fine-tuning on ALA docs

---

## Out of Scope

- Authentication / per-user access control (public, read-only)
- Write operations to ChromaDB from the API
- Web UI for browsing the KB (docs page only)
- Multi-instance / HA setup

---

## Decisions Made

1. **Domain**: `kb.l-a.site` — community-owned, short, neutral
2. **Re-indexing trigger**: webhook-based — GitHub webhook on push to tracked repos triggers reindex of that repo; monthly fallback cron as safety net
3. **Chunking strategy**: per-function/class — better precision for both development (understand code structure) and support (find config vars, error handling). Implementation: use tree-sitter or regex heuristics to split at function/class boundaries; fall back to fixed-size (512 tokens) for non-code files (YAML, properties, markdown)
