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

**Status**: ✅ UPDATED - Reflects current practices (2026-03-14)  
**Notes**:
- **Ansible** is the stable, recommended deployment method for production
- **Docker Compose** support is experimental/beta (WIP in ala-install)
- AI defaults to Ansible guidance unless user specifically requests Docker

**Trigger**: User creates new LA Toolkit project  
**AI Goal**: Establish realistic infrastructure expectations and guide toward stable deployment

**Flow** (6-9 turns):

1. **AI**: "Welcome! I'll help you deploy a Living Atlas portal. Let me guide you through the infrastructure planning.
   
   **Recommended approach**: Traditional Ansible deployment (stable, production-ready).
   
   First, let's understand your hardware:
   - How many servers do you have available?
   - Are they VMs or bare metal?
   - Approximate specs per server (CPU, RAM, storage)?"

2. **User**: [Provides server details, e.g., "I have 5 VMs, 8 cores, 16GB RAM each"]

3. **AI**: "Good! 5 servers is suitable for a standard LA deployment. Here's the typical architecture:
   
   **Server Allocation (Ansible)**:
   1. **Authentication Server** (CAS) - `auth.yourportal.org`
   2. **Collections Server** (Collectory) - `collections.yourportal.org`
   3. **Biocache Backend** (Solr, Cassandra, biocache-service) - `biocache-ws.yourportal.org`
   4. **Biocache UI** (biocache-hub, branding) - `biocache.yourportal.org`
   5. **Species Server** (bie-index, bie-hub) - `species.yourportal.org`
   
   **Optional** (can consolidate):
   - Logger service (can share with collections server)
   - Image service (can share with branding server)
   - Spatial services (can share with species server, or separate if heavy use)
   
   You can expand to 6-7 servers later if needed. Sound reasonable?"

4. **User**: "Yes, what about domains?"

5. **AI**: "For each server, you'll need:
   
   **DNS Configuration**:
   - Subdomains pointing to each server (auth.yourportal.org, collections.yourportal.org, etc.)
   - Main portal domain (yourportal.org) → points to branding server
   
   **SSL Certificates**:
   - Recommended: Let's Encrypt (free, automatic renewal)
   - Alternative: Wildcard certificate (*.yourportal.org)
   
   ⚠️ **Critical**: Set up DNS and SSL *before* deploying services. Many authentication flows fail without working HTTPS.
   
   [Action Available: Validate Prerequisites - checks DNS resolution, SSL readiness]
   
   Have you configured your domains yet?"

6. **User**: [Responds with DNS status]

7. **AI**: [Continues with next steps: SSH setup, ala-install cloning, inventory configuration]

**Alternative Branch - User Wants Docker**:

- **User**: "Can I use Docker instead?"
- **AI**: "Yes, but with important caveats:
  
  **Docker Compose support is currently experimental** (beta, WIP in ala-install). 
  
  **Pros**:
  - Fewer servers needed (2-3 instead of 5-7)
  - Easier local testing
  - Simplified dependency management (depends_on + healthchecks)
  
  **Cons**:
  - Not yet stable for production
  - Limited community support/documentation
  - May encounter breaking changes as ala-install docker work evolves
  
  **Recommendation**: If this is for **production**, stick with Ansible. If you're **experimenting** or have a **development environment**, Docker is fine.
  
  Which fits your use case?"

- **User**: [Chooses Docker for dev/experiment]
- **AI**: [Provides Docker-specific architecture guidance: 2-3 servers, backend+frontend split, resource requirements]

**Key Points**:
- Defaults to proven Ansible approach
- Clearly flags Docker as experimental/beta
- Gathers infrastructure constraints before prescribing architecture
- Warns about DNS/SSL prerequisites early (prevents common failures)

---

### 4.2 Configuration Validation

**Status**: ✅ UPDATED - Reflects current practices (2026-03-14)  
**Notes**:
- LA Toolkit now **auto-generates** CAS encryption keys (JWKS) during deployment
- No manual key generation required (handled by ala-install)
- AI focuses on other configuration validation (DNS, SSL, database connections, API keys)

**Trigger**: User configuring services in LA Toolkit  
**AI Goal**: Catch configuration errors before deployment

**Flow** (5-7 turns):

1. **AI** (proactive): "I notice you're configuring multiple services. Let me validate your configuration before deployment to catch common issues."

2. **AI**: [Scans configuration for potential issues]
   
   "I found a few items to check:
   
   ⚠️ **DNS Configuration**:
   - Your collectory service is configured for `collections.yourportal.org`
   - Your CAS service expects `auth.yourportal.org`
   - [Action Available: Validate Prerequisites - checks DNS resolution for all configured services]
   
   ⚠️ **SSL Certificates**:
   - HTTPS is required for CAS authentication to work
   - Do you have SSL certificates ready, or should I guide you through Let's Encrypt setup?
   
   ⚠️ **Database Connections**:
   - Collectory, CAS, and other services need database access
   - Are your database servers configured and accessible from service servers?
   
   Which would you like to check first?"

3. **User**: "Check DNS resolution"

4. **AI**: [Executes DNS validation action]
   
   "Checking DNS for your configured services...
   
   ✅ `yourportal.org` → resolves to 203.0.113.10
   ✅ `auth.yourportal.org` → resolves to 203.0.113.11
   ✅ `collections.yourportal.org` → resolves to 203.0.113.12
   ❌ `biocache.yourportal.org` → **FAILED** (NXDOMAIN - not found)
   ❌ `species.yourportal.org` → **FAILED** (NXDOMAIN - not found)
   
   **Action needed**: Configure DNS records for biocache and species subdomains before deploying those services."

5. **User**: "What about the database connections?"

6. **AI**: "Let me check database connectivity...
   
   [Action Available: Validate Prerequisites - tests database connections]
   
   I'll need to SSH to your servers to test connections. This will check:
   - PostgreSQL access for CAS, Collectory (default port 5432)
   - MySQL access if configured (default port 3306)
   - Network firewall rules
   
   Should I proceed?"

7. **User**: [Approves or addresses issues]

**Alternative Scenarios**:

**Scenario A - Missing API Keys**:
- **AI**: "I see you're configuring spatial services. These require API keys for:
  - Google Maps API (for map tiles) - Optional but recommended
  - Bing Maps API (alternative) - Optional
  
  These aren't critical for initial deployment, but spatial analysis features won't work without them. Want to add them now or later?"

