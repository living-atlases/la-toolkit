# living-atlas-kb: REST API + MCP HTTP Server — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the `living-atlases/living-atlas-kb` GitHub repo with a FastAPI REST service and MCP HTTP server that expose the existing ChromaDB knowledge base publicly at `kb.l-a.site`.

**Architecture:** FastAPI REST on `localhost:8080` reads ChromaDB directly (same host). MCP streamable-HTTP server on `localhost:3000` proxies to the REST API. nginx terminates TLS and routes `/api/*` and `/mcp` to each service. Both run as systemd services deployed via Ansible.

**Tech Stack:** Python 3.11+, FastAPI, uvicorn, mcp 1.27+, pydantic, chromadb, nginx, systemd, Ansible, GitHub Actions

---

## File Map

```
living-atlas-kb/
├── server/
│   ├── api.py              # FastAPI REST service (reads ChromaDB directly)
│   ├── mcp_http.py         # MCP streamable-HTTP server (calls REST API)
│   ├── mcp_stdio.py        # MCP stdio server (local SSH use, refactored from ~/mcp-servers/ala-kb/server.py)
│   └── requirements.txt    # fastapi, uvicorn, chromadb, mcp, sentence-transformers, httpx
├── tests/
│   ├── test_api.py         # FastAPI unit tests (TestClient, no ChromaDB needed)
│   └── test_mcp_tools.py   # MCP tool logic unit tests
├── ansible/
│   └── deploy.yml          # Deploy services + nginx on la-toolkit-kb-dev-2026
├── .github/
│   └── workflows/
│       └── ci.yml          # Run tests on push
└── README.md               # Quickstart
```

---

### Task 1: Initialize repo and Python package structure

**Files:**
- Create: `server/requirements.txt`
- Create: `server/__init__.py` (empty)
- Create: `tests/__init__.py` (empty)
- Create: `README.md`

- [ ] **Step 1: Create repo locally**

```bash
mkdir living-atlas-kb && cd living-atlas-kb
git init
git branch -m main
```

- [ ] **Step 2: Create `server/requirements.txt`**

```
fastapi>=0.115
uvicorn[standard]>=0.30
chromadb>=0.5
sentence-transformers>=3.0
mcp>=1.27
httpx>=0.27
pydantic>=2.0
```

- [ ] **Step 3: Create Python venv and install**

```bash
python3 -m venv venv
venv/bin/pip install -r server/requirements.txt
```

- [ ] **Step 4: Create empty `__init__.py` files**

```bash
mkdir -p server tests
touch server/__init__.py tests/__init__.py
```

- [ ] **Step 5: Create minimal README.md**

```markdown
# living-atlas-kb

Knowledge base service for Living Atlas / ALA repositories.

- REST API: `https://kb.l-a.site/api/`
- MCP remote: `https://kb.l-a.site/mcp`

See [API docs](https://kb.l-a.site/api/docs) for usage.
```

- [ ] **Step 6: Initial commit**

```bash
git add .
git commit -m "chore: init repo structure"
```

---

### Task 2: FastAPI REST service

**Files:**
- Create: `server/api.py`
- Create: `tests/test_api.py`

- [ ] **Step 1: Write failing tests for REST API**

Create `tests/test_api.py`:

```python
import pytest
from unittest.mock import MagicMock, patch
from fastapi.testclient import TestClient


@pytest.fixture
def mock_chroma():
    """Mock ChromaDB collection."""
    col = MagicMock()
    col.query.return_value = {
        "documents": [["content of doc 1", "content of doc 2"]],
        "metadatas": [[
            {"repo": "collectory", "file": "grails-app/conf/application.groovy", "chunk": 0, "description": "Config"},
            {"repo": "ala-install", "file": "ansible/roles/collectory/tasks/main.yml", "chunk": 0, "description": "Tasks"},
        ]],
        "distances": [[0.3, 0.5]],
    }
    return col


@pytest.fixture
def mock_client(mock_chroma):
    """Mock ChromaDB PersistentClient."""
    client = MagicMock()
    client.get_collection.return_value = mock_chroma
    client.list_collections.return_value = [
        MagicMock(name="la_toolkit_kb", count=lambda: 3671),
        MagicMock(name="la-toolkit-tier1", count=lambda: 858),
    ]
    return client


@pytest.fixture
def test_client(mock_client):
    with patch("server.api.chroma_client", mock_client):
        from server.api import app
        return TestClient(app)


def test_query_returns_results(test_client, mock_chroma):
    response = test_client.post("/api/query", json={"question": "collectory database config"})
    assert response.status_code == 200
    data = response.json()
    assert len(data["results"]) == 2
    assert data["results"][0]["metadata"]["repo"] == "collectory"
    assert 0.0 <= data["results"][0]["relevance"] <= 1.0
    assert "content of doc 1" in data["results"][0]["content"]


def test_query_default_collection(test_client, mock_client):
    test_client.post("/api/query", json={"question": "test"})
    mock_client.get_collection.assert_called_with("la_toolkit_kb")


def test_query_custom_collection(test_client, mock_client):
    test_client.post("/api/query", json={"question": "test", "collection": "la-toolkit-tier1"})
    mock_client.get_collection.assert_called_with("la-toolkit-tier1")


def test_query_n_results_capped_at_10(test_client, mock_chroma):
    test_client.post("/api/query", json={"question": "test", "n_results": 99})
    call_kwargs = mock_chroma.query.call_args.kwargs
    assert call_kwargs["n_results"] <= 10


def test_query_missing_question_returns_422(test_client):
    response = test_client.post("/api/query", json={})
    assert response.status_code == 422


def test_collections_returns_list(test_client):
    response = test_client.get("/api/collections")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data["collections"], list)
    assert len(data["collections"]) == 2
    names = [c["name"] for c in data["collections"]]
    assert "la_toolkit_kb" in names


