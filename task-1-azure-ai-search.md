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