**Scenario B - Port Conflicts**:
- **AI**: "⚠️ **Configuration issue detected**: You're deploying both `biocache-service` and `bie-service` to the same server, and both are configured to use port 8080.
  
  **Solutions**:
  1. Deploy to separate servers (recommended)
  2. Change one service to use a different port (e.g., 8081)
  3. Use Nginx reverse proxy to handle routing
  
  Which approach works for your setup?"

**Scenario C - Insufficient Resources**:
- **AI**: "I notice you're deploying Solr, Cassandra, and biocache-service on a server with 8GB RAM.
  
  ⚠️ **Warning**: This configuration may struggle under load:
  - Solr typically needs 4-8GB heap
  - Cassandra needs 2-4GB heap
  - biocache-service needs 2-4GB heap
  - OS overhead: 1-2GB
  
  **Total needed**: 16-24GB RAM (you have 8GB)
  
  **Recommendations**:
  1. Split services across 2 servers (recommended)
  2. Reduce heap sizes (may impact performance)
  3. Upgrade server RAM to 16GB minimum
  
  This won't prevent deployment, but may cause OOM (Out of Memory) errors during data loading."

**Key Points**:
- AI proactively scans configuration for common issues
- Validates external dependencies (DNS, SSL, databases)
- Warns about resource constraints before deployment
- Provides actionable solutions, not just error messages

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

**Status**: ✅ UPDATED - Reflects current practices (2026-03-14)  
**Notes**:
- Covers both Ansible (systemd logs) and Docker Compose (container logs) deployments
- Different log access patterns for each deployment method
- Common error patterns apply to both (but underlying causes may differ)

**Trigger**: User reports service failure/error  
**AI Goal**: Systematic diagnosis using logs and common error patterns

---

#### **Scenario A: Ansible Deployment Log Analysis**

**Flow** (6-10 turns):

1. **User**: "Biocache-hub shows 502 Bad Gateway"

2. **AI**: "502 errors indicate the backend service isn't responding. Let me systematically diagnose:
   
   **Context questions**:
   - Are you using Ansible deployment?
   - Did earlier services (CAS, Collectory, biocache-service) deploy successfully?
   - Any recent configuration changes?
   - What's the exact URL showing the error?"

3. **User**: "Ansible deployment, earlier services working, no changes, https://biocache.myportal.org"

4. **AI**: "Let's check service status and logs.
   
   [Action Available: Analyze Logs - checks biocache-hub service logs via systemd]
   
   This will:
   1. Check if biocache-hub service is running (`systemctl status biocache-hub`)
   2. Pull last 200 lines of logs (`journalctl -u biocache-hub -n 200`)
   3. Search for common error patterns (DB connection, CAS auth, config errors)
   
   Should I proceed?"

5. **User**: [Approves action]

6. **AI**: [SSH to server, executes analysis, returns findings]
   
   "**Analysis Results**:
   
   ✅ Service is running (active since 2 hours ago)
   ❌ **Error found** (repeated 47 times in logs):
   
   ```
   ERROR o.g.web.errors.GrailsExceptionResolver - ConnectException: 
   Connection refused to http://biocache-ws.myportal.org:8080/ws
   ```
   
   **Root Cause**: biocache-hub can't reach biocache-service backend.
   
   **Diagnostic checks**:
   1. Is biocache-service running? Check: `ssh biocache-ws.myportal.org 'systemctl status biocache-service'`
   2. Is firewall blocking port 8080? Check: `curl http://biocache-ws.myportal.org:8080/ws/`
   3. Is biocache-hub configured with correct backend URL?
   
   [Action Available: Validate Prerequisites - checks biocache-service connectivity]
   
   Should I check these automatically?"

7. **User**: "Yes, check them"

8. **AI**: [Runs connectivity checks]
   
   "**Connectivity Test Results**:
   
   ✅ biocache-service is running (systemd shows active)
   ❌ **Port 8080 not accessible** from biocache-hub server
   ✅ biocache-hub config has correct URL
   
   **Problem identified**: Firewall is blocking port 8080 between servers.
   
   **Solution**:
   ```bash
   # On biocache-ws server, allow port 8080
   sudo ufw allow from <biocache-hub-server-ip> to any port 8080
   # OR if using iptables:
   sudo iptables -A INPUT -p tcp -s <biocache-hub-server-ip> --dport 8080 -j ACCEPT
   ```
   
   After opening the port, restart biocache-hub:
   ```bash
   sudo systemctl restart biocache-hub
   ```
   
   Let me know if the 502 error persists after these changes."

---

#### **Scenario B: Docker Compose Log Analysis**

**Flow** (5-8 turns):

1. **User**: "Collectory container keeps restarting"

2. **AI**: "Container restart loops usually indicate:
   - Failed health checks
   - Missing environment variables
   - Database connection failures
   - Port conflicts
   
   Let me check the logs.
   
   [Action Available: Analyze Logs - docker logs for collectory]
   
   This will:
   1. Check container status (`docker ps -a | grep collectory`)
   2. Get last 100 log lines (`docker logs collectory --tail 100`)
   3. Check for exit codes and restart reasons
   
   Should I proceed?"

3. **User**: [Approves]

4. **AI**: [Analyzes Docker logs]
   
   "**Analysis Results**:
   
   Container Status:
   - State: Restarting (exit code 1)
   - Restart count: 23 times in last 10 minutes
   - Last started: 30 seconds ago
   
   **Error found in logs**:
   ```
   Caused by: org.postgresql.util.PSQLException: 
   FATAL: password authentication failed for user "collectory"
   ```
   
   **Root Cause**: Database authentication failure.
   
   **Common causes**:
   1. Wrong DB password in `docker-compose.yml` or `.env` file
   2. Database user not created yet
   3. Database container not fully initialized before collectory started
   
   **Debug steps**:
   
   1. Check environment variables:
   ```bash
   docker exec collectory env | grep -i 'db\|postgres'
   ```
   
   2. Test DB connection manually:
   ```bash
   docker exec -it postgres-container psql -U collectory -d collectory
   ```
   
   3. Check `depends_on` and healthcheck in docker-compose.yml:
   ```yaml
   collectory:
     depends_on:
       postgres:
         condition: service_healthy
   ```
   
   [Action Available: Validate Prerequisites - checks DB connectivity from collectory container]
   
   Want me to run these checks?"

5. **User**: "Yes"