def test_health_check(test_client):
    response = test_client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
```

- [ ] **Step 2: Run tests — verify they fail**

```bash
cd living-atlas-kb
venv/bin/pytest tests/test_api.py -v
```

Expected: `ModuleNotFoundError: No module named 'server.api'`

- [ ] **Step 3: Implement `server/api.py`**

```python
"""FastAPI REST service for Living Atlas Knowledge Base."""

import os
from contextlib import asynccontextmanager
from typing import Optional

import chromadb
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

CHROMA_PATH = os.environ.get("CHROMA_PATH", "/opt/la-toolkit-kb/data/chromadb/")

chroma_client: chromadb.PersistentClient = None  # set on startup


@asynccontextmanager
async def lifespan(app: FastAPI):
    global chroma_client
    chroma_client = chromadb.PersistentClient(path=CHROMA_PATH)
    yield


app = FastAPI(title="Living Atlas KB API", lifespan=lifespan)


class QueryRequest(BaseModel):
    question: str
    collection: str = "la_toolkit_kb"
    n_results: int = Field(default=5, ge=1, le=10)


class QueryResult(BaseModel):
    content: str
    metadata: dict
    relevance: float


class QueryResponse(BaseModel):
    results: list[QueryResult]


class CollectionInfo(BaseModel):
    name: str
    count: int


class CollectionsResponse(BaseModel):
    collections: list[CollectionInfo]


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/api/query", response_model=QueryResponse)
def query(req: QueryRequest):
    try:
        col = chroma_client.get_collection(req.collection)
    except Exception:
        raise HTTPException(status_code=404, detail=f"Collection '{req.collection}' not found")

    results = col.query(
        query_texts=[req.question],
        n_results=req.n_results,
        include=["documents", "metadatas", "distances"],
    )

    items = []
    for doc, meta, dist in zip(
        results["documents"][0],
        results["metadatas"][0],
        results["distances"][0],
    ):
        items.append(QueryResult(
            content=doc[:3000],
            metadata=meta,
            relevance=round(1 - dist, 3),
        ))

    return QueryResponse(results=items)


@app.get("/api/collections", response_model=CollectionsResponse)
def list_collections():
    cols = chroma_client.list_collections()
    return CollectionsResponse(collections=[
        CollectionInfo(name=c.name, count=c.count()) for c in cols
    ])
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
venv/bin/pytest tests/test_api.py -v
```

Expected: all 8 tests PASS

- [ ] **Step 5: Verify API runs locally (optional manual check)**

```bash
CHROMA_PATH=/opt/la-toolkit-kb/data/chromadb/ venv/bin/uvicorn server.api:app --port 8080
# In another terminal:
curl -s http://localhost:8080/health | python3 -m json.tool
curl -s -X POST http://localhost:8080/api/query \
  -H "Content-Type: application/json" \
  -d '{"question":"collectory database","n_results":2}' | python3 -m json.tool
```

- [ ] **Step 6: Commit**

```bash
git add server/api.py tests/test_api.py
git commit -m "feat(api): add FastAPI REST service for KB queries"
```

---

### Task 3: MCP HTTP server (streamable-HTTP transport)

**Files:**
- Create: `server/mcp_http.py`
- Create: `tests/test_mcp_tools.py`

- [ ] **Step 1: Write failing tests for MCP tool logic**

Create `tests/test_mcp_tools.py`:

```python
import pytest
import json
from unittest.mock import AsyncMock, patch, MagicMock
import httpx


# We test the tool handler functions directly, not the MCP transport layer
# The handlers call the REST API via httpx

@pytest.fixture
def mock_httpx_client():
    client = AsyncMock(spec=httpx.AsyncClient)
    return client


@pytest.mark.asyncio
async def test_query_tool_formats_results(mock_httpx_client):
    mock_httpx_client.post.return_value = MagicMock(
        status_code=200,
        json=lambda: {
            "results": [
                {
                    "content": "grails { ... }",
                    "metadata": {"repo": "collectory", "file": "conf/app.groovy", "chunk": 0},
                    "relevance": 0.7,
                }
            ]
        }
    )

    from server.mcp_http import handle_query
    result = await handle_query(
        {"question": "collectory config", "collection": "la_toolkit_kb", "n_results": 1},
        http_client=mock_httpx_client,
    )

    assert "collectory/conf/app.groovy" in result
    assert "relevance: 0.7" in result
    assert "grails { ... }" in result


