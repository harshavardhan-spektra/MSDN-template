# Task 1: Environment Setup

**Estimated Duration:** 15 minutes

## Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/james-tn/agent-memory.git
   cd agent-memory
   ```

2. **Install dependencies with `uv`**
   ```bash
   uv sync --extra dev
   ```
   If `uv` isn't installed: `pip install uv --break-system-packages` (or follow the [uv install docs](https://docs.astral.sh/uv/getting-started/installation/)).

3. **Create your `.env` file**
   ```bash
   cp .env.example .env
   ```
   Then edit `.env` and set:
   ```
   AZURE_OPENAI_ENDPOINT=https://<your-resource>.openai.azure.com/
   AZURE_OPENAI_API_KEY=<your-key>
   AZURE_OPENAI_API_VERSION=2024-08-01-preview
   AZURE_OPENAI_REASONING_DEPLOYMENT=<your-chat-model-deployment>
   AZURE_OPENAI_EMBEDDING_DEPLOYMENT=<your-embedding-deployment>
   ```

4. **Select your backend**
   In `.env`, set:
   ```
   AGENT_MEMORY_DB_TYPE=sqlite
   ```
   (Valid values: `sqlite`, `azure_ai_search`, `postgresql`, `cosmos_db` — used later in Exercise 2.)

## Checkpoint
- [ ] Repo cloned and dependencies installed
- [ ] `.env` file created and populated
- [ ] Backend type set to `sqlite`