6. **AI**: [Executes checks, identifies wrong password in .env file]
   
   "**Problem found**: The `COLLECTORY_DB_PASSWORD` in your `.env` file doesn't match the password set in the PostgreSQL container.
   
   **Solution**:
   1. Stop the stack: `docker-compose down`
   2. Fix password in `.env` file (make sure it matches `POSTGRES_PASSWORD`)
   3. Restart: `docker-compose up -d`
   
   Alternatively, if you want to reset the database password:
   ```bash
   docker exec -it postgres-container psql -U postgres
   ALTER USER collectory WITH PASSWORD 'new_password_here';
   ```
   
   Then update `.env` to match."

---

#### **Common Error Patterns (Both Deployments)**

**Pattern 1: 502 Bad Gateway**
- **Ansible**: Service not running or unreachable
- **Docker**: Container unhealthy, networking issue, depends_on not working

**Pattern 2: Database Connection Failures**
- **Ansible**: Check `/etc/default/<service>` for DB config, test with `psql` or `mysql` client
- **Docker**: Check `.env` file, container networking, healthchecks

**Pattern 3: Authentication Errors (CAS)**
- **Ansible**: JWKS keys not configured, CAS not reachable
- **Docker**: CAS container not started yet, wrong service URLs in environment

**Pattern 4: Out of Memory (OOM)**
- **Ansible**: Check `journalctl -k | grep -i 'out of memory'`
- **Docker**: Check `docker stats`, look for container restarts due to OOM

**Key Points**:
- AI determines deployment method first (logs accessed differently)
- Systematic approach: status → logs → error pattern → root cause → solution
- Provides specific commands for both systemd and docker
- Links errors to common causes with concrete fixes

---

### 4.5 Data Ingestion Workflow

**Status**: ✅ UPDATED - Reflects current practices (2026-03-14)  
**Notes**:
- **GBIF Pipelines** is now the **recommended** ingestion method
- **biocache-store** is legacy (still supported for existing deployments)
- Pipelines offers better performance, scalability, and data quality

**Trigger**: User wants to add first data resource  
**AI Goal**: Guide through collectory → ingestion → indexing pipeline

**Flow** (10-14 turns):

1. **User**: "How do I add occurrence data?"

2. **AI**: "Great! Let's walk through the data ingestion process. It has 4 main steps:
   
   **Step 1**: Create data resource in Collectory (metadata registry)
   **Step 2**: Upload/link data (DwC-A, CSV, or IPT endpoint)
   **Step 3**: Run ingestion pipeline (processes and validates data)
   **Step 4**: Index into Solr (makes data searchable)
   
   First, what format is your data:
   - **Darwin Core Archive** (DwC-A) - Recommended, standard format
   - **CSV file** - Will be converted to DwC-A
   - **IPT endpoint** - Live connection to IPT publisher
   - **Other format**?"

3. **User**: "Darwin Core Archive"

4. **AI**: "Perfect! DwC-A is the standard format. Now let me explain your ingestion options:
   
   **GBIF Pipelines** (Recommended):
   - ✅ Modern, actively developed
   - ✅ Better data quality checks
   - ✅ Faster for large datasets (1M+ records)
   - ✅ Better handling of multimedia, taxonomy, geocoding
   - ⚠️ Requires more initial setup (Spark, HDFS for large data)
   
   **biocache-store** (Legacy):
   - ⚠️ Older codebase (maintenance mode)
   - ✅ Simpler setup for small deployments
   - ✅ Works well for datasets < 100K records
   - ❌ Slower, less validation
   
   **Recommendation**: Use **Pipelines** unless you have an existing biocache-store deployment or very simple needs.
   
   Which would you like to use?"

5. **User**: "Pipelines, what do I need?"

6. **AI**: "Good choice! GBIF Pipelines requirements:
   
   **Prerequisites**:
   - Apache Spark (for data processing)
   - HDFS or S3-compatible storage (for large datasets)
   - Sufficient disk space (3-5x your data size for intermediate files)
   
   **For small/medium deployments** (< 1M records):
   - Can run in 'standalone' mode without full Hadoop cluster
   - Local filesystem instead of HDFS
   
   Let me check your environment:
   [Action Available: Validate Prerequisites - checks for Spark, Java, disk space]
   
   Should I check your setup?"

7. **User**: [Approves]

8. **AI**: [Checks environment]
   
   "**Environment Check**:
   ✅ Java 11 installed
   ✅ 500GB free disk space on /data
   ❌ Apache Spark not found
   
   **Action needed**: Install Apache Spark (version 3.x recommended)
   
   ```bash
   # Quick install for Debian/Ubuntu
   wget https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz
   tar -xzf spark-3.5.0-bin-hadoop3.tgz
   sudo mv spark-3.5.0-bin-hadoop3 /opt/spark
   
   # Add to PATH
   echo 'export SPARK_HOME=/opt/spark' >> ~/.bashrc
   echo 'export PATH=$PATH:$SPARK_HOME/bin' >> ~/.bashrc
   source ~/.bashrc
   ```
   
   Once Spark is installed, we can proceed with Pipelines setup."

9. **User**: "Spark is installed, what's next?"

10. **AI**: "Excellent! Now let's create your data resource in Collectory and configure Pipelines.
    
    **Step 1: Create Data Resource in Collectory**
    
    1. Navigate to Collectory admin: https://collections.yourportal.org/admin
    2. Click 'Data Resources' → 'Create New'
    3. Fill in:
       - **Name**: Your dataset name (e.g., 'Regional Butterfly Survey 2025')
       - **Description**: Brief description
       - **License**: CC-BY, CC0, or appropriate license
       - **Contact**: Data provider email
    4. Save and note the **Data Resource ID** (e.g., `dr1`, `dr2`, etc.)
    
    Have you created the data resource? If so, what's the DR ID?"

11. **User**: "Created, DR ID is dr5"

12. **AI**: "Perfect! `dr5` is your data resource. Now let's upload your DwC-A and run Pipelines.
    
    **Step 2: Upload Data**
    
    ```bash
    # SSH to your biocache/pipelines server
    ssh biocache-ws.yourportal.org
    
    # Create directory for your data resource
    sudo mkdir -p /data/pipelines-data/dr5
    sudo chown $(whoami):$(whoami) /data/pipelines-data/dr5
    
    # Upload your DwC-A file
    # (Use scp/rsync from your local machine)
    scp your-data.zip biocache-ws.yourportal.org:/data/pipelines-data/dr5/
    
    # Extract if needed
    cd /data/pipelines-data/dr5
    unzip your-data.zip
    ```
    
    **Step 3: Run Pipelines Ingestion**
    
    The Pipelines ingestion runs in phases. Here's the command:
    
    ```bash
    # Navigate to pipelines directory (location may vary)
    cd /opt/pipelines
    
    # Run ingestion for dr5
    ./run-pipelines.sh dr5
    ```
    
    This will:
    1. **Interpret** - Parse Darwin Core fields
    2. **Validate** - Check data quality (coordinates, dates, taxonomy)
    3. **Index** - Load into Solr
    
    **Estimated time**: 
    - Small dataset (< 10K records): 2-5 minutes
    - Medium (100K records): 10-30 minutes  
    - Large (1M+ records): 1-3 hours
    
    Run the ingestion and let me know if you see any errors."