@pytest.mark.asyncio
async def test_query_tool_handles_api_error(mock_httpx_client):
    mock_httpx_client.post.return_value = MagicMock(
        status_code=404,
        json=lambda: {"detail": "Collection not found"},
    )

    from server.mcp_http import handle_query
    result = await handle_query(
        {"question": "test", "collection": "nonexistent"},
        http_client=mock_httpx_client,
    )

    assert "Error" in result


@pytest.mark.asyncio
async def test_list_collections_tool(mock_httpx_client):
    mock_httpx_client.get.return_value = MagicMock(
        status_code=200,
        json=lambda: {
            "collections": [
                {"name": "la_toolkit_kb", "count": 3671},
                {"name": "la-toolkit-tier1", "count": 858},
            ]
        }
    )

    from server.mcp_http import handle_list_collections
    result = await handle_list_collections({}, http_client=mock_httpx_client)

    assert "la_toolkit_kb" in result
    assert "3671" in result
```

- [ ] **Step 2: Run tests — verify they fail**

```bash
venv/bin/pytest tests/test_mcp_tools.py -v
```

Expected: `ImportError: cannot import name 'handle_query' from 'server.mcp_http'`

- [ ] **Step 3: Implement `server/mcp_http.py`**

```python
"""MCP streamable-HTTP server for Living Atlas KB (public, remote access)."""

import os
from typing import Any

import httpx
from mcp.server import Server
from mcp.server.streamable_http import streamablehttp_server
from mcp.types import Tool, TextContent

REST_API_URL = os.environ.get("KB_API_URL", "http://localhost:8080")

app = Server("living-atlas-kb")


async def handle_query(arguments: dict, http_client: httpx.AsyncClient = None) -> str:
    """Query the KB via REST API and return formatted markdown."""
    if http_client is None:
        http_client = httpx.AsyncClient()

    question = arguments["question"]
    collection = arguments.get("collection", "la_toolkit_kb")
    n_results = min(arguments.get("n_results", 5), 10)

    response = http_client.post(
        f"{REST_API_URL}/api/query",
        json={"question": question, "collection": collection, "n_results": n_results},
        timeout=30,
    )

    if hasattr(response, "__await__"):
        response = await response

    if response.status_code != 200:
        return f"Error querying KB: {response.status_code} — {response.json().get('detail', 'unknown error')}"

    results = response.json()["results"]
    if not results:
        return "No results found."

    lines = [f"# ALA KB Results for: {question}\n"]
    for i, r in enumerate(results, 1):
        meta = r["metadata"]
        repo = meta.get("repo", "unknown")
        file_path = meta.get("file", "")
        relevance = r["relevance"]
        lines.append(f"## Result {i} — `{repo}/{file_path}` (relevance: {relevance})")
        lines.append(f"```\n{r['content']}\n```\n")

    return "\n".join(lines)


async def handle_list_collections(arguments: dict, http_client: httpx.AsyncClient = None) -> str:
    """List KB collections via REST API."""
    if http_client is None:
        http_client = httpx.AsyncClient()

    response = http_client.get(f"{REST_API_URL}/api/collections", timeout=10)
    if hasattr(response, "__await__"):
        response = await response

    if response.status_code != 200:
        return f"Error: {response.status_code}"

    cols = response.json()["collections"]
    lines = ["# Living Atlas KB Collections\n"]
    for c in cols:
        lines.append(f"- **{c['name']}**: {c['count']} documents")
    return "\n".join(lines)


@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="query_ala_kb",
            description=(
                "Query the Living Atlas / ALA Knowledge Base. "
                "Contains documentation, code, and configuration from ALA/GBIF repositories: "
                "ala-install, la-toolkit, gbif-pipelines, collectory, biocache-service, "
                "biocache-hubs, ala-bie-hub, spatial-hub, image-service, species-lists. "
                "Use for questions about Living Atlas deployment, configuration, troubleshooting."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "question": {"type": "string", "description": "Search query"},
                    "collection": {
                        "type": "string",
                        "enum": ["la_toolkit_kb", "la-toolkit-tier1"],
                        "default": "la_toolkit_kb",
                        "description": "la_toolkit_kb (3671 docs, all services) or la-toolkit-tier1 (858 docs, ala-install+la-toolkit+gbif-pipelines)",
                    },
                    "n_results": {
                        "type": "integer",
                        "default": 5,
                        "minimum": 1,
                        "maximum": 10,
                    },
                },
                "required": ["question"],
            },
        ),
        Tool(
            name="list_ala_kb_collections",
            description="List available collections in the Living Atlas KB with document counts.",
            inputSchema={"type": "object", "properties": {}},
        ),
    ]


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    async with httpx.AsyncClient() as client:
        if name == "query_ala_kb":
            text = await handle_query(arguments, http_client=client)
        elif name == "list_ala_kb_collections":
            text = await handle_list_collections(arguments, http_client=client)
        else:
            text = f"Unknown tool: {name}"
    return [TextContent(type="text", text=text)]


