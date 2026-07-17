# Task 3: Exploring Demos

**Estimated Duration:** 15 minutes

## Steps

1. **Run the SQLite demo**:
   ```bash
   uv run python demo/sqlite_demo.py
   ```

2. **Run the Cosmos DB demo**:
   ```bash
   uv run python demo/cosmos_demo.py
   ```

3. **Run the FastAPI server-mode demo**:
   ```bash
   uv run uvicorn server.main:app --port 8000 &
   uv run python demo/server_demo.py
   ```

4. **Compare** setup effort, latency, and output quality across all three demos and note which best fits a production scenario vs. local prototyping.

## Checkpoint
- [ ] SQLite demo run successfully
- [ ] Cosmos DB demo run successfully
- [ ] Server-mode demo run successfully
- [ ] Comparison notes captured
