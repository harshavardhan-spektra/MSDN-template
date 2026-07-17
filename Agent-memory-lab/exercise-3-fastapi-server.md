# Exercise 3: Agent Memory with FastAPI Server Mode

**Estimated Duration:** 70 minutes

This exercise reuses the **Cosmos DB backend from Exercise 2** — but instead of your script calling `AgentMemory` in-process, it goes through a FastAPI service over HTTP. Same production backend, different (remote) access pattern. This combination is also this lab's capstone: by the end of Task 5, you'll have proven the full path — server → Cosmos DB → back to a remote client — works end to end.

---

## Task 1: Configure FastAPI Service

**Estimated Duration:** 15 minutes

**Steps:**
1. Review the repo's FastAPI server project/module (check for a `memory/server.py`, a `server/` folder, or a console script entry point in the README).
2. Configure the service settings so it points at the **same Cosmos DB backend** from Exercise 2 — reuse the `AZURE_COSMOS_*` values already in your `.env` file. Do **not** point this at SQLite; the point of this exercise is remote access to the production backend.
3. Confirm the service's configuration (env vars, config file, or startup arguments) explicitly references `DatabaseType.AZURE_COSMOS_DB`.
4. Validate the configuration by checking whatever startup validation the server performs (a `--check-config` flag, a dry-run mode, or simply reading the startup log once you launch it in Task 2).

**Checklist:**
- [ ] The server's backend configuration points at Cosmos DB, not SQLite
- [ ] `.env` values are shared/reused from Exercise 2, not duplicated with different settings

---

## Task 2: Start the Memory Server

**Estimated Duration:** 15 minutes

**Steps:**
1. Launch the FastAPI server in its own terminal (leave this terminal running for the rest of the exercise):
   ```bash
   uv run python -m memory.server
   # or, if the repo exposes a console script:
   uv run agent-memory-server
   ```
2. Verify the REST API is available — check the console for a "listening on" message, and/or open the interactive docs in a browser:
   ```text
   http://localhost:8000/docs
   ```
3. Review the startup logs for the backend confirmation (it should say Cosmos DB, matching Task 1).
4. Confirm the service reports healthy (a `/health` endpoint if one exists, or a successful docs page load).

**Checklist:**
- [ ] Server process is running and left open in its own terminal
- [ ] `/docs` (or equivalent) loads in a browser
- [ ] Startup logs confirm Cosmos DB as the active backend

---

## Task 3: Connect Using MemoryServiceClient

**Estimated Duration:** 15 minutes

**Steps:**
1. In a **second terminal**, write a short client script:
   ```python
   from memory.client import MemoryServiceClient

   client = MemoryServiceClient(base_url="http://localhost:8000")
   ```
2. Test connectivity with a simple call (adjust to whatever health/ping method the client exposes, or fall back to a trivial `add_turn`):
   ```python
   client.add_turn(user_id="server-demo", user_msg="Connectivity check.", agent_msg="Connected.")
   print(client.get_context(user_id="server-demo"))
   ```
3. Verify the client initializes without errors and the call above returns a response instead of a connection error.
4. Confirm in the **server's** terminal (from Task 2) that the request was logged/received.

**Checklist:**
- [ ] Client script runs with no connection errors
- [ ] The request shows up in the server's own logs, proving it went over HTTP and not in-process

---

## Task 4: Access Memory Remotely

**Estimated Duration:** 15 minutes

**Steps:**
1. From your client script (still in the second terminal), store a small persona under a new `user_id`:
   ```python
   client.add_turn(user_id="remote-demo", user_msg="I just adopted a dog named Biscuit.", agent_msg="Noted.")
   client.add_turn(user_id="remote-demo", user_msg="Biscuit is a rescue and still nervous around loud noises.", agent_msg="Got it.")
   ```
2. In the **same** client script run, retrieve memories through the REST API:
   ```python
   print(client.get_context(user_id="remote-demo"))
   ```
3. Validate a multi-turn conversation by asking a dependent follow-up in the same run:
   ```python
   client.add_turn(
       user_id="remote-demo",
       user_msg="What should I keep in mind if I'm inviting people over with Biscuit around?",
       agent_msg="<agent's reply>",
   )
   ```
4. Observe that this is remote integration: your client script never imported or constructed `AgentMemory` directly — every read and write went through `MemoryServiceClient` over HTTP to the server from Task 2.

**Checklist:**
- [ ] `remote-demo` data was stored and retrieved purely through the client/REST API
- [ ] The follow-up response correctly uses the earlier facts (dog's name, temperament)

---

## Task 5: Validate Remote Integration (Capstone)

**Estimated Duration:** 10 minutes

**Steps:**
1. **Close the client script from Task 4 entirely** (a fresh process, not just a new function call).
2. In a **third, brand-new script execution**, connect a new `MemoryServiceClient` to the same server and recall the fact without restating it:
   ```python
   from memory.client import MemoryServiceClient

   client = MemoryServiceClient(base_url="http://localhost:8000")
   print(client.get_context(user_id="remote-demo"))
   ```
3. Confirm end-to-end communication: client process 2 → HTTP → server → Cosmos DB → HTTP → client process 3, with the dog's name/temperament still correctly recalled.
4. Review and summarize the full request flow to the group:
   - Client calls `MemoryServiceClient` → HTTP request to FastAPI server
   - Server calls `AgentMemory`, which reads/writes to Cosmos DB
   - Server returns the response over HTTP back to the client
5. This is the capstone moment for the lab: the same **production backend** from Exercise 2 is now being accessed the way a real, separate client application would — over the network, not in-process.

**Checklist:**
- [ ] A brand-new process (client 3) correctly recalls memory written by an earlier, separate process (client 2)
- [ ] You can draw or explain the full request path from client → server → Cosmos DB → back
- [ ] You can articulate why this pattern matters: multiple apps/services can now share one memory store without embedding the library directly in each one