if __name__ == "__main__":
    import asyncio

    async def main():
        async with streamablehttp_server() as (read_stream, write_stream, _):
            await app.run(read_stream, write_stream, app.create_initialization_options())

    asyncio.run(main())
```

- [ ] **Step 4: Run tests — verify they pass**

```bash
venv/bin/pip install pytest-asyncio
venv/bin/pytest tests/test_mcp_tools.py -v
```

Expected: all 3 tests PASS

- [ ] **Step 5: Commit**

```bash
git add server/mcp_http.py tests/test_mcp_tools.py
git commit -m "feat(mcp): add streamable-HTTP MCP server"
```

---

### Task 4: Refactor stdio MCP server to use REST API

**Files:**
- Create: `server/mcp_stdio.py` (replaces `~/mcp-servers/ala-kb/server.py`)

- [ ] **Step 1: Create `server/mcp_stdio.py`**

```python
"""MCP stdio server — local use via SSH. Calls REST API on localhost."""

import os
import asyncio
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent
import httpx

# When running locally on the server, REST API is on localhost
REST_API_URL = os.environ.get("KB_API_URL", "http://localhost:8080")

# Re-use handler functions from mcp_http
from server.mcp_http import handle_query, handle_list_collections, list_tools  # noqa: E402

app = Server("living-atlas-kb-local")
app.list_tools()(list_tools)


@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    async with httpx.AsyncClient() as client:
        if name == "query_ala_kb":
            text = await handle_query(arguments, http_client=client)
        elif name == "list_ala_kb_collections":
            text = await handle_list_collections(arguments, http_client=client)
        else:
            text = f"Unknown tool: {name}"
    return [TextContent(type="text", text=text)]


async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
```

- [ ] **Step 2: Verify existing local MCP server still works (end-to-end on server)**

SSH to server:
```bash
ssh la-toolkit-kb-dev-2026
cd /opt/la-toolkit-kb
# Start REST API in background
source venv/bin/activate
uvicorn server.api:app --port 8080 &
# Test via stdio server
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"0.1"}}}' \
  | python3 server/mcp_stdio.py
```

Expected: JSON response with `"serverInfo":{"name":"living-atlas-kb-local",...}`

- [ ] **Step 3: Commit**

```bash
git add server/mcp_stdio.py
git commit -m "feat(mcp): add stdio server using REST API backend"
```

---

### Task 5: GitHub Actions CI

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create `.github/workflows/ci.yml`**

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.11"

      - name: Install dependencies
        run: |
          pip install -r server/requirements.txt
          pip install pytest pytest-asyncio

      - name: Run tests
        run: pytest tests/ -v
```

- [ ] **Step 2: Commit and push**

```bash
git add .github/
git commit -m "ci: add GitHub Actions test workflow"
git remote add origin git@github.com:living-atlases/living-atlas-kb.git
git push -u origin main
```

- [ ] **Step 3: Verify CI passes on GitHub**

Open `https://github.com/living-atlases/living-atlas-kb/actions` — green check on first run.

---

### Task 6: Ansible deploy playbook

**Files:**
- Create: `ansible/deploy.yml` — deploy REST API + MCP services + nginx
- Create: `ansible/setup_kb.yml` — full VM setup + indexing (adapted from original `la-toolkit-kb-setup.yml`)
- Create: `ansible/repos_tier1.yml` — repo config for KB indexer (Tier 1)
- Create: `ansible/repos_tier2.yml` — repo config for KB indexer (Tier 2, extended with more ALA/GBIF repos)

---

- [ ] **Step 1: Create `ansible/repos_tier1.yml`**

```yaml
# Living Atlas KB - Tier 1 Repositories
# Updated: Daily at 2:00 AM
# Priority: CRITICAL — most-used, actively maintained

repos:
  - name: ala-install
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/ala-install.git
    branch: master
    patterns:
      - "**/*.md"
      - "ansible/roles/*/tasks/*.yml"
      - "ansible/roles/*/defaults/*.yml"
      - "ansible/roles/*/templates/*"
      - "ansible/group_vars/**/*.yml"
    description: "Ansible roles and playbooks for deploying LA services"

  - name: la-toolkit
    org: living-atlases
    url: https://github.com/living-atlases/la-toolkit.git
    branch: main
    patterns:
      - "**/*.md"
      - "lib/**/*.dart"
      - "api/**/*.js"
      - "config/**/*.js"
    description: "LA Toolkit: conversational project configuration"

  - name: gbif-pipelines
    org: gbif
    url: https://github.com/gbif/pipelines.git
    branch: master
    patterns:
      - "**/*.md"
      - "livingatlas/**/*.java"
      - "**/*.properties"
      - "**/*.yml"
    description: "GBIF Pipelines: DarwinCore data processing (livingatlas module)"
```

- [ ] **Step 2: Create `ansible/repos_tier2.yml`**