13. **User**: "Ingestion finished! How do I know it worked?"

14. **AI**: "Great! Let's verify the data is searchable:
    
    **Verification Steps**:
    
    1. **Check record count**:
    ```bash
    curl 'https://biocache-ws.yourportal.org/ws/occurrences/search?q=data_resource_uid:dr5&facet=off' | jq '.totalRecords'
    ```
    
    2. **Check in biocache-hub UI**:
    - Navigate to: https://biocache.yourportal.org
    - Search for your dataset: `data_resource_uid:dr5`
    - Should see records with map points
    
    3. **Validate data quality**:
    ```bash
    # Check for data quality flags
    curl 'https://biocache-ws.yourportal.org/ws/occurrences/search?q=data_resource_uid:dr5&facet=true&facets=assertions' | jq '.facetResults[0].fieldResult'
    ```
    
    Common issues to check:
    - **Missing coordinates**: Records without lat/lon won't appear on map
    - **Invalid dates**: Check `assertions` facet for date issues
    - **Unmatched taxonomy**: Check if species names matched to taxonomy
    
    [Action Available: Validate Data Quality - analyzes dr5 for common issues]
    
    Should I run a full data quality check?"

**Alternative Scenario - User Chooses biocache-store**:

- **User**: "I want to use biocache-store (I have an existing deployment)"
- **AI**: "Understood. biocache-store workflow is simpler but older:
  
  **Steps**:
  1. Upload DwC-A to `/data/biocache-load/dr5/`
  2. Run processing: `biocache load dr5`
  3. Run sampling (coordinates → layers): `biocache sample`
  4. Index to Solr: `biocache index dr5`
  
  Note: biocache-store commands require biocache-cli tools installed.
  
  Reference: https://github.com/AtlasOfLivingAustralia/documentation/wiki/Biocache-Load
  
  Want detailed commands for biocache-store?"

**Key Points**:
- Clearly recommends Pipelines as modern approach
- Provides practical setup for Pipelines (not just theory)
- Includes validation steps (critical for first-time users)
- Supports legacy biocache-store for existing deployments
- Explains performance expectations (time estimates)

---

### 4.6 Upgrade Path Planning

**Status**: ✅ DESIGNED - Initial version (2026-03-14)  
**Notes**: 
- Upgrades are high-risk operations requiring careful planning
- Testing in staging environment is critical
- Rollback plan must exist before starting
- Different upgrade types have different risk levels

**Trigger**: User with existing portal wants to upgrade services  
**AI Goal**: Provide safe upgrade paths, prevent breaking changes, ensure rollback capability

**Flow** (12-18 turns):

1. **User**: "I want to upgrade my portal to the latest versions"

2. **AI**: "Portal upgrades need careful planning to avoid downtime. Let me help you create a safe upgrade strategy.
   
   First, let me understand your current environment:
   - Which services are you running? (CAS, biocache-hub, collectory, etc.)
   - What versions are currently deployed? (Check in LA Toolkit or service `/version` endpoints)
   - Do you have a **staging/test environment** to test upgrades first?
   - When was your last successful upgrade?"

3. **User**: "Running CAS 2.0, biocache-hub 3.2, collectory 4.1. No staging environment. Last upgraded 2 years ago."

4. **AI**: "⚠️ **High-risk upgrade detected**: You're running **CAS 2.0**, which is deprecated. Upgrading to **CAS 5** is a **major breaking change**.
   
   **Critical Issues**:
   1. **CAS 2 → CAS 5**: Complete architecture change (OAuth2, JWKS, different authentication flow)
   2. **2 years behind**: Multiple intermediate breaking changes
   3. **No staging**: Can't test safely before production
   
   **Strong Recommendation**: 
   Before upgrading production, you MUST:
   1. **Create staging environment** (clone your production setup)
   2. **Test upgrade path** in staging
   3. **Document rollback procedure**
   4. **Schedule maintenance window** (expect 4-8 hours downtime for CAS upgrade)
   
   **Upgrade Priority Levels**:
   
   🔴 **Critical** (breaking changes, requires careful planning):
   - CAS 2 → CAS 5 (authentication affects all services)
   
   🟡 **Moderate** (may have minor breaking changes):
   - biocache-hub 3.2 → latest (check release notes)
   - collectory 4.1 → latest (schema changes possible)
   
   🟢 **Low Risk** (typically backward compatible):
   - Minor version updates (e.g., 4.1.0 → 4.1.5)
   - Security patches
   
   Should I help you plan this upgrade, or would you prefer to set up staging first?"

5. **User**: "Help me plan it, I'll set up staging later"

6. **AI**: "Understood, but remember: **Do NOT execute these steps on production without testing in staging first.**
   
   Let me create an upgrade plan with risk assessment:
   
   [Action Available: Analyze Upgrade Path - reads current versions from LA Toolkit, checks for breaking changes]
   
   This will:
   1. Identify all services and versions
   2. Check release notes for breaking changes
   3. Create phased upgrade plan
   4. Estimate downtime
   
   Should I analyze your configuration?"

7. **User**: [Approves]

