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