```yaml
# Living Atlas KB - Tier 2 Repositories
# Updated: Weekly (Sundays) at 3:00 AM
# Priority: HIGH — full LA ecosystem coverage
# Repos sourced from: la-docker-compose/roles/la-compose/vars/docker-services-desc.yaml

repos:
  - name: collectory
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/collectory.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
      - "grails-app/controllers/**/*.groovy"
      - "src/main/resources/**/*.properties"
      - "grails-app/migrations/**/*.groovy"
    description: "Biodiversity collections registry"

  - name: biocache-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/biocache-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
      - "grails-app/controllers/**/*.groovy"
      - "src/main/resources/**/*.properties"
    description: "Occurrence records service"

  - name: biocache-hubs
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/biocache-hubs.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
      - "grails-app/views/**/*.gsp"
    description: "Occurrence hub web app"

  - name: ala-bie-hub
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/ala-bie-hub.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
      - "grails-app/controllers/**/*.groovy"
    description: "Biodiversity Information Explorer hub"

  - name: bie-index
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/bie-index.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "BIE species index service"

  - name: image-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/image-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
      - "grails-app/controllers/**/*.groovy"
    description: "Image management service"

  - name: specieslist-webapp
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/specieslist-webapp.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "Species lists web app (legacy)"

  - name: species-lists
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/species-lists.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "Species lists service (new)"

  - name: spatial-hub
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/spatial-hub.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "Spatial analysis hub"

  - name: spatial-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/spatial-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.groovy"
    description: "Spatial analysis service"

  - name: regions
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/regions.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "Regions management service"

  - name: logger-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/logger-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.groovy"
    description: "Event logging service"

  - name: ala-namematching-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/ala-namematching-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.java"
      - "src/**/*.yml"
    description: "Taxonomic name matching service"

  - name: ala-sensitive-data-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/ala-sensitive-data-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.java"
      - "src/**/*.yml"
    description: "Sensitive data service"

  - name: dashboard
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/dashboard.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "LA Dashboard service"

  - name: alerts
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/alerts.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.groovy"
    description: "User alerts service"

  - name: doi-service
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/doi-service.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.groovy"
    description: "DOI minting service"

  - name: userdetails
    org: AtlasOfLivingAustralia
    url: https://github.com/AtlasOfLivingAustralia/userdetails.git
    branch: master
    patterns:
      - "**/*.md"
      - "grails-app/conf/**/*.groovy"
    description: "User management service"

  - name: base-branding
    org: living-atlases
    url: https://github.com/living-atlases/base-branding.git
    branch: master
    patterns:
      - "**/*.md"
      - "**/*.yml"
    description: "LA base branding and theming"

  # ── GBIF public community repos ───────────────────────────────────────────

  - name: ipt
    org: gbif
    url: https://github.com/gbif/ipt.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/main/resources/**/*.properties"
      - "src/main/webapp/WEB-INF/**/*.xml"
      - "**/*.yml"
    description: "GBIF Integrated Publishing Toolkit — DarwinCore data publishing"

  - name: gbif-api
    org: gbif
    url: https://github.com/gbif/gbif-api.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/main/java/**/*.java"
    description: "GBIF public Java API model — shared types/enums used by all GBIF services"

  - name: dwca-validator
    org: gbif
    url: https://github.com/gbif/dwca-validator.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.java"
    description: "Darwin Core Archive validator"

  - name: dwca-io
    org: gbif
    url: https://github.com/gbif/dwca-io.git
    branch: master
    patterns:
      - "**/*.md"
      - "src/**/*.java"
    description: "Darwin Core Archive reader/writer library"

  - name: occurrence
    org: gbif
    url: https://github.com/gbif/occurrence.git
    branch: master
    patterns:
      - "**/*.md"
      - "occurrence-*/**/*.java"
      - "**/*.properties"
      - "**/*.yml"
    description: "GBIF occurrence processing and download service"

  - name: registry
    org: gbif
    url: https://github.com/gbif/registry.git
    branch: master
    patterns:
      - "**/*.md"
      - "registry-*/**/*.java"
      - "**/*.yml"
    description: "GBIF registry of datasets, organizations, nodes, installations"

  - name: checklistbank
    org: gbif
    url: https://github.com/gbif/checklistbank.git
    branch: master
    patterns:
      - "**/*.md"
      - "checklistbank-*/**/*.java"
      - "**/*.yml"
    description: "GBIF ChecklistBank — taxonomic checklist storage and API"
```

- [ ] **Step 3: Create `ansible/setup_kb.yml`**

> Full VM setup + indexing playbook. Adapted from original `la-toolkit-kb-setup.yml`.
> Run once on a fresh VM, or to re-index. For service deploy only, use `deploy.yml`.