8. **AI**: [Analyzes configuration, generates upgrade plan]
   
   "**Upgrade Plan for Your Portal**
   
   **Current State**:
   - CAS: 2.0.8 (deprecated, EOL)
   - Collectory: 4.1.3
   - biocache-service: 3.1.9
   - biocache-hub: 3.2.1
   - bie-hub: 3.0.5
   - Solr: 7.2 (embedded)
   - Database: PostgreSQL 10
   
   **Target State** (latest stable):
   - CAS: 5.3.x
   - Collectory: 5.0.x
   - biocache-service: 4.2.x
   - biocache-hub: 5.1.x
   - bie-hub: 4.0.x
   - Solr: 8.11.x (external)
   - Database: PostgreSQL 14
   
   ---
   
   **PHASE 1: Pre-Upgrade (Preparation) - 2-3 days**
   
   **Risk**: 🟢 Low (non-destructive)
   
   1. **Full backup** (database, configs, data):
   ```bash
   # Backup databases
   pg_dump collectory > collectory_backup_$(date +%F).sql
   pg_dump cas > cas_backup_$(date +%F).sql
   
   # Backup configs
   tar -czf configs_backup_$(date +%F).tar.gz /etc/ala/
   
   # Backup Solr indexes (if not rebuilding)
   tar -czf solr_backup_$(date +%F).tar.gz /data/solr/
   ```
   
   2. **Document current state**:
   ```bash
   # Save service versions
   curl https://auth.yourportal.org/cas/version > versions_before.txt
   curl https://collections.yourportal.org/version >> versions_before.txt
   # ... repeat for all services
   ```
   
   3. **Test current functionality** (baseline):
   - Login via CAS (screenshot proof)
   - Search occurrences
   - View species page
   - Download data (small test)
   
   4. **Prepare rollback scripts**:
   ```bash
   # Create rollback playbook or docker-compose version pinning
   git checkout <current-version-tag>
   ```
   
   **Deliverable**: Backups verified, rollback tested
   
   ---
   
   **PHASE 2: Infrastructure Upgrades - 1-2 hours downtime**
   
   **Risk**: 🟡 Moderate
   
   1. **Upgrade PostgreSQL 10 → 14**:
   ```bash
   # This is required before upgrading CAS/Collectory
   sudo pg_upgrade ...
   ```
   
   2. **Upgrade Solr 7 → 8** (or migrate to external Solr):
   - May require re-indexing all data (4-12 hours depending on data size)
   
   **Rollback**: Restore database from pg_dump, revert Solr version
   
   ---
   
   **PHASE 3: CAS Upgrade (2 → 5) - 4-6 hours downtime**
   
   **Risk**: 🔴 **CRITICAL** - Breaks authentication for ALL services
   
   **Breaking Changes**:
   - Authentication protocol: CAS 2 tickets → OAuth2 + OIDC
   - Configuration format: XML → YAML/Properties
   - Encryption keys: Custom → JWKS
   - User database schema: Changed (migration required)
   
   **Pre-requisites**:
   1. All services must support CAS 5 (check compatibility)
   2. Generate new JWKS keys (LA Toolkit does this automatically)
   3. Update ALL service configs to point to CAS 5 OAuth2 endpoints
   
   **Steps**:
   1. Stop all services (everything depends on CAS):
   ```bash
   sudo systemctl stop biocache-hub biocache-service collectory bie-hub
   ```
   
   2. Deploy CAS 5:
   ```bash
   cd ala-install
   ansible-playbook -i inventories/your-inventory cas5-playbook.yml
   ```
   
   3. Migrate user database:
   ```bash
   # Run CAS 5 user migration script
   /opt/cas/bin/migrate_users_from_cas2.sh
   ```
   
   4. Test CAS 5 login (manual browser test)
   
   5. Update service configs (biocache-hub, collectory, etc.) to use CAS 5 endpoints
   
   6. Restart services one by one, verify login
   
   **Rollback**: 
   - Restore CAS 2 from backup
   - Revert service configs
   - Restore user database
   - (Estimated rollback time: 30-60 minutes)
   
   ⚠️ **Warning**: If users register/login during CAS 5 trial, rolling back loses that data.
   
   ---
   
   **PHASE 4: Service Upgrades - 2-4 hours downtime**
   
   **Risk**: 🟡 Moderate
   
   Upgrade in dependency order:
   
   1. **Collectory** (4.1 → 5.0):
   - Database schema changes (auto-migration)
   - Config format changes (check ala-install)
   
   2. **biocache-service** (3.1 → 4.2):
   - API changes (check if biocache-hub compatible)
   - May need Solr re-index
   
   3. **biocache-hub** (3.2 → 5.1):
   - UI changes (test thoroughly)
   - New config options
   
   4. **bie-hub** (3.0 → 4.0):
   - Species page redesign
   - Taxonomy index rebuild (2-4 hours)
   
   **Rollback**: Restore service versions via ansible/docker, restore databases
   
   ---
   
   **PHASE 5: Verification & Monitoring - Ongoing**
   
   **Risk**: 🟢 Low
   
   1. **Functional testing** (same as pre-upgrade baseline):
   - Login via CAS 5
   - Search occurrences
   - View species page
   - Download data
   
   2. **Monitor logs for 24-48 hours**:
   ```bash
   journalctl -u cas5 -f
   journalctl -u biocache-hub -f
   ```
   
   3. **Performance comparison**:
   - Search response times
   - Login success rate
   - Error rates
   
   **If issues found**: Execute rollback immediately
   
   ---
   
   **SUMMARY**
   
   **Total Estimated Downtime**: 8-12 hours (mostly CAS upgrade)
   
   **Recommended Timeline**:
   - Week 1: Set up staging, test Phase 1-3
   - Week 2: Test Phase 4-5 in staging
   - Week 3: Schedule production upgrade (weekend or maintenance window)
   
   **Go/No-Go Checklist** (before starting production upgrade):
   - ✅ Full backups verified and tested
   - ✅ Rollback procedure documented and tested in staging
   - ✅ All upgrade phases tested successfully in staging
   - ✅ Maintenance window scheduled and users notified
   - ✅ Team available for entire maintenance window
   - ✅ Emergency contacts ready (ALA community, DevOps team)
   
   **Critical**: Do NOT proceed without staging environment testing. CAS 2→5 upgrade has high failure rate without preparation.
   
   Would you like me to save this plan, or do you have questions about specific phases?"

9. **User**: "What if CAS 5 upgrade fails in production?"

10. **AI**: "Excellent question. CAS failures are **portal-wide** (all services affected), so rollback must be fast.
    
    **Rollback Procedure** (30-60 minutes):
    
    1. **Immediate actions** (do within 5 minutes of detecting failure):
    ```bash
    # Stop CAS 5
    sudo systemctl stop cas5
    
    # Restore CAS 2 database
    sudo -u postgres psql -d cas -f cas_backup_<date>.sql
    
    # Revert CAS 2 service
    cd ala-install
    git checkout cas2-version-tag
    ansible-playbook -i inventories/your-inventory cas2-playbook.yml
    ```
    
    2. **Revert service configs** (all services that point to CAS):
    ```bash
    # Restore old config files (backed up in Phase 1)
    sudo tar -xzf configs_backup_<date>.tar.gz -C /
    
    # Restart services with old CAS 2 endpoints
    sudo systemctl restart biocache-hub collectory bie-hub
    ```
    
    3. **Verify login** (manual test in browser)
    
    4. **Monitor for 1 hour**, check error logs
    
    **Things that can go wrong**:
    - **Rollback database restore fails**: Have secondary backup (offsite)
    - **Services won't start with old config**: Keep complete /etc/ala/ backup
    - **User data created during CAS 5 trial**: Warn users before upgrade (maintenance mode)
    
    **Best Practice**: 
    - Put site in **maintenance mode** during CAS upgrade (custom nginx holding page)
    - Prevents user registrations during upgrade window
    - Simplifies rollback (no lost user data)
    
    Want me to generate a maintenance mode setup?"

