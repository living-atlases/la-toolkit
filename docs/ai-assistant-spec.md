# LA Toolkit AI Assistant - Specification v0.1

**Status**: DRAFT - Under active development  
**Last Updated**: 2026-03-14  
**Maintainer**: Claude (OpenCode session memory)  
**Repository**: https://github.com/living-atlases/la-toolkit

---

## 1. Vision & Goals

### 1.1 Purpose
Provide intelligent, context-aware assistance for deploying and maintaining Living Atlas portals throughout their lifecycle, leveraging real-time knowledge from ALA/GBIF codebases.

### 1.2 Core Principles
- **Code as Source of Truth**: Knowledge extracted from active repositories, not static docs
- **Prevent > Cure**: Proactively warn about common pitfalls before they occur
- **Progressive Complexity**: Guide users from minimal deployments to full production
- **No Guessing**: AI admits uncertainty and points to documentation when needed

### 1.3 Non-Goals
- Replace human DevOps expertise
- Automatically execute destructive operations
- Support deprecated deployment methods (e.g., obsolete service versions)

---

## 2. Knowledge Base Architecture

### 2.1 Primary Sources (Priority Order)

**Tier 1: Deployment & Configuration**
- `ala-install` - Ansible playbooks, roles, variables (including new docker-compose support)
- `la-toolkit` - This application's own codebase and configs
- GBIF `pipelines` - Data processing workflows

**Tier 2: Core Services**
- `collectory` - Metadata management
- `biocache-hubs` - Occurrence data UI
- `ala-bie-hub` - Species pages
- `ala-cas-5` - Authentication (CAS-5 is current, CAS-2 is deprecated)
- `logger-service` - Event logging
- `image-service` - Media management
- `spatial-hub` + `spatial-service` - Spatial analysis

**Tier 3: Supporting Services**
- `userdetails` + `apikey` - User/API management
- `alerts` - User notifications
- `doi-service` - DOI minting
- `dashboard` - Portal analytics
- `regions` - Geographic regions
- `species-lists` - Species list management
- `ala-namematching-service` - Taxonomic matching
- `ala-sensitive-data-service` - Data obfuscation

**Tier 4: Specialized**
- `biocollect` + `ecodata` - Citizen science projects
- `volunteer-portal` - Crowdsourcing transcription

### 2.2 Processing Strategy

**Code Analysis Pipeline**:
1. **Repository Monitoring**: Track commits to main branches of Tier 1-3 repos
2. **Documentation Extraction**: 
   - README files
   - Configuration examples (inventory files, docker-compose.yml)
   - Inline code comments
   - Service dependencies (package.json, build.gradle, requirements.txt)
3. **Structured Indexing**:
   - Service configurations → searchable parameters
   - Error patterns → diagnostic knowledge
   - Deployment order → dependency graph
4. **Wiki Integration**: Link structured code knowledge to narrative docs

**Update Frequency**:
- Tier 1: Weekly (deployment automation changes frequently)
- Tier 2: Bi-weekly
- Tier 3-4: Monthly

**Deprecation Handling**:
- Mark deprecated repos/methods in knowledge base
- Warn users attempting to use outdated approaches
- Redirect to current alternatives

### 2.3 Knowledge Base Schema (Draft)

```json
{
  "services": [
    {
      "name": "collectory",
      "repo": "https://github.com/AtlasOfLivingAustralia/collectory",
      "deployment_methods": ["ansible", "docker-compose"],
      "dependencies": ["mysql", "tomcat"],
      "config_variables": [
        {"name": "collectory.db.host", "required": true, "default": "localhost"},
        ...
      ],
      "common_errors": [
        {
          "pattern": "Unable to connect to MySQL",
          "causes": ["firewall", "incorrect credentials", "service not running"],
          "diagnostic_steps": ["check mysql status", "test network connectivity"],
          "wiki_reference": "Troubleshooting#collectory-database-connection"
        }
      ]
    }
  ]
}
```

### 2.4 Knowledge Base Processing - Technical Details

This section describes the concrete implementation strategy for extracting, processing, and indexing knowledge from ALA/GBIF repositories.

---

#### 2.4.1 Repository Crawler

**Purpose**: Periodically clone/pull repositories and extract documentation

**Implementation**:
```javascript
// api/services/RepositoryIndexer.js (Sails backend)

const REPOS = [
  // Tier 1
  { org: 'living-atlases', name: 'ala-install', tier: 1, branches: ['master', 'dev'] },
  { org: 'living-atlases', name: 'la-toolkit', tier: 1, branches: ['main'] },
  { org: 'gbif', name: 'pipelines', tier: 1, branches: ['dev'] },
  
  // Tier 2
  { org: 'AtlasOfLivingAustralia', name: 'collectory', tier: 2, branches: ['master'] },
  { org: 'AtlasOfLivingAustralia', name: 'biocache-hubs', tier: 2, branches: ['master'] },
  // ... etc
];

class RepositoryIndexer {
  async indexRepository(repo) {
    const repoPath = await this.cloneOrPull(repo);
    const documents = await this.extractDocuments(repoPath, repo);
    const chunks = await this.chunkDocuments(documents);
    const embeddings = await this.generateEmbeddings(chunks);
    await this.storeInVectorDB(embeddings, chunks, repo);
  }
  
  async extractDocuments(repoPath, repo) {
    // Extract multiple document types
    return [
      ...await this.extractMarkdown(repoPath),     // READMEs, docs/*.md
      ...await this.extractConfigs(repoPath, repo), // ansible vars, docker-compose.yml
      ...await this.extractCodeComments(repoPath),  // Source code docstrings
      ...await this.extractDependencies(repoPath)   // requirements.txt, package.json
    ];
  }
}
```

**Extraction Patterns**:

1. **Markdown Documentation**:
   - `README.md`, `CONTRIBUTING.md`, `docs/**/*.md`
   - Parse headers as section boundaries
   - Extract code blocks separately (preserve syntax)

2. **Ansible Configuration** (ala-install):
   - `ansible/inventories/*/group_vars/**/*.yml`
   - `ansible/roles/*/defaults/main.yml`
   - Extract variables with descriptions from comments
   
   Example:
   ```yaml
   # Collectory database hostname
   collectory_db_host: localhost
   
   # Collectory database port (default: 3306 for MySQL)
   collectory_db_port: 3306
   ```
   → Indexed as: "collectory_db_host is the database hostname for Collectory, defaults to localhost"

3. **Docker Compose** (ala-install/docker):
   - `docker/docker-compose*.yml`
   - Extract service definitions, dependencies, environment variables
   - Map to deployment patterns

4. **Error Patterns** (from code):
   - Search for log statements: `log.error()`, `logger.error()`, `throw new Error()`
   - Extract error messages and surrounding context
   - Link to troubleshooting steps if available

