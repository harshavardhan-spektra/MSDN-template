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
