# Task 1: Configure Azure AI Search Backend

**Estimated Duration:** 20 minutes

## Steps

1. **Provision or locate an Azure AI Search resource** in the Azure Portal, and grab its endpoint and admin API key.

2. **Update your `.env` file**:
   ```
   AGENT_MEMORY_DB_TYPE=azure_ai_search
   AZURE_AI_SEARCH_ENDPOINT=https://<your-search-service>.search.windows.net
   AZURE_AI_SEARCH_API_KEY=<your-admin-key>
   AZURE_AI_SEARCH_INDEX_PREFIX=agent-memory
   ```

3. **Re-run the quickstart script** from Exercise 1, Task 2 — it will now write to Azure AI Search instead of SQLite:
   ```bash
   uv run python quickstart.py
   ```

4. **Perform a hybrid search query** to confirm both vector and keyword matching work:
   ```python
   results = await memory.search(
       session_id="demo-session",
       query="favorite programming language",
       search_type="hybrid"
   )
   print(results)
   ```

## Checkpoint
- [ ] Azure AI Search environment variables configured
- [ ] Turn successfully written to the search index
- [ ] Hybrid search returns the expected result

# Task 2: Configure PostgreSQL Backend

**Estimated Duration:** 20 minutes

## Steps

1. **Provision an Azure Database for PostgreSQL Flexible Server** (or use an existing one) and enable the `pgvector` extension:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```

2. **Update your `.env` file**:
   ```
   AGENT_MEMORY_DB_TYPE=postgresql
   POSTGRES_CONNECTION_STRING=postgresql://<user>:<password>@<host>:5432/<database>?sslmode=require
   ```

3. **Re-run the quickstart script**:
   ```bash
   uv run python quickstart.py
   ```

4. **Validate vector similarity search** by querying with a semantically related (not exact) phrase, e.g. "What coding language do I prefer?", and confirm it still retrieves the Python preference via vector similarity rather than exact keyword match.

## Checkpoint
- [ ] PostgreSQL connection string configured and `pgvector` enabled
- [ ] Turn successfully written to Postgres
- [ ] Vector similarity search returns semantically relevant results

# Task 3: Configure Azure Cosmos DB Backend

**Estimated Duration:** 15 minutes

## Steps

1. **Provision an Azure Cosmos DB account** (NoSQL API) with vector search enabled in preview features.

2. **Update your `.env` file**:
   ```
   AGENT_MEMORY_DB_TYPE=cosmos_db
   COSMOS_ENDPOINT=https://<your-account>.documents.azure.com:443/
   AZURE_COSMOS_CONNECTION_STRING=<your-connection-string>
   ```

3. **Re-run the quickstart script**:
   ```bash
   uv run python quickstart.py
   ```

4. **Test native vector + hybrid search**:
   ```python
   results = await memory.search(
       session_id="demo-session",
       query="favorite programming language",
       search_type="hybrid"
   )
   print(results)
   ```

5. **Compare all three backends** (SQLite, Azure AI Search, PostgreSQL, Cosmos DB) side by side — note differences in latency, setup complexity, and search quality in your own notes.

## Checkpoint
- [ ] Cosmos DB environment variables configured
- [ ] Turn successfully written to Cosmos DB
- [ ] Native vector/hybrid search validated
- [ ] Backend comparison notes captured

# Task 4: Running Agent Memory in Server Mode

**Estimated Duration:** 20 minutes

## Steps

1. **Start the FastAPI service**:
   ```bash
   uv run uvicorn server.main:app --reload --port 8000
   ```
   Confirm it starts cleanly — the server should fail fast if your `.env` backend config is invalid.

2. **Install/use the client package** in a new script `server_client_demo.py`:
   ```python
   import asyncio
   from client import MemoryServiceClient

   async def main():
       client = MemoryServiceClient(base_url="http://localhost:8000")

       session = await client.start_session(session_id="server-demo")
       await client.add_turn(
           session_id="server-demo",
           user_message="I live in Seattle.",
           assistant_message="Noted — you're based in Seattle."
       )
       results = await client.search(session_id="server-demo", query="Where do I live?", search_type="hybrid")
       print(results)
       await client.end_session(session_id="server-demo")

   asyncio.run(main())
   ```

3. **Run the client script** in a separate terminal while the server is running:
   ```bash
   uv run python server_client_demo.py
   ```

4. **Check the API docs** at `http://localhost:8000/docs` (FastAPI auto-generated Swagger UI) to explore all available endpoints.

## Checkpoint
- [ ] FastAPI server starts and validates config on boot
- [ ] Client successfully starts a session, adds a turn, and searches
- [ ] Session ended cleanly
- [ ] Swagger UI reviewed at `/docs`