5. **Wiki Links** (from code comments):
   - Pattern: `// See: https://github.com/AtlasOfLivingAustralia/documentation/wiki/...`
   - Create bidirectional links: code ↔ wiki

---

#### 2.4.2 Document Chunking Strategy

**Challenge**: Long documents must be split into retrievable chunks

**Strategy**:
```javascript
class DocumentChunker {
  chunkMarkdown(document) {
    // Split by headers (##, ###)
    const sections = this.splitByHeaders(document.content);
    
    return sections.map(section => ({
      text: section.content,
      metadata: {
        repo: document.repo,
        file: document.filePath,
        section: section.header,
        type: 'markdown',
        lineStart: section.lineStart,
        lineEnd: section.lineEnd
      }
    }));
  }
  
  chunkAnsibleVars(document) {
    // Each variable = one chunk
    const vars = this.parseYAML(document.content);
    
    return Object.entries(vars).map(([key, value]) => ({
      text: `${key}: ${JSON.stringify(value)}\n${this.extractComment(key)}`,
      metadata: {
        repo: document.repo,
        file: document.filePath,
        varName: key,
        type: 'ansible_var',
        service: this.inferService(document.filePath) // e.g., "collectory"
      }
    }));
  }
  
  chunkErrorPattern(document) {
    // Each error message = one chunk with rich context
    const errors = this.extractErrorStatements(document.content);
    
    return errors.map(error => ({
      text: `Error: ${error.message}\nContext: ${error.surroundingCode}`,
      metadata: {
        repo: document.repo,
        file: document.filePath,
        errorPattern: error.message,
        type: 'error_pattern',
        severity: error.severity // error, warning, info
      }
    }));
  }
}
```

**Chunking Rules**:
- **Max chunk size**: 1000 tokens (~750 words)
- **Overlap**: 100 tokens between adjacent chunks (preserve context)
- **Preserve**: Code blocks intact, don't split mid-sentence
- **Metadata**: Always include repo, file path, line numbers for source linking

---

#### 2.4.3 Embedding Generation

**Model Selection**:
- **Option 1** (Recommended): `sentence-transformers/all-MiniLM-L6-v2`
  - Fast (500 sentences/sec on CPU)
  - Good quality for semantic search
  - 384-dimensional embeddings
  - Small model (~80MB)
  
- **Option 2**: `intfloat/e5-base-v2`
  - Better quality, slower
  - 768-dimensional embeddings
  - Requires more storage

**Implementation**:
```javascript
const { SentenceTransformer } = require('sentence-transformers-js'); // Hypothetical - use Python service

class EmbeddingGenerator {
  constructor() {
    this.model = new SentenceTransformer('all-MiniLM-L6-v2');
  }
  
  async generateEmbedding(text) {
    // Preprocess
    const cleaned = this.preprocessText(text);
    
    // Generate embedding
    const embedding = await this.model.encode(cleaned);
    
    return embedding; // Float32Array of length 384
  }
  
  preprocessText(text) {
    // Remove excessive whitespace
    // Normalize code formatting
    // Truncate to model's max length (512 tokens)
    return text.trim().replace(/\s+/g, ' ').substring(0, 5000);
  }
}
```

**Batch Processing**:
- Process 32-128 chunks at once (GPU batch size)
- Store embeddings alongside metadata in vector DB

---

#### 2.4.4 Vector Database Schema

**Choice**: Start with **ChromaDB** (embedded, Python/JS clients)

**Collections Structure**:

```javascript
// Collection 1: Documentation chunks
const docsCollection = {
  name: 'ala_documentation',
  metadata: { description: 'Markdown docs from ALA repos' },
  schema: {
    id: 'uuid',                    // Unique chunk ID
    embedding: 'float32[384]',     // Sentence embedding
    document: 'text',              // Original chunk text
    metadata: {
      repo: 'string',              // e.g., 'AtlasOfLivingAustralia/collectory'
      branch: 'string',            // e.g., 'master'
      file_path: 'string',         // e.g., 'README.md'
      section: 'string',           // e.g., '## Installation'
      type: 'string',              // 'markdown' | 'code' | 'config'
      tier: 'int',                 // 1, 2, 3, 4 (priority)
      last_updated: 'timestamp',   // When repo was last pulled
      line_start: 'int',           // For source linking
      line_end: 'int'
    }
  }
};

// Collection 2: Configuration variables
const configCollection = {
  name: 'ala_config_vars',
  schema: {
    id: 'uuid',
    embedding: 'float32[384]',
    document: 'text',
    metadata: {
      var_name: 'string',          // e.g., 'collectory_db_host'
      service: 'string',           // e.g., 'collectory'
      default_value: 'string',     // e.g., 'localhost'
      required: 'bool',            // true/false
      deployment_method: 'array',  // ['ansible', 'docker-compose']
      description: 'text',         // Human-readable explanation
      file_path: 'string',         // e.g., 'roles/collectory/defaults/main.yml'
      repo: 'string'
    }
  }
};

// Collection 3: Error patterns
const errorCollection = {
  name: 'ala_error_patterns',
  schema: {
    id: 'uuid',
    embedding: 'float32[384]',
    document: 'text',              // Error message + context
    metadata: {
      error_pattern: 'string',     // e.g., 'Unable to connect to MySQL'
      service: 'string',           // e.g., 'collectory'
      severity: 'string',          // 'error' | 'warning' | 'info'
      causes: 'array',             // ['firewall', 'credentials']
      diagnostic_steps: 'array',   // ['check mysql status', ...]
      wiki_reference: 'string',    // URL to troubleshooting wiki
      repo: 'string',
      file_path: 'string'
    }
  }
};

// Collection 4: Service dependency graph
const dependencyCollection = {
  name: 'ala_service_dependencies',
  schema: {
    id: 'uuid',
    document: 'text',              // Description of dependency
    metadata: {
      service: 'string',           // e.g., 'biocache-hub'
      depends_on: 'array',         // ['solr', 'cassandra', 'collectory', 'cas']
      deployment_phase: 'int',     // 1-6 (from deployment order)
      deployment_method: 'string', // 'ansible' | 'docker-compose'
      optional: 'bool',            // Is this dependency optional?
      reason: 'text'               // Why this dependency exists
    }
  }
};
```

**Storage Layout**:
```
/data/knowledge_base/
  ├── chroma/                      # ChromaDB persistent storage
  │   ├── ala_documentation/
  │   ├── ala_config_vars/
  │   ├── ala_error_patterns/
  │   └── ala_service_dependencies/
  ├── repos/                       # Cloned repositories
  │   ├── ala-install/
  │   ├── collectory/
  │   └── ...
  └── metadata/
      ├── index_status.json        # Last successful index time per repo
      ├── deprecated_repos.json    # List of deprecated repos to skip
      └── schema_version.json      # KB schema version for migrations
```

---

#### 2.4.5 Retrieval Strategy (RAG)