```yaml
---
# Living Atlas Knowledge Base - VM Setup & Indexing
# Adapted from la-toolkit-kb-setup.yml (prod-gbif-es-ansible-extras)
#
# Usage:
#   Full setup + tier1:
#     ansible-playbook ansible/setup_kb.yml -i inventory.ini
#   Full setup + tier1 + tier2:
#     ansible-playbook ansible/setup_kb.yml -i inventory.ini -e "index_tier2=true"
#   Re-index only (skip setup phases):
#     ansible-playbook ansible/setup_kb.yml -i inventory.ini --tags reindex

- name: Living Atlas KB - VM Setup & Indexing
  hosts: kb
  become: true
  vars:
    kb_home: /opt/la-toolkit-kb
    kb_user: ubuntu
    chroma_path: /opt/la-toolkit-kb/data/chromadb/
    index_tier2: false   # override: -e "index_tier2=true"

  tasks:

    # ── Phase 1: System dependencies ─────────────────────────────────────────

    - name: "Phase 1: Update apt cache"
      ansible.builtin.apt:
        update_cache: true
        cache_valid_time: 3600

    - name: Install system packages
      ansible.builtin.apt:
        name:
          - python3-pip
          - python3-dev
          - python3-venv
          - build-essential
          - git
          - curl
          - rsync
          - nginx
          - certbot
          - python3-certbot-nginx
        state: present

    # ── Phase 2: Directory structure ──────────────────────────────────────────

    - name: "Phase 2: Create directory structure"
      ansible.builtin.file:
        path: "{{ item }}"
        state: directory
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0755"
      loop:
        - "{{ kb_home }}"
        - "{{ kb_home }}/config"
        - "{{ kb_home }}/repos"
        - "{{ kb_home }}/scripts"
        - "{{ kb_home }}/server"
        - "{{ kb_home }}/data"
        - "{{ kb_home }}/data/chromadb"
        - "{{ kb_home }}/logs"

    # ── Phase 3: Python venv ──────────────────────────────────────────────────

    - name: "Phase 3: Create Python venv"
      ansible.builtin.command:
        cmd: "python3 -m venv {{ kb_home }}/venv"
        creates: "{{ kb_home }}/venv/bin/python"
      become_user: "{{ kb_user }}"

    - name: Upgrade pip in venv
      ansible.builtin.command:
        cmd: "{{ kb_home }}/venv/bin/pip install --upgrade pip setuptools wheel"
      become_user: "{{ kb_user }}"
      changed_when: false

    # ── Phase 4: Python dependencies ─────────────────────────────────────────

    - name: "Phase 4: Install Python libraries in venv"
      ansible.builtin.pip:
        name:
          - sentence-transformers>=3.0
          - chromadb>=0.5
          - fastapi>=0.115
          - "uvicorn[standard]>=0.30"
          - "mcp>=1.27"
          - httpx>=0.27
          - pydantic>=2.0
          - gitpython>=3.1
          - pyyaml>=6.0
        state: present
        virtualenv: "{{ kb_home }}/venv"
      become_user: "{{ kb_user }}"

    # ── Phase 5: Repo configs ─────────────────────────────────────────────────

    - name: "Phase 5: Copy tier1 repos config"
      ansible.builtin.copy:
        src: repos_tier1.yml
        dest: "{{ kb_home }}/config/repos_tier1.yml"
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0644"

    - name: Copy tier2 repos config
      ansible.builtin.copy:
        src: repos_tier2.yml
        dest: "{{ kb_home }}/config/repos_tier2.yml"
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0644"

    # ── Phase 6: Server files ─────────────────────────────────────────────────

    - name: "Phase 6: Copy server files"
      ansible.builtin.copy:
        src: "{{ item }}"
        dest: "{{ kb_home }}/server/"
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0644"
      loop:
        - ../server/__init__.py
        - ../server/api.py
        - ../server/mcp_http.py
        - ../server/mcp_stdio.py

    # ── Phase 7: KB indexer script ────────────────────────────────────────────

    - name: "Phase 7: Install kb_indexer.py"
      ansible.builtin.copy:
        src: kb_indexer.py
        dest: "{{ kb_home }}/scripts/kb_indexer.py"
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0755"

    # ── Phase 8: Index KB ─────────────────────────────────────────────────────

    - name: "Phase 8: Index Tier 1 repos"
      ansible.builtin.shell: |
        source {{ kb_home }}/venv/bin/activate
        cd {{ kb_home }}
        python3 scripts/kb_indexer.py tier1
      become_user: "{{ kb_user }}"
      timeout: 3600
      tags: [reindex, reindex_tier1]

    - name: "Index Tier 2 repos (optional)"
      ansible.builtin.shell: |
        source {{ kb_home }}/venv/bin/activate
        cd {{ kb_home }}
        python3 scripts/kb_indexer.py tier2
      become_user: "{{ kb_user }}"
      timeout: 10800
      when: index_tier2 | bool
      tags: [reindex, reindex_tier2]

    # ── Phase 9: Cron jobs ────────────────────────────────────────────────────

    - name: "Phase 9: Configure cron jobs"
      ansible.builtin.copy:
        dest: /etc/cron.d/la-toolkit-kb
        mode: "0644"
        content: |
          # Living Atlas KB maintenance jobs
          # Tier 1: Daily at 02:00 (ala-install, la-toolkit, gbif-pipelines)
          0 2 * * * {{ kb_user }} source {{ kb_home }}/venv/bin/activate && python3 {{ kb_home }}/scripts/kb_indexer.py tier1 >> {{ kb_home }}/logs/cron_tier1.log 2>&1
          # Tier 2: Weekly Sunday at 03:00 (all LA/GBIF service repos)
          0 3 * * 0 {{ kb_user }} source {{ kb_home }}/venv/bin/activate && python3 {{ kb_home }}/scripts/kb_indexer.py tier2 >> {{ kb_home }}/logs/cron_tier2.log 2>&1

    # ── Phase 10: Systemd services ────────────────────────────────────────────

    - name: "Phase 10: Create systemd service for REST API"
      ansible.builtin.copy:
        dest: /etc/systemd/system/la-toolkit-kb-api.service
        mode: "0644"
        content: |
          [Unit]
          Description=Living Atlas KB REST API
          After=network.target

          [Service]
          User={{ kb_user }}
          WorkingDirectory={{ kb_home }}
          Environment=CHROMA_PATH={{ chroma_path }}
          ExecStart={{ kb_home }}/venv/bin/python -m uvicorn server.api:app --host 127.0.0.1 --port 8080
          Restart=always
          RestartSec=5

          [Install]
          WantedBy=multi-user.target

    - name: Create systemd service for MCP HTTP server
      ansible.builtin.copy:
        dest: /etc/systemd/system/la-toolkit-kb-mcp.service
        mode: "0644"
        content: |
          [Unit]
          Description=Living Atlas KB MCP HTTP Server
          After=la-toolkit-kb-api.service

          [Service]
          User={{ kb_user }}
          WorkingDirectory={{ kb_home }}
          Environment=KB_API_URL=http://localhost:8080
          ExecStart={{ kb_home }}/venv/bin/python server/mcp_http.py
          Restart=always
          RestartSec=5

          [Install]
          WantedBy=multi-user.target

    - name: Enable and start services
      ansible.builtin.systemd:
        name: "{{ item }}"
        enabled: true
        state: restarted
        daemon_reload: true
      loop:
        - la-toolkit-kb-api
        - la-toolkit-kb-mcp

    # ── Phase 10b: Intro page ─────────────────────────────────────────────────

    - name: Create web root directory
      ansible.builtin.file:
        path: /var/www/la-toolkit-kb
        state: directory
        owner: www-data
        group: www-data
        mode: "0755"

    - name: Create intro index.html
      ansible.builtin.copy:
        dest: /var/www/la-toolkit-kb/index.html
        owner: www-data
        group: www-data
        mode: "0644"
        content: |
          <!DOCTYPE html>
          <html lang="en">
          <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Living Atlas Knowledge Base</title>
            <style>
              body { font-family: system-ui, sans-serif; max-width: 720px; margin: 3rem auto; padding: 0 1rem; color: #222; }
              h1 { color: #1a6c37; }
              a { color: #1a6c37; }
              code { background: #f4f4f4; padding: 0.15em 0.4em; border-radius: 3px; font-size: 0.9em; }
              .endpoints { border-collapse: collapse; width: 100%; }
              .endpoints th, .endpoints td { text-align: left; padding: 0.5rem 0.75rem; border-bottom: 1px solid #ddd; }
              .endpoints th { background: #f0f8f2; }
            </style>
          </head>
          <body>
            <h1>Living Atlas Knowledge Base</h1>
            <p>
              Semantic search API and MCP server over the
              <a href="https://github.com/living-atlases">Living Atlases</a> /
              <a href="https://github.com/gbif">GBIF</a> documentation corpus.
            </p>

            <h2>Endpoints</h2>
            <table class="endpoints">
              <tr><th>URL</th><th>Description</th></tr>
              <tr><td><a href="/api/docs"><code>/api/docs</code></a></td><td>Interactive REST API (Swagger UI)</td></tr>
              <tr><td><code>/api/query</code></td><td>Semantic search — POST <code>{"question":"…","n_results":5}</code></td></tr>
              <tr><td><code>/api/collections</code></td><td>List indexed collections</td></tr>
              <tr><td><code>/health</code></td><td>Health check</td></tr>
              <tr><td><code>/mcp</code></td><td>MCP streamable-HTTP for AI agents</td></tr>
            </table>

            <h2>Usage example</h2>
            <pre><code>curl -s https://kb.l-a.site/api/query \
              -H 'Content-Type: application/json' \
              -d '{"question":"How to configure biocache-service?","n_results":3}' | jq .</code></pre>

            <h2>Source</h2>
            <p><a href="https://github.com/living-atlases/living-atlas-kb">github.com/living-atlases/living-atlas-kb</a></p>
          </body>
          </html>

    # ── Phase 11: nginx + TLS ─────────────────────────────────────────────────

    - name: "Phase 11: Configure nginx"
      ansible.builtin.copy:
        dest: /etc/nginx/sites-available/la-toolkit-kb
        mode: "0644"
        content: |
          server {
              listen 443 ssl;
              server_name kb.l-a.site;

              ssl_certificate /etc/letsencrypt/live/kb.l-a.site/fullchain.pem;
              ssl_certificate_key /etc/letsencrypt/live/kb.l-a.site/privkey.pem;

              location /api/ {
                  proxy_pass http://127.0.0.1:8080;
                  proxy_set_header Host $host;
                  proxy_set_header X-Real-IP $remote_addr;
              }

              location /mcp {
                  proxy_pass http://127.0.0.1:3000;
                  proxy_set_header Host $host;
                  proxy_set_header Connection "";
                  proxy_http_version 1.1;
                  proxy_buffering off;
              }

              location /health {
                  proxy_pass http://127.0.0.1:8080;
              }

              root /var/www/la-toolkit-kb;
              index index.html;

              location / {
                  try_files $uri $uri/ =404;
              }
          }

          server {
              listen 80;
              server_name kb.l-a.site;
              return 301 https://$host$request_uri;
          }

    - name: Enable nginx site
      ansible.builtin.file:
        src: /etc/nginx/sites-available/la-toolkit-kb
        dest: /etc/nginx/sites-enabled/la-toolkit-kb
        state: link

    - name: Reload nginx
      ansible.builtin.service:
        name: nginx
        state: reloaded
```

