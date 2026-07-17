# Exercise 2: Agent Memory with Azure Cosmos DB

**Estimated Duration:** 90 minutes

Cosmos DB is the "production-style" backend for this lab — a managed, network-hosted store instead of a local file. The Agent Memory API stays identical to Exercise 1; only the backend configuration changes.

> **Before you start:** Confirm with your facilitator that a Cosmos DB database and container already exist, with a partition key already defined. Partition key choice cannot be changed after the container is created, so this must be set up in advance, not during the lab.

---

## Task 1: Configure Azure Cosmos DB

**Estimated Duration:** 20 minutes

**Steps:**
1. Review the Azure Cosmos DB resource provisioned by your organization — note the account endpoint, database name, and container name.
2. Configure the endpoint and credentials in your `.env` file (add these alongside your existing Azure OpenAI values):
   ```bash
   AZURE_COSMOS_ENDPOINT=https://your-cosmos-account.documents.azure.com:443/
   AZURE_COSMOS_KEY=your-cosmos-key
   AZURE_COSMOS_DATABASE=agent-memory-db
   AZURE_COSMOS_CONTAINER=agent-memory-container
   ```
3. Update your Agent Memory configuration to reference these values (exact parameter names may differ slightly — check the repo's Cosmos DB backend module or MkDocs reference):
   ```python
   import os
   from memory import AgentMemory
   from memory.db import DatabaseType

   memory = AgentMemory(
       user_id="user-201",
       openai_client=client,
       db_type=DatabaseType.AZURE_COSMOS_DB,
       cosmos_endpoint=os.environ["AZURE_COSMOS_ENDPOINT"],
       cosmos_key=os.environ["AZURE_COSMOS_KEY"],
   )
   ```
4. Verify connectivity with a minimal round trip:
   ```python
   async def main():
       async with memory:
           await memory.add_turn("Connectivity check.", "Connected.")
           print(await memory.get_context())
   ```

**Checklist:**
- [ ] `.env` contains valid Cosmos DB connection values
- [ ] The connectivity check runs with no authentication or connection errors

---

## Task 2: Switch Backend to Cosmos DB

**Estimated Duration:** 15 minutes

**Steps:**
1. Take your working script or demo entry point from Exercise 1 and change **only** the `AgentMemory` construction to use `DatabaseType.AZURE_COSMOS_DB` as shown in Task 1 — do not change any of the surrounding application logic.
2. Confirm the rest of your code (the part that calls `add_turn()` / `get_context()`, or drives the demo conversation) is untouched.
3. Restart the application/script from a clean process.
4. Verify Cosmos DB initialization — look for a log line or printed confirmation showing the active backend is Cosmos DB, not SQLite.

**Checklist:**
- [ ] Only the backend configuration line(s) changed
- [ ] Application starts cleanly against Cosmos DB
- [ ] You can confirm from logs/output which backend is active

---

## Task 3: Run Cosmos DB Demo

**Estimated Duration:** 15 minutes

**Steps:**
1. Locate and run the repo's production-style demo (adjust the command to match what's actually in the repo):
   ```bash
   uv run python examples/cosmos_demo.py
   ```
2. Verify the demo executes successfully end to end.
3. Observe the application logs for the Cosmos DB connection and any request/response details.
4. Confirm memory operations (writes and reads) are completing without errors.

**Checklist:**
- [ ] Demo runs without errors
- [ ] Logs confirm reads/writes are happening against Cosmos DB

---

## Task 4: Interact with the AI Agent

**Estimated Duration:** 20 minutes

**Steps:**
1. Start a **new conversation** under a fresh `user_id` (e.g. `user_id="user-202"`) and send:
   ```text
   1. I'm allergic to shellfish, so please keep that in mind for any food-related suggestions.
   2. I work East Coast hours, roughly 8am to 4pm Eastern.
   3. My favorite programming language is Rust, though I use Python daily for work.
   ```
2. **Fully end that session/process.** Then start a **new script run**, using the same `user_id="user-202"`, and retrieve previously stored memories with a question that depends on turn 1:
   ```text
   4. If you were going to suggest a lunch spot for a meeting with me, what should you keep in mind?
   ```
3. Validate that the response correctly surfaces the shellfish allergy without you having restated it.
4. To demonstrate a persistent, ongoing conversation, continue in the same new process with a follow-up:
   ```text
   5. What about my working hours — does that affect when you'd suggest we meet?
   ```

**Checklist:**
- [ ] The recall question (turn 4) correctly reflects a fact from a completely separate process run
- [ ] The follow-up (turn 5) shows the conversation continuing naturally with prior context intact

---

## Task 5: Validate Cosmos DB Memory

**Estimated Duration:** 20 minutes

**Steps:**
1. Open the Azure Portal (or Azure Cosmos DB Data Explorer / VS Code extension) and navigate to your container.
2. Review the stored memory documents for `user_id="user-202"` — identify the fields holding turns, summaries, and any extracted facts.
3. Compare this document-based storage model to the SQLite implementation from Exercise 1:
   - What's stored as rows in SQLite vs. as JSON documents in Cosmos DB?
   - Is the partition key visible on each document, and does it match your `user_id`?
4. Confirm this qualifies as production-ready persistence: the data survives process restarts, is centrally hosted (not tied to one local machine), and is inspectable/auditable through the Azure Portal.

**Checklist:**
- [ ] You can locate and read the stored documents directly in the Cosmos DB container
- [ ] You can explain at least one concrete difference between the SQLite and Cosmos DB storage models
- [ ] You understand why this backend is the better choice for a real, multi-user deployment