**Query Processing**:
```javascript
class KnowledgeRetriever {
  async retrieve(userQuery, conversationContext, numResults = 5) {
    // Step 1: Enhance query with context
    const enhancedQuery = this.enhanceQuery(userQuery, conversationContext);
    
    // Step 2: Generate query embedding
    const queryEmbedding = await this.embedder.encode(enhancedQuery);
    
    // Step 3: Search multiple collections with different weights
    const [docsResults, configResults, errorResults, depsResults] = await Promise.all([
      this.searchCollection('ala_documentation', queryEmbedding, numResults),
      this.searchCollection('ala_config_vars', queryEmbedding, numResults / 2),
      this.searchCollection('ala_error_patterns', queryEmbedding, numResults / 2),
      this.searchCollection('ala_service_dependencies', queryEmbedding, numResults / 2)
    ]);
    
    // Step 4: Rerank by relevance + recency
    const allResults = [...docsResults, ...configResults, ...errorResults, ...depsResults];
    const reranked = this.rerank(allResults, userQuery, conversationContext);
    
    // Step 5: Return top N with source links
    return reranked.slice(0, numResults).map(result => ({
      text: result.document,
      metadata: result.metadata,
      score: result.score,
      sourceLink: this.generateSourceLink(result.metadata) // Link to GitHub
    }));
  }
  
  enhanceQuery(userQuery, context) {
    // Add conversation context
    const contextInfo = [
      `User's deployment method: ${context.deploymentMethod}`,
      `User's configured services: ${context.services.join(', ')}`,
      `Current project phase: ${context.phase}`
    ].join('\n');
    
    return `${contextInfo}\n\nUser question: ${userQuery}`;
  }
  
  rerank(results, userQuery, context) {
    return results
      .map(result => ({
        ...result,
        score: this.calculateScore(result, userQuery, context)
      }))
      .sort((a, b) => b.score - a.score);
  }
  
  calculateScore(result, userQuery, context) {
    let score = result.similarity; // Base cosine similarity
    
    // Boost Tier 1 repos
    if (result.metadata.tier === 1) score *= 1.5;
    
    // Boost recently updated content
    const daysSinceUpdate = (Date.now() - result.metadata.last_updated) / (1000 * 60 * 60 * 24);
    if (daysSinceUpdate < 30) score *= 1.2;
    if (daysSinceUpdate < 7) score *= 1.4;
    
    // Boost if matches user's deployment method
    if (result.metadata.deployment_method?.includes(context.deploymentMethod)) {
      score *= 1.3;
    }
    
    // Boost if matches user's configured services
    if (context.services.includes(result.metadata.service)) {
      score *= 1.2;
    }
    
    return score;
  }
  
  generateSourceLink(metadata) {
    // GitHub permalink to exact line
    return `https://github.com/${metadata.repo}/blob/${metadata.branch}/${metadata.file_path}#L${metadata.line_start}`;
  }
}
```

**Prompt Injection**:
```javascript
// Injected into Ollama system prompt
const knowledgeContext = retrievedChunks.map((chunk, i) => `
[Source ${i + 1}: ${chunk.metadata.repo} - ${chunk.metadata.file_path}]
${chunk.text}
[View source: ${chunk.sourceLink}]
`).join('\n\n---\n\n');

const systemPrompt = `
You are an AI assistant for the Living Atlas Toolkit.

# Current User Context
- Deployment method: ${context.deploymentMethod}
- Configured services: ${context.services.join(', ')}
- Project phase: ${context.phase}

# Retrieved Knowledge
${knowledgeContext}

# Your Task
Answer the user's question using the retrieved knowledge above.
ALWAYS cite sources using [Source N] notation.
If the knowledge doesn't contain the answer, say "I don't have enough information" and suggest consulting the wiki.
`;
```

---

#### 2.4.6 Indexing Schedule

**Automated Updates**:
```javascript
// api/config/cron.js

module.exports.cron = {
  // Tier 1 repos: Daily
  indexTier1Repos: {
    schedule: '0 2 * * *', // 2 AM daily
    onTick: async () => {
      await RepositoryIndexer.indexTier(1);
    }
  },
  
  // Tier 2 repos: Weekly
  indexTier2Repos: {
    schedule: '0 3 * * 0', // 3 AM Sunday
    onTick: async () => {
      await RepositoryIndexer.indexTier(2);
    }
  },
  
  // Tier 3-4 repos: Monthly
  indexTier34Repos: {
    schedule: '0 4 1 * *', // 4 AM 1st of month
    onTick: async () => {
      await RepositoryIndexer.indexTier(3);
      await RepositoryIndexer.indexTier(4);
    }
  }
};
```

**Manual Refresh**:
- Admin UI button: "Refresh Knowledge Base"
- Webhook: Trigger re-index when ALA repo receives push (GitHub webhook)

---

#### 2.4.7 Quality Assurance

**Testing Knowledge Base Accuracy**:
```javascript
// test/knowledge_base_accuracy.test.js

const testQuestions = [
  {
    question: "What is the recommended deployment order for LA services?",
    expectedKeywords: ["branding", "CAS", "collectory", "biocache-service"],
    expectedSource: "ala-install"
  },
  {
    question: "How do I generate CAS encryption keys?",
    expectedKeywords: ["JWKS", "openssl", "CAS-5"],
    expectedSource: "documentation/wiki/CAS-postinstall-steps"
  },
  // ... 50-100 test questions
];

describe('Knowledge Base Accuracy', () => {
  testQuestions.forEach(test => {
    it(`should answer: ${test.question}`, async () => {
      const results = await KnowledgeRetriever.retrieve(test.question, {});
      
      // Check if expected keywords appear in results
      const resultText = results.map(r => r.text).join(' ');
      test.expectedKeywords.forEach(keyword => {
        expect(resultText.toLowerCase()).toContain(keyword.toLowerCase());
      });
      
      // Check if source is correct
      const sources = results.map(r => r.metadata.repo + r.metadata.file_path);
      expect(sources.some(s => s.includes(test.expectedSource))).toBe(true);
    });
  });
});
```

**Monitoring**:
- Log retrieval quality scores (average similarity)
- Track "I don't know" responses (indicates knowledge gaps)
- User feedback: "Was this helpful?" button

---

### 2.5 Initial Knowledge Base Bootstrap

**Phase 1 Implementation**: Manual seed for MVP

Before automated indexing is ready, bootstrap with curated content:

```javascript
// scripts/seed_knowledge_base.js

