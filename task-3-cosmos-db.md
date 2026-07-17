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