- [ ] **Step 4: Create `ansible/deploy.yml`** (service-only, no indexing)

```yaml
---
# Living Atlas KB - Deploy services only (no indexing)
# Use when ChromaDB is already populated and you only want to
# update/restart the REST API and MCP HTTP server.
#
# Usage:
#   ansible-playbook ansible/deploy.yml -i inventory.ini

- name: Deploy living-atlas-kb API and MCP services
  hosts: kb
  become: true
  vars:
    kb_home: /opt/la-toolkit-kb
    kb_user: ubuntu

  tasks:
    - name: Copy server files
      ansible.builtin.copy:
        src: "{{ item }}"
        dest: "{{ kb_home }}/server/"
        owner: "{{ kb_user }}"
        group: "{{ kb_user }}"
        mode: "0644"
      loop:
        - ../server/__init__.py
        - ../server/api.py
        - ../server/mcp_http.py
        - ../server/mcp_stdio.py

    - name: Install/update server Python dependencies
      ansible.builtin.pip:
        name:
          - fastapi>=0.115
          - "uvicorn[standard]>=0.30"
          - chromadb>=0.5
          - sentence-transformers>=3.0
          - "mcp>=1.27"
          - httpx>=0.27
          - pydantic>=2.0
        state: present
        virtualenv: "{{ kb_home }}/venv"
      become_user: "{{ kb_user }}"

    - name: Restart REST API service
      ansible.builtin.systemd:
        name: la-toolkit-kb-api
        state: restarted
        daemon_reload: true

    - name: Restart MCP HTTP service
      ansible.builtin.systemd:
        name: la-toolkit-kb-mcp
        state: restarted
```