const seedKnowledge = {
  deploymentOrder: {
    ansible: [
      { phase: 1, services: ['branding'], reason: 'No dependencies' },
      { phase: 2, services: ['cas', 'collectory'], reason: 'Core infrastructure' },
      { phase: 3, services: ['logger-service', 'image-service'], reason: 'Simple services' },
      { phase: 4, services: ['solr', 'cassandra'], reason: 'Backend data stores' },
      { phase: 5, services: ['biocache-service', 'biocache-hub', 'bie-hub'], reason: 'Complex services' }
    ],
    dockerCompose: {
      note: 'Experimental - depends_on + healthchecks manage order automatically',
      servers: [
        { name: 'backend', services: ['solr', 'cassandra', 'collectory'] },
        { name: 'frontend', services: ['branding', 'biocache-hub', 'cas'] }
      ]
    }
  },
  
  commonErrors: [
    {
      pattern: '502 Bad Gateway',
      service: 'any',
      causes: ['Backend service not responding', 'Nginx config error', 'Service not started'],
      diagnostics: ['Check service logs', 'Verify service is running', 'Check nginx config']
    },
    // ... more errors
  ],
  
  configVariables: [
    {
      name: 'collectory_db_host',
      service: 'collectory',
      description: 'Database hostname for Collectory',
      required: true,
      default: 'localhost',
      ansible_path: 'roles/collectory/defaults/main.yml'
    },
    // ... more variables
  ]
};

