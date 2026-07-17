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

# Task 2: Quick Start with Local SQLite

**Estimated Duration:** 15 minutes

## Steps

1. **Create a Python script** `quickstart.py` in the repo root:
   ```python
   import asyncio
   from memory import AgentMemory

   async def main():
       memory = AgentMemory(db_type="sqlite", db_path="local_memory.db")

       # Add a conversation turn
       await memory.add_turn(
           session_id="demo-session",
           user_message="My favorite programming language is Python.",
           assistant_message="Got it — I'll remember that you prefer Python."
       )

       # Retrieve context
       context = await memory.get_context(session_id="demo-session", query="What language do I like?")
       print(context)

   asyncio.run(main())
   ```

2. **Run it**
   ```bash
   uv run python quickstart.py
   ```

3. **Verify persistence**
   ```bash
   sqlite3 local_memory.db ".tables"
   sqlite3 local_memory.db "SELECT * FROM turns LIMIT 5;"
   ```
   Confirm your turn was written to disk.

4. **Re-run the retrieval only** (comment out `add_turn`, rerun) to confirm the context still returns your stored preference after the script restarts.

## Checkpoint
- [ ] Turn added successfully
- [ ] Context retrieval returns the stored preference
- [ ] Data confirmed present in `local_memory.db`

# Task 3: Integrating with Microsoft Agent Framework

**Estimated Duration:** 20 minutes

## Steps

1. **Install the Agent Framework** (if not already part of `uv sync`):
   ```bash
   uv add agent-framework
   ```

2. **Create `agent_demo.py`**:
   ```python
   import asyncio
   from agent_framework.azure import AzureOpenAIChatClient
   from agent_framework import Agent
   from memory import AgentMemory

   async def main():
       memory = AgentMemory(db_type="sqlite", db_path="local_memory.db")

       chat_client = AzureOpenAIChatClient(
           endpoint="<your-endpoint>",
           api_key="<your-key>",
           deployment_name="<your-chat-deployment>"
       )

       agent = Agent(
           chat_client=chat_client,
           context_providers=[memory]
       )

       response = await agent.run(
           session_id="demo-session",
           message="What programming language did I say I liked?"
       )
       print(response)

   asyncio.run(main())
   ```

3. **Run it**
   ```bash
   uv run python agent_demo.py
   ```

4. **Test recall across turns**
   Send a new message in the same session (e.g., "What's my favorite language again?") and confirm the agent correctly recalls "Python" from Task 2's stored turn.

## Checkpoint
- [ ] Agent successfully wired with `AgentMemory` as a context provider
- [ ] Agent response reflects memory-aware context
- [ ] Recall confirmed across multiple turns in the same session

# Task 4: Validating the Architecture

**Estimated Duration:** 10 minutes

## Steps

1. **Enable debug logging** to trace the pipeline. Add to the top of any script:
   ```python
   import logging
   logging.basicConfig(level=logging.DEBUG)
   ```

2. **Re-run `agent_demo.py`** from Task 3 and watch the log output for calls through:
   - `MemoryOrchestrator` — coordinates the overall memory flow
   - `MemoryKeeper` — writes/reads raw turns
   - `FactRetrieval` — pulls relevant facts for the current query
   - `Reflection` — generates longer-term summaries/insights

3. **Inspect stored session summaries**
   ```bash
   sqlite3 local_memory.db "SELECT * FROM summaries LIMIT 5;"
   sqlite3 local_memory.db "SELECT * FROM insights LIMIT 5;"
   ```

4. **Repeat the same query flow against a second backend later** (Exercise 2) and confirm the `AgentMemory` API surface (`add_turn`, `get_context`) behaves identically regardless of which backend is configured.

## Checkpoint
- [ ] Debug logs show the full orchestration path
- [ ] Session summaries/insights visible in the database
- [ ] Confirmed API consistency across backends (to be finished in Exercise 2)