- [ ] **Step 5: Run full setup (first time)**

```bash
# Prerequisites: DNS kb.l-a.site → IP of la-toolkit-kb-dev-2026
# Run certbot BEFORE this playbook:
#   ssh kb 'certbot certonly --nginx -d kb.l-a.site'

ansible-playbook ansible/setup_kb.yml -i inventory.ini
# With tier2:
ansible-playbook ansible/setup_kb.yml -i inventory.ini -e "index_tier2=true"
```

- [ ] **Step 6: Verify public endpoints**

```bash
curl -s https://kb.l-a.site/health | python3 -m json.tool
# Expected: {"status": "ok"}

curl -s https://kb.l-a.site/api/collections | python3 -m json.tool
# Expected: {"collections": [{"name": "la_toolkit_kb", ...}, ...]}

curl -s -X POST https://kb.l-a.site/api/query \
  -H "Content-Type: application/json" \
  -d '{"question": "collectory database configuration", "n_results": 2}' \
  | python3 -m json.tool
```

- [ ] **Step 7: Test MCP from OpenCode (remote config)**

Add to `~/.config/opencode/opencode.json`:
```json
"ala-kb-remote": {
  "type": "remote",
  "url": "https://kb.l-a.site/mcp"
}
```

Open OpenCode → "list ala kb collections" — returns collections without SSH.

- [ ] **Step 8: Commit**

```bash
git add ansible/
git commit -m "feat(deploy): add setup + deploy ansible playbooks with full repo list"
```

---

## Self-Review

- **Spec coverage:** ✅ FastAPI REST, ✅ MCP HTTP, ✅ MCP stdio refactored, ✅ Ansible deploy, ✅ CI. Missing from this plan (separate plans): indexer improvements (chunking, webhook), GitHub Pages docs.
- **Placeholder scan:** No TBDs. Ansible playbook assumes Let's Encrypt cert already provisioned — add note: run certbot before deploy.
- **Type consistency:** `handle_query` / `handle_list_collections` defined in `mcp_http.py` and imported in `mcp_stdio.py` — consistent.
- **Note:** `streamablehttp_server` import in `mcp_http.py` — verify exact import path for mcp 1.27 before running (`from mcp.server.streamable_http import streamablehttp_server`).

---

**Prerequisites before Task 6:**
1. DNS: `kb.l-a.site` → IP of `la-toolkit-kb-dev-2026`
2. TLS cert: `certbot certonly --nginx -d kb.l-a.site` on the server
