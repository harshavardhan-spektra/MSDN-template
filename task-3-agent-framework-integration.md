# Task 3: Integrating with Microsoft Agent Framework

**Estimated Duration:** 20 minutes

## Steps

1. **Install the Agent Framework** (if not already part of `uv sync`):
   ```bash
   uv add agent-framework
   ```

2. **Create `agent_demo.py`**:
   ```python
   import asyncio
   from agent_framework.azure import AzureOpenAIChatClient
   from agent_framework import Agent
   from memory import AgentMemory

   async def main():
       memory = AgentMemory(db_type="sqlite", db_path="local_memory.db")

       chat_client = AzureOpenAIChatClient(
           endpoint="<your-endpoint>",
           api_key="<your-key>",
           deployment_name="<your-chat-deployment>"
       )

       agent = Agent(
           chat_client=chat_client,
           context_providers=[memory]
       )

       response = await agent.run(
           session_id="demo-session",
           message="What programming language did I say I liked?"
       )
       print(response)

   asyncio.run(main())
   ```

3. **Run it**
   ```bash
   uv run python agent_demo.py
   ```

4. **Test recall across turns**
   Send a new message in the same session (e.g., "What's my favorite language again?") and confirm the agent correctly recalls "Python" from Task 2's stored turn.

## Checkpoint
- [ ] Agent successfully wired with `AgentMemory` as a context provider
- [ ] Agent response reflects memory-aware context
- [ ] Recall confirmed across multiple turns in the same session