11. **User**: "Yes, show me maintenance mode"

12. **AI**: "Here's a simple maintenance mode for your portal:
    
    **1. Create maintenance page**:
    ```html
    <!-- /var/www/maintenance.html -->
    <!DOCTYPE html>
    <html>
    <head>
      <title>Maintenance - Your Portal</title>
      <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #333; }
        .info { color: #666; margin: 20px; }
      </style>
    </head>
    <body>
      <h1>🔧 Portal Maintenance in Progress</h1>
      <p class=\"info\">
        We're upgrading to improve your experience.<br>
        <strong>Expected return:</strong> Sunday, March 16, 2026 at 6:00 PM GMT<br>
        <strong>Reason:</strong> Major authentication system upgrade (CAS 2 → 5)
      </p>
      <p>Thank you for your patience!</p>
    </body>
    </html>
    ```
    
    **2. Enable maintenance mode** (before starting upgrade):
    ```nginx
    # Add to /etc/nginx/sites-available/yourportal.conf
    server {
      server_name yourportal.org *.yourportal.org;
      
      # Maintenance mode - comment out to disable
      location / {
        return 503;
      }
      
      error_page 503 @maintenance;
      location @maintenance {
        root /var/www;
        rewrite ^(.*)$ /maintenance.html break;
      }
    }
    ```
    
    ```bash
    # Apply change
    sudo nginx -t && sudo systemctl reload nginx
    ```
    
    **3. Disable maintenance mode** (after successful upgrade):
    ```bash
    # Comment out the maintenance mode block in nginx config
    sudo nano /etc/nginx/sites-available/yourportal.conf
    sudo systemctl reload nginx
    ```
    
    **Pro tip**: Keep API endpoints accessible for monitoring:
    ```nginx
    # Allow health checks during maintenance
    location /cas/status {
      proxy_pass http://cas-backend;
    }
    location /collectory/health {
      proxy_pass http://collectory-backend;
    }
    ```
    
    This way you can test services without exposing them to users."

**Key Points**:
- AI strongly discourages upgrading without staging environment
- Provides detailed risk assessment for each phase
- Emphasizes rollback planning before starting
- Identifies breaking changes explicitly (CAS 2→5)
- Realistic time estimates (not overly optimistic)
- Maintenance mode guidance to prevent user data loss
- Go/No-Go checklist ensures readiness

---

### 4.7 Customization Guidance

**Status**: ✅ CURRENT  
**Notes**: 
- ALA "no-fork philosophy" remains the recommended approach
- Configuration and CSS overrides preferred over code modifications
- Docker deployments may offer additional customization via environment variables

**Trigger**: User asks about UI/functional modifications  
**AI Goal**: Encourage safe customization patterns, discourage unmaintainable forks

**Flow** (5-8 turns):

1. **User**: "Can I change the homepage layout?"

