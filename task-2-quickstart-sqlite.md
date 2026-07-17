# Task 2: Quick Start with Local SQLite

**Estimated Duration:** 15 minutes

## Steps

1. **Create a Python script** `quickstart.py` in the repo root:
   ```python
   import asyncio
   from memory import AgentMemory

   async def main():
       memory = AgentMemory(db_type="sqlite", db_path="local_memory.db")

       # Add a conversation turn
       await memory.add_turn(
           session_id="demo-session",
           user_message="My favorite programming language is Python.",
           assistant_message="Got it — I'll remember that you prefer Python."
       )

       # Retrieve context
       context = await memory.get_context(session_id="demo-session", query="What language do I like?")
       print(context)

   asyncio.run(main())
   ```

2. **Run it**
   ```bash
   uv run python quickstart.py
   ```

3. **Verify persistence**
   ```bash
   sqlite3 local_memory.db ".tables"
   sqlite3 local_memory.db "SELECT * FROM turns LIMIT 5;"
   ```
   Confirm your turn was written to disk.

4. **Re-run the retrieval only** (comment out `add_turn`, rerun) to confirm the context still returns your stored preference after the script restarts.

## Checkpoint
- [ ] Turn added successfully
- [ ] Context retrieval returns the stored preference
- [ ] Data confirmed present in `local_memory.db`
