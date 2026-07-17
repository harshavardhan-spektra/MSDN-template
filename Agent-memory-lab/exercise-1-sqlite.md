# Exercise 1: Agent Memory with SQLite

**Estimated Duration:** 80 minutes

SQLite is Agent Memory's zero-config default backend — no external resources required. This exercise is where you learn the core concepts (turns, context, persistence) before adding cloud backends in later exercises.

---

## Task 1: Configure Agent Memory Environment

**Estimated Duration:** 15 minutes

**Steps:**
1. Review the repository structure — note the `memory/` package, any `examples/` folder, and the docs under `docs/` (served via MkDocs).
2. Create the Python virtual environment and install dependencies:
   ```bash
   git clone https://github.com/james-tn/agent-memory.git
   cd agent-memory
   uv sync --extra dev --extra docs
   ```
3. Install/verify required packages resolved correctly:
   ```bash
   uv run python -c "import memory; print('agent-memory ready')"
   ```
4. Configure your `.env` file with the Azure OpenAI endpoint, deployment names, and API key provided by your organization (see the top-level `00-README.md` for the exact variable names).

**Checklist:**
- [ ] `uv sync` completes with no errors
- [ ] `import memory` succeeds
- [ ] `.env` file is present in the repo root with all required values filled in

---

## Task 2: Configure SQLite Backend

**Estimated Duration:** 15 minutes

**Steps:**
1. Update your configuration (or script) to explicitly use the SQLite backend. If a `DatabaseType` enum is exposed, this is the default and typically needs no extra parameters:
   ```python
   from memory import AgentMemory

   memory = AgentMemory(user_id="user-101", openai_client=client)
   # SQLite is the default backend — no db_type parameter needed
   ```
2. Locate where the local `.db` file is written (repo root or a configured data directory) — note the path so you can inspect it later in Task 5.
3. Run a minimal script to confirm `AgentMemory` initializes without errors:
   ```python
   import asyncio
   from openai import AzureOpenAI
   from memory import AgentMemory

   client = AzureOpenAI(
       azure_endpoint="https://your-resource.openai.azure.com/",
       api_key="your-key",
       api_version="2025-04-01-preview",
   )

   async def main():
       async with AgentMemory(user_id="user-101", openai_client=client) as memory:
           print("Agent Memory initialized on SQLite")

   asyncio.run(main())
   ```
4. Note why SQLite is a good default for learning: no credentials to manage, no network dependency, and behavior is easy to inspect directly in the `.db` file.

**Checklist:**
- [ ] Script runs and prints the initialization message with no errors
- [ ] You know the local `.db` file path

---

## Task 3: Run SQLite Demo

**Estimated Duration:** 15 minutes

**Steps:**
1. Locate and execute the repo's SQLite demo application (check `examples/` or the README for the exact command — a likely form is shown below; adjust to match what's actually in the repo):
   ```bash
   uv run python examples/sqlite_demo.py
   ```
2. Verify the agent/demo starts successfully and reaches a ready state (e.g. a prompt or "ready" message in the console).
3. Review the application logs printed to the console for anything unexpected.
4. Confirm memory initialization messages appear (e.g. backend selected, user_id in use).

**Checklist:**
- [ ] Demo starts with no errors
- [ ] Console shows the backend as SQLite
- [ ] You can see where to type input to interact with the agent

---

## Task 4: Interact with the AI Agent

**Estimated Duration:** 20 minutes

**Steps:**
1. With the demo (or your own script from Task 2) running, send the following messages **in order**, one at a time, reading the agent's reply after each:
   ```text
   1. Hi, my name is Priya and I'm a backend engineer on the payments team.
   2. I mostly write Python and use PostgreSQL for our main database.
   3. My coffee order is a flat white, no sugar, if that ever comes up.
   4. We're migrating one service from REST to gRPC next quarter.
   ```
2. Now ask a **follow-up question that only makes sense if the agent remembered the earlier turns**:
   ```text
   5. Based on what you know about me, what should I keep in mind for that migration?
   ```
3. Observe whether the reply references your role, tech stack, or the migration detail from turn 4 — this is the memory-aware response you're validating.
4. Optional stretch: ask a second follow-up that depends on turn 3 instead:
   ```text
   6. If you were getting me a coffee, what would you order?
   ```

**Checklist:**
- [ ] The reply to prompt 5 clearly reflects information from earlier turns
- [ ] You did not have to repeat any earlier fact yourself for the agent to use it

---

## Task 5: Validate SQLite Memory

**Estimated Duration:** 15 minutes

**Steps:**
1. Open the local SQLite database file from Task 2 with a SQLite browser or the CLI:
   ```bash
   sqlite3 path/to/your.db
   .tables
   SELECT * FROM <turns-or-sessions-table>;
   ```
2. Verify the conversation records from Task 4 are present (look for the text you typed in prompts 1–4).
3. **Fully stop and restart** the demo/script (kill the process, start it again with the same `user_id="user-101"`).
4. Send only the follow-up question again, without repeating any earlier fact:
   ```text
   Based on what you know about me, what should I keep in mind for that migration?
   ```
5. Compare this response to the one from Task 4 — confirm the memory survived the full application restart, proving persistence (not just in-memory state within a single run).

**Checklist:**
- [ ] Records from Task 4 are visible directly in the SQLite database
- [ ] After a full restart, the agent still answers correctly using the earlier facts
- [ ] You can articulate the difference between "context available during a running process" and "memory that persists across restarts"