2. **AI**: "Yes, you can customize your portal! But let me explain the **customization trade-offs** to help you choose the safest approach:
   
   **✅ Safe** (survives upgrades, no maintenance burden):
   - **Branding variables**: Logos, colors, organization name (via LA Toolkit or ala-install config)
   - **CSS overrides**: Custom styles via `skin.css` or theme files
   - **Configuration toggles**: Feature flags, search defaults, map settings
   - **Content pages**: About, help, contact pages via CMS or static content
   
   **⚠️ Risky** (requires ongoing maintenance, breaks on upgrades):
   - **Forking service repos**: Modifying source code directly
   - **GSP template edits**: Changing Grails Server Pages (`.gsp` files)
   - **Custom controllers/services**: Adding Java/Groovy code
   
   **ALA Philosophy**: [The No-Fork Path](https://github.com/AtlasOfLivingAustralia/documentation/wiki/The-ALA-No%E2%80%90Fork-Path)
   - Configuration > CSS > Templates > Code
   - Try least-invasive approach first
   
   What specifically do you want to change about the homepage?"

3. **User**: "Just rearrange homepage sections"

4. **AI**: "Rearranging sections typically requires template modifications (GSP files), which is **risky** because:
   - Templates change between versions
   - Your modifications break during upgrades
   - You must manually merge changes with each update
   
   **Safer alternatives**:
   
   **Option 1: Custom Landing Page** (Recommended)
   - Create a custom static landing page (HTML/CSS)
   - Host it as your portal homepage (`yourportal.org`)
   - Link to standard biocache/species search interfaces
   - Many LA portals do this: custom landing, standard search
   
   **Option 2: CMS Integration**
   - Use Wordpress/Drupal/ALA CMS for homepage
   - Integrate with biocache-hub for search functionality
   - Reference: https://github.com/AtlasOfLivingAustralia/documentation/wiki/CMS-integration
   
   **Option 3: CSS-only Reordering**
   - Sometimes you can reorder sections with CSS `order` property (flexbox/grid)
   - Won't work for all layouts, but worth trying
   
   **Option 4: Fork and Maintain** (Last resort)
   - Fork biocache-hub, modify templates
   - Accept ongoing maintenance burden
   - Document changes carefully
   
   Which approach fits your needs?"

5. **User**: "Option 1 sounds good, how do I do that?"

6. **AI**: "Great choice! Custom landing pages are very common. Here's the setup:
   
   **Architecture**:
   ```
   yourportal.org → Custom landing page (static HTML/CSS)
   yourportal.org/search → biocache-hub (occurrences)
   yourportal.org/species → bie-hub (species)
   ```
   
   **Implementation Steps**:
   
   1. **Create landing page**:
   ```bash
   # On your branding/web server
   mkdir -p /var/www/landing
   cd /var/www/landing
   
   # Create index.html with your custom layout
   # Include links to /search and /species
   ```
   
   2. **Configure Nginx routing**:
   ```nginx
   server {
     server_name yourportal.org;
     
     # Custom landing page
     location = / {
       root /var/www/landing;
       index index.html;
     }
     
     # Biocache search
     location /search {
       proxy_pass http://biocache-hub-backend:8080;
     }
     
     # Species pages
     location /species {
       proxy_pass http://bie-hub-backend:8080;
     }
     
     # Static assets for landing
     location /assets {
       root /var/www/landing;
     }
   }
   ```
   
   3. **Design tips**:
   - Use ALA brand colors for consistency
   - Prominently feature search box (links to /search)
   - Include recent observations, featured species
   - Link to collections (/collectory), spatial (/spatial)
   
   **Example portals with custom landings**:
   - GBIF.org (custom homepage, standard occurrence search)
   - Many national LA nodes
   
   This keeps upgrades simple while giving you full design freedom."

7. **User**: "What if I need to change search filters?"

8. **AI**: "Search customization is often configuration-based (safe!):
   
   **Common search customizations** (no code changes):
   
   1. **Default filters/facets**:
   ```yaml
   # In biocache-hub config
   facets: ["basis_of_record", "taxon_name", "year", "state_conservation"]
   default_search_query: "country:Colombia"
   ```
   
   2. **Hidden features**:
   ```yaml
   # Hide specific functionality
   downloads_enabled: false
   sensitive_data_visible: false
   ```
   
   3. **Map defaults**:
   ```yaml
   map_default_center: [-35.0, 149.0]
   map_default_zoom: 5
   ```
   
   4. **Custom data quality filters**:
   ```yaml
   data_quality_preset: "strict"  # or "relaxed", "custom"
   ```
   
   Most portal differences come from **data** (species lists, regions) and **configuration**, not code changes.
   
   Reference: https://github.com/AtlasOfLivingAustralia/biocache-hubs/blob/master/grails-app/conf/application.yml
   
   What specific search behavior do you want to change?"

**Key Points**:
- AI actively discourages forking unless truly necessary
- Provides concrete alternatives (custom landing, CMS, CSS)
- Explains maintenance consequences clearly
- Links to ALA documentation on no-fork philosophy
- Encourages configuration-first approach

---

### 4.8 Proactive Monitoring

**Status**: ✅ DESIGNED - Future phase (Phase 5, weeks 12-13)  
**Notes**: 
- Requires backend monitoring infrastructure (health checks, log aggregation)
- AI proactively suggests actions based on detected anomalies
- User always has control (approve/dismiss warnings)
- Not MVP feature, but enhances user experience significantly

**Trigger**: AI detects potential issues via periodic health checks  
**AI Goal**: Warn users before failures occur, suggest preventive actions

**Implementation Requirements**:

1. **Backend Monitoring Service** (`api/services/HealthMonitorService.js`):
   - Periodic health checks (every 5-15 minutes)
   - Collects metrics: disk space, service status, SSL expiry, error rates
   - Stores historical data for trend analysis
   
2. **Alert Thresholds** (configurable):
   - Disk space < 10% free
   - SSL expires within 30 days
   - Service response time > 5 seconds
   - Error rate > 5% of requests
   - Failed health checks (3 consecutive)

3. **AI Context Injection**:
   - Recent alerts added to AI conversation context
   - AI suggests relevant actions based on alert type
   - User can ask "What's my portal health?" anytime

---

#### **Scenario A: Disk Space Warning**

**Flow** (3-5 turns):

1. **AI** (proactive notification): "⚠️ **Alert**: Disk space on `biocache-ws.yourportal.org` is running low (8% free, 23GB remaining).
   
   This server hosts Solr indexes. Running out of space will cause:
   - Search failures
   - Data ingestion failures
   - Service crashes
   
   **Estimated time until full**: 4-6 days (based on current data growth rate)
   
   [Action Available: Analyze Logs - check what's consuming space]
   
   Would you like me to investigate?"

2. **User**: "Yes, what's using the space?"

3. **AI**: [Runs disk analysis via SSH]
   
   "**Disk Usage Analysis** for /data partition:
   
   ```
   /data/solr/biocache/              → 145GB (60%)
   /data/pipelines-data/             → 82GB (34%)
   /data/logs/                       → 12GB (5%)
   /data/backups/ (old backups)      → 3GB (1%)
   ```
   
   **Findings**:
   - Solr index is normal size for your dataset
   - Pipelines intermediate files not cleaned up (82GB!)
   - Old backups taking space
   
   **Recommendations**:
   
   1. **Quick fix** (frees ~85GB, safe):
   ```bash
   # Clean up old pipelines intermediate files
   find /data/pipelines-data -name '*.avro' -mtime +30 -delete
   find /data/pipelines-data -name 'tmp_*' -delete
   
   # Remove old backups (keep last 3)
   cd /data/backups
   ls -t | tail -n +4 | xargs rm -rf
   ```
   
   2. **Long-term fix**:
   - Add cron job to auto-clean pipelines files monthly
   - Set up backup rotation policy
   - Consider expanding disk or archiving old data
   
   [Action Available: Generate Config - creates cron job for automatic cleanup]
   
   Should I create the cleanup cron job for you?"

4. **User**: "Yes, create it"

5. **AI**: [Generates cron job configuration]
   
   "Created cleanup cron job. To install:
   
   ```bash
   # SSH to biocache-ws server
   ssh biocache-ws.yourportal.org
   
   # Add cron job (runs monthly on 1st at 3 AM)
   sudo crontab -e
   
   # Add this line:
   0 3 1 * * find /data/pipelines-data -name '*.avro' -mtime +30 -delete && find /data/pipelines-data -name 'tmp_*' -delete
   ```
   
   This will automatically clean up old pipelines files monthly.
   
   **Immediate action**: Run the cleanup commands now to free space immediately.
   
   I'll continue monitoring disk space and alert you if it goes below 10% again."

---

#### **Scenario B: SSL Certificate Expiring Soon**

**Flow** (2-4 turns):

1. **AI** (proactive notification, 25 days before expiry): "⚠️ **Alert**: SSL certificate for `auth.yourportal.org` expires in **25 days** (April 10, 2026).
   
   Services affected:
   - CAS authentication (auth.yourportal.org)
   - All services depending on CAS (entire portal)
   
   **Impact if expires**: Portal-wide authentication failures, users can't log in.
   
   Are you using **Let's Encrypt** (auto-renewal) or **manual certificates**?"

2. **User**: "Let's Encrypt, I thought it auto-renewed?"

3. **AI**: "Let's Encrypt **should** auto-renew, but something may be blocking it. Let me check:
   
   [Action Available: Validate Prerequisites - checks certbot status and renewal config]
   
   Should I investigate?"

4. **User**: [Approves]

5. **AI**: [Checks certbot status]
   
   "**Problem found**: Certbot auto-renewal is failing.
   
   **Error** (from `/var/log/letsencrypt/letsencrypt.log`):
   ```
   Challenge failed for domain auth.yourportal.org
   HTTP-01 challenge failed: Connection refused (port 80 blocked)
   ```
   
   **Root cause**: Firewall is blocking port 80, which Let's Encrypt uses for renewal verification.
   
   **Solution**:
   
   1. **Option A - Allow port 80 temporarily for renewal**:
   ```bash
   # On auth server
   sudo ufw allow 80/tcp
   
   # Test renewal
   sudo certbot renew --dry-run
   
   # If successful, close port 80 after renewal (optional)
   sudo ufw delete allow 80/tcp
   ```
   
   2. **Option B - Use DNS-01 challenge** (no port 80 needed):
   ```bash
   # Requires DNS provider API access
   sudo certbot renew --preferred-challenges dns-01
   ```
   
   **Recommendation**: Use Option A (simpler). Port 80 only needs to be open during renewal (once every 60 days).
   
   After fixing, certbot should auto-renew successfully. I'll continue monitoring SSL expiry dates."

---

#### **Scenario C: Service Performance Degradation**

**Flow** (4-6 turns):

1. **AI** (proactive notification): "⚠️ **Performance Alert**: `biocache-service` response times have increased significantly over the past 3 days:
   
   - **Normal**: 150-300ms average
   - **Current**: 2.5 seconds average (8x slower)
   
   Users are experiencing slow search results. Would you like me to diagnose?"

2. **User**: "Yes, what's wrong?"

3. **AI**: [Analyzes service logs and metrics]
   
   "**Diagnosis**:
   
   1. **Solr query times** (checked via Solr admin):
   - Average query time: 2.2 seconds (normal: 100-200ms)
   - Query cache hit rate: 12% (normal: 60-80%)
   
   2. **Recent changes**:
   - Large data ingestion 4 days ago (500K records added)
   - Solr index not optimized after ingestion
   
   **Root cause**: Solr index fragmentation after large ingestion.
   
   **Solution**:
   
   ```bash
   # SSH to biocache-ws server
   ssh biocache-ws.yourportal.org
   
   # Optimize Solr index (this improves query speed)
   curl 'http://localhost:8983/solr/biocache/update?optimize=true'
   ```
   
   **Warning**: Optimization takes 30-60 minutes and increases CPU usage temporarily. Best to run during low-traffic hours.
   
   **Expected result**: Search response times return to 150-300ms.
   
   Should I schedule this optimization for tonight at 2 AM, or run it now?"

4. **User**: "Schedule for tonight"

5. **AI**: "Optimization scheduled for tonight (2 AM).
   
   I'll create a cron job and monitor the results:
   
   ```bash
   # Will be added to crontab on biocache-ws server:
   0 2 * * * curl 'http://localhost:8983/solr/biocache/update?optimize=true' >> /var/log/solr-optimize.log 2>&1
   ```
   
   I'll check response times tomorrow morning and report back if the issue is resolved.
   
   **Future prevention**: After large data ingestions (> 100K records), always optimize Solr to maintain performance."

---

#### **Scenario D: Failed Data Ingestion**

**Flow** (3-5 turns):

1. **AI** (proactive notification): "⚠️ **Ingestion Alert**: Data resource `dr12` ingestion failed 3 times in the past 24 hours.
   
   **Error pattern** (from pipelines logs):
   ```
   TaxonomyMatchException: Unable to match 87% of species names
   ```
   
   This data resource won't appear in searches until ingestion succeeds.
   
   [Action Available: Analyze Logs - full diagnostic]
   
   Should I investigate?"

2. **User**: "Yes"

3. **AI**: [Analyzes pipelines logs and data quality]
   
   "**Problem**: The Darwin Core Archive has taxonomy issues.
   
   **Details**:
   - Total records: 12,450
   - Records with unmatched taxonomy: 10,832 (87%)
   - Common unmatched names: 'Quercus robur', 'Pinus sylvestris', etc.
   
   **Root cause**: Your **taxonomy backbone** is outdated or missing these common European species.
   
   **Solutions**:
   
   1. **Update taxonomy backbone** (recommended):
   ```bash
   # Download latest GBIF taxonomy
   cd /opt/ala-namematching
   ./update-taxonomy.sh
   ```
   
   2. **Use custom name matching rules**:
   - Add manual mappings for common unmatched names
   
   3. **Ingest anyway** (skip taxonomy matching):
   ```bash
   # Ingest without strict taxonomy validation
   ./run-pipelines.sh dr12 --skip-taxonomy-validation
   ```
   
   **Recommendation**: Option 1 (update taxonomy). This fixes the issue for all future ingestions too.
   
   Should I guide you through updating the taxonomy backbone?"

---

#### **Scenario E: User Asks "Is My Portal Healthy?"**

**Flow** (2-3 turns):

1. **User**: "Is my portal healthy?"

2. **AI**: [Queries HealthMonitorService for current status]
   
   "**Portal Health Report** (as of March 14, 2026 10:45 AM):
   
   **✅ Services Status** (all healthy):
   - CAS (auth.yourportal.org): ✅ Responding (120ms)
   - Collectory (collections.yourportal.org): ✅ Responding (95ms)
   - biocache-service (biocache-ws.yourportal.org): ✅ Responding (220ms)
   - biocache-hub (biocache.yourportal.org): ✅ Responding (180ms)
   - bie-hub (species.yourportal.org): ✅ Responding (150ms)
   
   **✅ SSL Certificates**:
   - All certificates valid for 180+ days
   
   **⚠️ Disk Space** (1 warning):
   - biocache-ws: 8% free (23GB) - See alert above
   - All other servers: > 30% free
   
   **✅ Recent Data Ingestions**:
   - Last 7 days: 3 successful ingestions
   - No failed ingestions
   
   **✅ Error Rates**:
   - Last 24 hours: 0.3% error rate (normal)
   - No unusual spikes
   
   **Overall Status**: 🟡 **Mostly Healthy** (1 warning: low disk space on biocache-ws)
   
   Recommendation: Address the disk space warning to prevent future issues."

---

**Key Points**:
- AI monitors continuously in background (not intrusive)
- Proactive alerts appear in chat when issues detected
- User always in control (approve suggested actions)
- AI provides context + severity + time estimates
- Suggests preventive actions (cron jobs, policies)
- "Is my portal healthy?" provides overview anytime
- Alerts are actionable (not just informational)

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