// Convert to embeddings and store
await bootstrapFromSeed(seedKnowledge);
```

---

## 3. User Personas

### 3.1 New LA Deployer
**Context**: First LA deployment, limited DevOps experience  
**Goals**: Get a working minimal portal without major mistakes  
**AI Assistance**: High-touch, proactive warnings, step-by-step guidance

### 3.2 Experienced Administrator
**Context**: Existing portal, needs troubleshooting/upgrades  
**Goals**: Quick diagnosis, upgrade paths, performance tuning  
**AI Assistance**: Direct answers, log analysis, comparison with working configs

### 3.3 Developer/Contributor
**Context**: Customizing services, contributing to ALA codebase  
**Goals**: Understand service architecture, safe customization patterns  
**AI Assistance**: Code references, architecture explanations, no-fork guidance

---

## 4. Conversation Scenarios [DRAFT - NEEDS REVIEW]

> **⚠️ NOTE TO REVIEWER**: The following scenarios are initial drafts based on LA deployment patterns circa early 2025. Each scenario needs validation against:
> - Current ala-install practices (especially docker-compose integration)
> - Updated hardware recommendations
> - Modern deployment patterns (ansible vs docker-compose vs hybrid)
> - Evolved community best practices
>
> Please review each scenario and flag specific inaccuracies or outdated assumptions.

### 4.1 Initial Project Setup

**Status**: 🟡 NEEDS REVIEW  
**Concerns**: 
- Is the 5-7 server recommendation still valid with docker-compose?
- How does containerization change architecture recommendations?
- What's the new minimal setup?

**Trigger**: User creates new LA Toolkit project  
**AI Goal**: Establish realistic infrastructure expectations

**Flow** (5-7 turns):
1. **AI**: "Welcome! I'll help you deploy a Living Atlas portal. First, let me understand your environment. How will you deploy: (1) Traditional Ansible to VMs, (2) Docker Compose on fewer servers, or (3) Hybrid approach?"

2. **User**: [Selects approach]

3. **AI**: [Provides appropriate architecture guidance based on selection]
   - **If Ansible**: "Traditional deployment requires 5-7 servers minimum (auth, collections, biocache-backend, biocache-ui, species, logger, branding)..."
   - **If Docker Compose**: "Docker Compose allows consolidating services on fewer servers. Typical setup: 2-3 servers (backend + databases, frontend services, spatial services)..."
   - **If Hybrid**: "Hybrid approaches are common for migration scenarios..."

4. [Continue with SSL, domain planning, etc.]

**FIXME**: 
- Validate server count recommendations for docker-compose deployments
- Update with actual docker-compose architecture patterns from new ala-install work
- Clarify when hybrid makes sense

---

### 4.2 Configuration Validation

**Status**: 🟢 PROBABLY CURRENT  
**Concerns**: None identified, but validate CAS-5 specifics haven't changed

**Trigger**: User configuring services in LA Toolkit  
**AI Goal**: Catch configuration errors before deployment

**Flow** (6-8 turns):
1. **AI** (proactive): "I notice you're configuring CAS authentication. Before deploying, you'll need to generate CAS encryption keys. Would you like help with this?"

2. **User**: "Yes"

3. **AI**: "CAS-5 requires JSON Web Key Sets (JWKS) for OAuth2. [Action Available: Validate Prerequisites - checks if openssl/java installed on auth server]. Should I check your server?"

4. **User**: [Approves action]

5. **AI**: [Executes check, provides generation commands]

6. **AI**: "Copy these keys into LA Toolkit: Basic tab → CAS Configuration → JWKS Keys. Reference: https://github.com/AtlasOfLivingAustralia/documentation/wiki/CAS-postinstall-steps"

**FIXME**:
- Confirm JWKS is still the correct key format for ala-cas-5
- Validate postinstall steps haven't changed

---

### 4.3 Deployment Orchestration

**Status**: 🟡 UPDATED - Reflects current practices (2026-03-14)  
**Notes**:
- Docker-Compose support is **experimental/beta** (WIP in ala-install)
- Typical docker-compose architecture: **2-3 servers minimum** (variable, may include hybrid ansible+docker)
- Dependency management via **depends_on + healthchecks**
- Ansible deployment order emphasizes **building foundation first** (branding → CAS → collectory → simple services → complex services like biocache-service last)

**Trigger**: User ready to deploy services  
**AI Goal**: Prevent "deploy everything at once" failure mode, guide appropriate deployment strategy

---

#### **Scenario A: Ansible Deployment (Traditional, Stable)**

**Flow** (8-12 turns):

1. **User**: "I'm ready to deploy everything"

2. **AI**: "⚠️ **Important**: Don't deploy all services at once. This is the #1 cause of deployment failures. Let me help you plan the correct order.

   First, which deployment method are you using:
   - **Ansible** (traditional, stable, 5-7 servers)
   - **Docker Compose** (experimental, 2-3 servers, WIP)
   - **Hybrid** (mix of both)"

3. **User**: "Ansible"

4. **AI**: "Good choice for production stability. Ansible deployments follow a **foundation-first** approach. [Action Available: Suggest Deployment Order - analyzes your configured services].

   The key principle: **start simple, build complexity gradually**. Each service must be verified working before deploying the next layer. Should I analyze your configuration?"

5. **User**: [Approves action]

6. **AI**: [Generates deployment phases based on user's configured services]
   
   "Based on your configuration, here's the recommended deployment order:
   
   **Phase 1: Foundation & Branding** (Deploy first)
   - `branding` - Portal appearance, no dependencies
   
   **Phase 2: Core Infrastructure** (After Phase 1 working)
   - `CAS` (ala-cas-5) - Authentication service (all others depend on this)
   - `collectory` - Metadata registry (needed by data services)
   
   **Phase 3: Simple Services** (After Phase 2 working)
   - `logger-service` - Event logging
   - `image-service` - Media management
   - `userdetails` + `apikey` - User management
   
   **Phase 4: Backend Data Stores** (After Phase 3 working)
   - `solr` - Search indexing
   - `cassandra` - Occurrence data storage (if using biocache-store)
   
   **Phase 5: Complex Services** (After Phase 4 working)
   - `biocache-service` - Occurrence API (needs Solr, Cassandra, Collectory, CAS all working)
   - `biocache-hub` - Occurrence UI (needs biocache-service)
   - `bie-index` + `bie-hub` - Species pages
   
   **Phase 6: Advanced Features** (Optional, after Phase 5 working)
   - `spatial-hub` + `spatial-service` - Spatial analysis
   - `regions` - Geographic regions
   - `alerts` - User notifications
   
   **Critical Rules**:
   - ✅ Deploy one phase at a time
   - ✅ Verify each service responds before proceeding (curl/browser test)
   - ✅ Check logs for errors after each deployment
   - ❌ Never skip phases or deploy multiple phases in parallel
   
   Shall we start with Phase 1 (Branding)?"

7. **User**: "Yes, how do I deploy branding?"

8. **AI**: "To deploy branding service:
   
   **Step 1**: SSH to your branding server
   ```bash
   ssh ubuntu@branding.yourportal.org
   ```
   
   **Step 2**: Navigate to your ala-install clone
   ```bash
   cd ~/ala-install
   ```
   
   **Step 3**: Run the branding playbook
   ```bash
   ansible-playbook -i inventories/your-inventory branding-playbook.yml
   ```
   
   **Step 4**: Verify deployment
   - Open https://yourportal.org in browser
   - Should see your branded homepage
   - Check logs: `sudo journalctl -u branding -n 50`
   
   **Common issues**:
   - **502 Bad Gateway**: Nginx config error, check `/etc/nginx/sites-available/`
   - **Certificate errors**: SSL not configured, see Let's Encrypt wiki
   - **Page not loading**: DNS not resolving, check domain configuration
   
   Let me know when branding is working, or if you encounter errors."

9. **User**: "Branding works! What's next?"

10. **AI**: "Excellent! ✓ Phase 1 complete. Now for **Phase 2: CAS authentication**.
    
    This is **critical** - many services won't work without CAS. Before deploying:
    
    ⚠️ **Prerequisites**:
    1. Have you generated CAS encryption keys (JWKS)? 
    2. Are they configured in LA Toolkit (Basic tab → CAS Keys)?
    3. Does your CAS subdomain (auth.yourportal.org) resolve via DNS?
    
    [Action Available: Validate Prerequisites - checks CAS requirements]
    
    Should I check your prerequisites before CAS deployment?"

11. **User**: [Continues through phases...]

**Key Conversation Branches**:
- **If user skips verification**: AI warns strongly, explains consequences (debugging hell, time waste)
- **If user reports errors**: AI triggers log analysis action, diagnoses issue before proceeding
- **If user wants to deploy multiple phases**: AI explains dependency risks, recommends against

---

#### **Scenario B: Docker Compose Deployment (Experimental)**

**Flow** (7-10 turns):

1. **User**: "I want to use Docker Compose"

2. **AI**: "⚠️ **Important**: Docker Compose support in ala-install is currently **experimental/beta**. This means:
   - ✅ Works for testing/development
   - ⚠️ May have rough edges for production
   - 📝 Actively being developed (features may change)
   - 🔧 Community feedback welcome
   
   **Advantages**:
   - Fewer servers needed (2-3 vs 5-7)
   - Easier local development
   - Container isolation
   
   **Challenges**:
   - Not all services may have docker-compose configs yet
   - Documentation still evolving
   - May need hybrid approach (some services on ansible)
   
   Do you want to proceed with docker-compose, or would you prefer stable ansible deployment?"

3. **User**: "Proceed with docker-compose"

4. **AI**: "Understood. Docker Compose architecture is **variable** - depends on your hardware and requirements. Typical setups:
   
   **Option A: 2-Server Setup**
   - Server 1: Backend services (solr, cassandra, collectory, biocache-service)
   - Server 2: Frontend services (branding, biocache-hub, bie-hub, CAS)
   
   **Option B: 3-Server Setup**
   - Server 1: Data stores (solr, cassandra, databases)
   - Server 2: Core services (CAS, collectory, logger, biocache-service)
   - Server 3: User-facing (branding, biocache-hub, bie-hub, spatial)
   
   **Option C: Hybrid** (recommended for production migration)
   - Critical services (CAS, biocache-backend) on ansible VMs
   - New/experimental services on docker-compose
   
   Which setup matches your infrastructure?"

5. **User**: [Selects setup]

6. **AI**: "For Docker Compose deployment, dependency management is handled via **depends_on + healthchecks**. This means:
   - Containers automatically wait for dependencies to be healthy
   - Less manual orchestration than ansible
   - BUT: You still need to understand dependencies for troubleshooting
   
   [Action Available: Generate Config - creates docker-compose.yml for your setup]
   
   I can generate the docker-compose configuration files. Should I proceed?"

7. **User**: [Approves]

8. **AI**: [Generates docker-compose.yml with appropriate depends_on, healthchecks, volumes, networks]
   
   "Here's your docker-compose.yml for Server 1 (backend):
   
   ```yaml
   version: '3.8'
   services:
     solr:
       image: solr:8.11
       healthcheck:
         test: ['CMD', 'curl', '-f', 'http://localhost:8983/solr/']
         interval: 10s
         timeout: 5s
         retries: 5
       volumes:
         - solr-data:/var/solr
     
     cassandra:
       image: cassandra:3.11
       healthcheck:
         test: ['CMD', 'cqlsh', '-e', 'describe cluster']
         interval: 30s
         timeout: 10s
         retries: 5
       volumes:
         - cassandra-data:/var/lib/cassandra
     
     collectory:
       image: ala/collectory:latest
       depends_on:
         solr:
           condition: service_healthy
       environment:
         - SOLR_URL=http://solr:8983/solr
         - CAS_URL=https://auth.yourportal.org/cas
       ports:
         - '8080:8080'
   ```
   
   **Deployment steps**:
   1. Copy docker-compose.yml to each server
   2. Run: `docker-compose up -d` on each server in order (backend first, then frontend)
   3. Monitor logs: `docker-compose logs -f`
   4. Verify health: `docker-compose ps` (all should show 'healthy')
   
   **Important notes**:
   - This is a simplified example - full configs will be more complex
   - SSL certificates need separate setup (Let's Encrypt with certbot)
   - Networking between servers needs firewall rules
   
   Would you like me to walk you through the first server deployment?"

---

#### **Scenario C: Hybrid Deployment**

**Flow** (5-7 turns):

1. **User**: "I need a hybrid approach"

2. **AI**: "Hybrid deployments make sense when:
   - Migrating from ansible to docker-compose gradually
   - Some services are stable on VMs, others you want containerized
   - Testing new services in containers before committing
   
   **Typical hybrid pattern**:
   - **Keep on Ansible** (stable, mission-critical): CAS, biocache-backend (Solr/Cassandra), collectory
   - **Move to Docker** (easier to update/test): logger, image-service, alerts, spatial services
   
   What's your reason for hybrid deployment?"

3. **User**: [Explains situation]

4. **AI**: [Provides tailored guidance based on user's needs, combining elements of Scenario A and B]

---

**Implementation Notes for AI**:
- Always ask deployment method first (don't assume)
- For ansible: Emphasize phase-by-phase verification
- For docker-compose: Warn about experimental status, provide fallback guidance
- For hybrid: Understand user's constraints before recommending split
- Track deployment progress in conversation context (which phases completed)
- Proactively offer log analysis if user reports issues

---

### 4.4 Error Diagnosis & Log Analysis

**Status**: 🟡 NEEDS REVIEW  
**Concerns**: 
- Log locations may differ in containerized deployments
- New services may have different logging patterns

**Trigger**: User reports service failure/error  
**AI Goal**: Systematic diagnosis using logs and common error patterns

**Flow** (6-10 turns):
1. **User**: "Biocache-hub returns 502 Bad Gateway"

2. **AI**: "502 errors indicate backend service not responding. Let me gather context:
   - Deployment method: Ansible or Docker Compose?
   - Did earlier services (Solr, Cassandra, Collectory, CAS) deploy successfully?
   - Any recent configuration changes?"

3. **User**: "Docker Compose, earlier services running, no changes"

4. **AI**: "[Action Available: Analyze Logs - docker logs biocache-hub]. Check container logs?"

5. **User**: [Approves]

6. **AI**: [Analyzes logs, identifies root cause, provides solution]

**FIXME**:
- Update log location patterns for docker deployments
- Map common docker-specific errors (container networking, volume mounts, etc.)
- Validate Solr/Cassandra still required for biocache or if pipelines changed this

---

### 4.5 Data Ingestion Workflow

**Status**: 🟡 NEEDS REVIEW  
**Concerns**:
- GBIF Pipelines may have changed ingestion workflow vs. biocache-store
- Need to clarify current recommended approach

**Trigger**: User wants to add first data resource  
**AI Goal**: Guide through collectory → ingestion → indexing pipeline

**Flow** (8-12 turns):
1. **User**: "How do I add occurrence data?"

2. **AI**: "Data ingestion workflow:
   1. Create data resource in Collectory
   2. Upload data (DwC-A, CSV, or IPT endpoint)
   3. Run ingestion pipeline (GBIF Pipelines or biocache-store)
   4. Index into Solr
   
   What format is your data?"

3. **User**: "Darwin Core Archive"

4. **AI**: [Guides through collectory setup, explains DR ID, then:]
   "For ingestion, you have two options:
   - **GBIF Pipelines** (recommended, newer, faster, better for large datasets)
   - **biocache-store** (legacy, still supported for smaller deployments)
   
   Which is your portal using?"

5. **User**: [Selects approach]

6. **AI**: [Provides approach-specific commands and validation steps]

**FIXME**:
- Clarify current recommendation: Pipelines vs biocache-store
- Update ingestion commands for current versions
- Validate Docker Compose implications (Jenkins setup? Direct commands?)

---

### 4.6 Upgrade Path Planning

**Status**: 🔴 NOT YET DESIGNED  
**Concerns**: This is a critical scenario that needs fresh design

**Trigger**: User with existing portal wants to upgrade services  
**AI Goal**: Provide safe upgrade paths, prevent breaking changes

**Flow**: [TO BE DESIGNED]

**TODO**:
- Define upgrade risk assessment process
- Map breaking changes between major versions
- Create rollback procedures
- Test upgrade scenarios (e.g., CAS-2 → CAS-5 migration)

---

### 4.7 Customization Guidance

**Status**: 🟢 PROBABLY CURRENT  
**Concerns**: No-fork philosophy unlikely to have changed

**Trigger**: User asks about UI/functional modifications  
**AI Goal**: Encourage safe customization patterns, discourage unmaintainable forks

**Flow** (4-6 turns):
1. **User**: "Can I change the homepage layout?"

2. **AI**: "Yes, but let me explain the customization trade-offs:
   
   **Safe** (survives upgrades):
   - Branding variables (logos, colors, org name)
   - Configuration-based toggles
   - CSS overrides via skin.css
   
   **Risky** (requires maintenance):
   - Forking service repos
   - Modifying Grails GSP templates
   - Custom controllers/services
   
   **Recommended approach**: Try configuration + CSS first. Reference: [The ALA No-Fork Path](https://github.com/AtlasOfLivingAustralia/documentation/wiki/The-ALA-No%E2%80%90Fork-Path)
   
   What specifically do you want to change?"

3. **User**: "Just rearrange homepage sections"

4. **AI**: "That requires template modifications (risky). Alternative: Many portals use the CMS integration to create custom landing pages while keeping standard search UI. Would that work?"

**FIXME**:
- Validate CMS integration patterns still recommended
- Check if newer services offer more configuration-based customization

---

### 4.8 Proactive Monitoring [FUTURE]

**Status**: 🔴 NOT YET DESIGNED  
**Concerns**: Requires backend infrastructure not yet built

**Trigger**: AI detects anomalies/potential issues proactively  
**AI Goal**: Warn before failures occur

**Concept**: AI monitors toolkit state and service health, alerts user to:
- Disk space running low on backend servers
- SSL certificates expiring soon
- Services not responding
- Unusual error patterns in logs
- Data ingestion failures

**TODO**: Design after core chat functionality working

---

## 5. AI Actions Specification

### 5.1 Action: validate_servers

**Purpose**: Check server prerequisites (OS, connectivity, installed packages)

**Input**:
```json
{
  "servers": [
    {"hostname": "auth.example.org", "role": "cas", "ssh_config": {...}}
  ],
  "checks": ["ssh_access", "os_version", "ansible_installed", "python_version"]
}
```

**Output**:
```json
{
  "results": [
    {
      "hostname": "auth.example.org",
      "checks": {
        "ssh_access": {"status": "pass", "details": "Connected successfully"},
        "os_version": {"status": "pass", "details": "Ubuntu 22.04 LTS"},
        "ansible_installed": {"status": "fail", "details": "ansible command not found"},
        "python_version": {"status": "pass", "details": "Python 3.10.12"}
      },
      "overall": "partial"
    }
  ],
  "recommendation": "Install Ansible on control machine before proceeding"
}
```

**Permissions**: Requires SSH credentials, user approves before execution

---

### 5.2 Action: check_prerequisites

**Purpose**: Validate external dependencies (DNS, firewall, APIs)

**Input**:
```json
{
  "checks": [
    {"type": "dns", "domain": "auth.example.org", "expected_ip": "192.0.2.10"},
    {"type": "https", "url": "https://auth.example.org", "expect_status": [200, 302]},
    {"type": "port", "host": "192.0.2.10", "port": 443, "protocol": "tcp"}
  ]
}
```

**Output**: Pass/fail per check with actionable recommendations

**Permissions**: No credentials required (external checks only), auto-approved

---

### 5.3 Action: analyze_logs

**Purpose**: Fetch and parse service logs for errors

**Input**:
```json
{
  "server": "biocache-hub.example.org",
  "service": "biocache-hub",
  "log_type": "tomcat | docker | system",
  "lines": 500
}
```

**Output**:
```json
{
  "summary": {
    "errors": 12,
    "warnings": 45,
    "critical_patterns": [
      {
        "pattern": "CAS authentication failed",
        "occurrences": 8,
        "known_issue": true,
        "wiki_ref": "Troubleshooting#cas-connection-errors"
      }
    ]
  },
  "diagnosis": "Backend cannot reach CAS server. Likely firewall or DNS issue.",
  "suggested_actions": ["Check firewall rules", "Verify CAS server is running"]
}
```

**Permissions**: Requires SSH credentials, user approves

---

### 5.4 Action: generate_ssh_config

**Purpose**: Create SSH config snippet for server access

**Input**:
```json
{
  "servers": [
    {"name": "auth-server", "hostname": "auth.example.org", "user": "ubuntu"}
  ]
}
```

**Output**:
```bash
# Add to ~/.ssh/config
Host auth-server
    HostName auth.example.org
    User ubuntu
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking accept-new
```

**Permissions**: No system access required, auto-approved

---

### 5.5 Action: generate_config

**Purpose**: Generate configuration snippets (ansible vars, docker-compose, commands)

**Input**:
```json
{
  "config_type": "ansible_inventory | docker_compose | ingestion_command",
  "context": {...} // Current LA Toolkit project state
}
```

**Output**: Formatted config file or command ready to copy

**Permissions**: Read-only access to LA Toolkit project, auto-approved

---

### 5.6 Action: suggest_deployment_order

**Purpose**: Analyze configured services and recommend deployment sequence

**Input**:
```json
{
  "services": ["cas", "collectory", "biocache-hub", "biocache-service", "bie-hub", "solr", "cassandra"],
  "deployment_method": "ansible | docker_compose"
}
```

**Output**:
```json
{
  "phases": [
    {
      "phase": 1,
      "services": ["solr", "cassandra"],
      "reason": "Backend data stores have no dependencies"
    },
    {
      "phase": 2,
      "services": ["collectory", "cas"],
      "reason": "Metadata and auth required by all other services"
    }
  ],
  "critical_notes": [
    "Verify each service responds before proceeding to next phase",
    "CAS must be fully configured (keys installed) before biocache-hub deployment"
  ]
}
```

**Permissions**: No system access, auto-approved

---

### 5.7 Action: optimize_config

**Purpose**: Review configuration for common mistakes and performance issues

**Input**: Current LA Toolkit project configuration

**Output**:
```json
{
  "issues": [
    {
      "severity": "warning",
      "category": "performance",
      "description": "Solr heap size (512MB) is below recommended minimum (2GB)",
      "recommendation": "Increase solr_heap_size variable to 2048"
    },
    {
      "severity": "error",
      "category": "security",
      "description": "SSL disabled for CAS server",
      "recommendation": "Enable SSL/TLS with Let's Encrypt or provide certificates"
    }
  ]
}
```

**Permissions**: No system access, auto-approved

---

## 6. UI/UX Specification

### 6.1 Chat Interface

**Components**:
- **Floating FAB**: Bottom-right, persistent across all LA Toolkit pages
- **Chat Panel**: 400px wide, slides in from right edge, overlays main content
- **Message Types**:
  - User message (right-aligned, blue)
  - AI message (left-aligned, gray)
  - System notification (centered, yellow)
  - Action prompt (interactive card with approve/reject buttons)

**Interactions**:
- Click FAB → Panel slides in
- Click outside panel or X button → Panel slides out (conversation persists)
- Streaming response: Messages appear token-by-token as AI generates them
- Action approval: Inline buttons, no separate modals

### 6.2 Conversation Context

**Persistent State** (stored in Redux):
- Full conversation history (current session)
- User's current LA Toolkit page context
- Project configuration snapshot
- Pending actions awaiting approval

**Context Injection** (sent to AI with each message):
- Current project name
- Configured services
- Deployment stage (pre-deploy, deploying, post-deploy)
- Recent user actions in LA Toolkit

---

## 7. Technical Architecture

### 7.1 Frontend (Flutter + Redux)

**New Components**:
- `lib/ai_assistant/`
  - `ai_chat_fab.dart` - Floating action button
  - `ai_chat_panel.dart` - Slide-in panel container
  - `ai_message.dart` - Message bubble widget
  - `ai_action_card.dart` - Interactive action prompt
  - `ai_chat_input.dart` - User input field

**Redux Integration**:
- `lib/redux/ai_assistant/`
  - `ai_state.dart` - Conversation state model
  - `ai_actions.dart` - Redux actions (send message, approve action, etc.)
  - `ai_reducer.dart` - State updates
  - `ai_middleware.dart` - WebSocket communication

### 7.2 Backend (Sails.js)

**New Endpoints**:
- `POST /api/ai/chat` - Send user message, receive AI response
- `POST /api/ai/action/execute` - Execute approved action
- `GET /api/ai/conversation/:id` - Retrieve conversation history
- `WebSocket /ai` - Streaming responses

**New Controllers**:
- `api/controllers/AIController.js`

**New Services**:
- `api/services/OllamaService.js` - Ollama API integration
- `api/services/KnowledgeBaseService.js` - RAG query interface
- `api/services/ActionExecutorService.js` - Execute AI actions safely

### 7.3 Ollama Integration

**Connection**:
- External Ollama server (configured via environment variable)
- Model: `llama3.1:8b` (default), configurable
- Streaming responses via Server-Sent Events

**Prompt Engineering**:
- System prompt includes:
  - LA Toolkit context (current project state)
  - Retrieved knowledge base snippets (RAG)
  - Conversation history (last 10 turns)
  - Available actions with parameters

### 7.4 Knowledge Base (RAG)

**Storage**: TBD - Options:
- Embedded vector DB (e.g., Chroma, FAISS)
- External vector store (Pinecone, Weaviate)
- Simple semantic search (sentence-transformers + SQLite)

**Indexing Pipeline**:
1. Clone/pull ALA repos periodically
2. Extract documentation (README, code comments, configs)
3. Chunk text (500-1000 tokens)
4. Generate embeddings (sentence-transformers)
5. Store with metadata (repo, file path, service name, last updated)

**Retrieval**:
- User query + conversation context → embedding
- Semantic search → top 5 relevant chunks
- Inject into AI prompt

---

## 8. Implementation Roadmap

### Phase 1: Core Chat (Weeks 1-3)
- [ ] Design chat UI components (Flutter)
- [ ] Implement WebSocket backend (Sails.js)
- [ ] Connect to Ollama (basic prompt, no RAG)
- [ ] Basic conversation flow (hardcoded responses for testing)
- [ ] Deploy to test environment

### Phase 2: Knowledge Base (Weeks 4-6)
- [ ] Select vector DB solution
- [ ] Build repo indexing pipeline
- [ ] Index Tier 1 repositories (ala-install, la-toolkit, pipelines)
- [ ] Implement RAG retrieval
- [ ] Test knowledge accuracy with sample questions

### Phase 3: Actions (Weeks 7-9)
- [ ] Implement Action framework (permissions, execution)
- [ ] Build actions: validate_servers, check_prerequisites
- [ ] Build actions: generate_ssh_config, generate_config
- [ ] Test action approval UI flow
- [ ] Security audit of action execution

### Phase 4: Advanced Actions (Weeks 10-11)
- [ ] Build actions: analyze_logs, suggest_deployment_order
- [ ] Build actions: optimize_config
- [ ] Integration testing with real deployments

### Phase 5: Proactive Assistance (Weeks 12-13)
- [ ] Event system (monitor LA Toolkit user actions)
- [ ] Trigger proactive AI suggestions
- [ ] Polish UI/UX based on user testing
- [ ] Production deployment

---

## 9. Testing Strategy

### 9.1 Scenario-Based Testing
Create test suites for each conversation scenario:
- Predefined user inputs
- Expected AI responses (key phrases, action suggestions)
- Knowledge base retrieval accuracy

### 9.2 Action Testing
- Unit tests for each action executor
- Integration tests with real servers (test environment)
- Security tests (permission bypass attempts)

### 9.3 Knowledge Base Validation
- Accuracy: Sample questions → manual verification of responses
- Freshness: Detect when indexed knowledge is outdated
- Coverage: Ensure all Tier 1-2 services documented

---

## 10. Open Questions & Decisions

### 10.1 Deployment Architecture
**Q**: How does docker-compose change recommended server topology?  
**Status**: 🔴 CRITICAL - Needs input from @vjrj on new ala-install patterns

### 10.2 Ingestion Workflow
**Q**: What's the current recommendation - GBIF Pipelines or biocache-store?  
**Status**: 🟡 MEDIUM - Affects Scenario 4.5

### 10.3 Vector DB Selection
**Q**: Embedded (Chroma) vs. external (Pinecone) vs. simple (sentence-transformers + SQLite)?  
**Tradeoff**:
- Embedded: Simpler deployment, limited scale
- External: Better scale, adds dependency
- Simple: Fast to build, may lack advanced features

**Decision**: Start simple, migrate to embedded if needed

### 10.4 Action Permission Model
**Q**: How granular should user approval be?  
**Options**:
1. Approve each action individually (current proposal)
2. Approve action categories once per session
3. Allow "always allow" for specific actions

**Decision**: Start with #1, add #2 based on user feedback

### 10.5 Conversation Persistence
**Q**: How long to retain conversation history?  
**Options**:
- Session only (lost on app restart)
- Persist to backend DB (searchable history)
- Local storage (privacy-friendly)

**Decision**: TBD based on privacy requirements

---

## 11. Success Metrics

**Phase 1-2 (Core Chat + Knowledge Base)**:
- AI correctly answers 80%+ of factual LA questions (manual eval)
- Knowledge base covers 100% of Tier 1 repos, 80% of Tier 2

**Phase 3-4 (Actions)**:
- Users complete first deployment 30% faster with AI assistance (A/B test)
- Common errors (SSL, CAS keys, deployment order) reduced by 50%

**Phase 5 (Proactive)**:
- 60% of proactive suggestions accepted/followed by users
- User satisfaction score >4/5 for AI helpfulness

---

## Appendix A: Repository Status & Deprecation

### Active Repositories (Safe to Reference)

**Deployment**:
- ✅ `ala-install` - Ansible playbooks (actively maintained)

**Core Services**:
- ✅ `collectory` - Active
- ✅ `biocache-hubs` - Active (replaced older `ala-hub`)
- ✅ `ala-bie-hub` - Active (replaced older `ala-bie`)
- ✅ `ala-cas-5` - Active (current auth service)
- ✅ `logger-service` - Active
- ✅ `image-service` - Active
- ✅ `spatial-hub` + `spatial-service` - Active

**Supporting**:
- ✅ `userdetails` + `apikey` - Active
- ✅ `alerts` - Active
- ✅ `doi-service` - Active
- ✅ `regions` - Active
- ✅ `species-lists` + `specieslist-webapp` - Active
- ✅ `ala-namematching-service` - Active
- ✅ `ala-sensitive-data-service` - Active

**Data Processing**:
- ✅ `gbif/pipelines` - Active (preferred for new deployments)
- ⚠️ `biocache-store` - Legacy but still supported

**Specialized**:
- ✅ `biocollect` + `ecodata` - Active
- ⚠️ `volunteer-portal` - Maintenance status unclear
- ⚠️ `dashboard` - Maintenance status unclear

### Deprecated (Do NOT Reference)

- ❌ `ala-hub` - Use `biocache-hubs` instead
- ❌ `ala-bie` - Use `ala-bie-hub` instead
- ❌ `ala-cas-2` - Use `ala-cas-5` instead
- ❌ Old biocache-service versions - Check current recommended version

### To Investigate

- `volunteer-portal` - Still maintained?
- `dashboard` - Still used in production nodes?
- `bie-plugin` - Current status?

---

## Appendix B: Glossary

**ALA** - Atlas of Living Australia  
**LA** - Living Atlas (the broader community/software)  
**DR** - Data Resource (occurrence dataset)  
**DwC-A** - Darwin Core Archive  
**CAS** - Central Authentication Service  
**BIE** - Biodiversity Information Explorer (species pages)  
**IPT** - Integrated Publishing Toolkit (GBIF data publishing)  
**GBIF** - Global Biodiversity Information Facility  
**RAG** - Retrieval-Augmented Generation (AI technique)  
**FAB** - Floating Action Button (UI element)

---

## Appendix C: Session Notes & Evolution

**2026-03-14**: Initial specification created based on:
- Common Challenges wiki analysis
- Development Resources review
- ~25 active ALA repositories identified
- User requirements: Full lifecycle support, Ollama+llama3.1:8b, external server, 7 actions, proactive assistance, English language

**Next Session Tasks**:
1. Review Scenario 4.3 (Deployment Orchestration) with current ala-install patterns
2. Define knowledge base processing strategy
3. Design detailed knowledge base schema
4. Document docker-compose integration status

---

**End of Specification v0.1**
