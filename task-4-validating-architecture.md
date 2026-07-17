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
