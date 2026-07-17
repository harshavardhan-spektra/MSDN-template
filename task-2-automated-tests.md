# Task 2: Running Automated Tests

**Estimated Duration:** 20 minutes

## Steps

1. **Run focused non-live unit tests**:
   ```bash
   uv run pytest tests/ -k "not live"
   ```
   This covers Azure Search, PostgreSQL, and hybrid search logic using mocks.

2. **Run server/client compatibility tests**:
   ```bash
   uv run pytest tests/test_server_client.py
   ```

3. **Run live Azure smoke tests** (requires provisioned resources from Task 1):
   ```bash
   uv run pytest -m live
   ```

4. **Review results** across all four cloud-backed test paths (SQLite, Azure AI Search, PostgreSQL, Cosmos DB) and confirm all pass before moving on.

## Checkpoint
- [ ] Non-live unit tests pass
- [ ] Server/client compatibility tests pass
- [ ] Live smoke tests pass against real Azure resources
