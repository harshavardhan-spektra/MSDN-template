# Exercise 05: Live Server Mode & Streamlit UI

### Estimated Duration: 1.5 Hours

## Scenario

In this exercise, you move from single-script execution to a service-based runtime model. Instead of running memory logic only inside standalone demos, you will start the FastAPI server in the `server/` folder, validate the health endpoint, connect to it with the terminal client in `demo/05_server_mode.py`, then explore the browser-based experience in `demo/07_interactive_ui.py`. You will also end a session and verify that memory created in one session can be recalled in another when you reuse the same user identity.

## Overview

You will start the live memory service with Uvicorn, confirm the service is healthy, run the terminal chat client, launch the Streamlit UI, and observe how active turns, summaries, and insights are surfaced through a server-backed workflow. Finally, you will change the backend by setting `AGENT_MEMORY_DB_TYPE` and confirm that the client flow continues to work after a restart.

## Objectives

- Task 1: Start and validate the FastAPI memory server
- Task 2: Use the terminal client against the live server
- Task 3: Launch and inspect the Streamlit interactive UI
- Task 4: End a session and verify cross-session recall
- Task 5: Switch the backend with `AGENT_MEMORY_DB_TYPE`

## Task 1: Start and validate the FastAPI memory server

In this task, you will sign in to Azure, open the prepared project workspace on the lab VM, start the FastAPI service with Uvicorn, and verify the `/health` endpoint returns a successful status.

1. Sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. Confirm that you are working in the lab environment associated with **Deployment ID <inject key="DeploymentID" enableCopy="false"/>**.

3. Open a terminal on the lab VM and change to the root of the preloaded repository.

4. If you have not already restored the Python environment in a previous exercise session, run the dependency sync command:

   ```bash
   uv sync --extra dev
   ```

5. Review the server entry point so you know which application object Uvicorn will host.

   ```bash
   ls server
   ```

   Confirm that the folder contains `main.py`, which is the file referenced by the startup command.

6. Start the memory server on the loopback interface and port `8000`.

   ```bash
   uv run uvicorn server.main:app --host 127.0.0.1 --port 8000
   ```

7. Leave the server terminal running. Open a second terminal window or tab and test the health endpoint.

   ```bash
   curl http://127.0.0.1:8000/health
   ```

8. Verify that the response contains a healthy status similar to the following:

   ```json
   {"status":"ok"}
   ```

9. If the server does not start, verify that your `.env` file contains the Azure OpenAI values used in earlier exercises and that no other process is already bound to port `8000`.

> [!Note]
> The Uvicorn command uses `server.main:app`, which means Python loads the `app` object from `server/main.py` and exposes it as the FastAPI service.

> [!Tip]
> Keep the server terminal open for the rest of this exercise. The terminal client and Streamlit UI both depend on the live service being available at `http://127.0.0.1:8000`.

<validation step="server_mode_health_check"/>

## Task 2: Use the terminal client against the live server

In this task, you will connect a terminal-based client to the running service and use the available slash commands to inspect context, search memory, and review insights.

1. In a new terminal, confirm that the server from Task 1 is still running.

2. Start the server mode demo client.

   ```bash
   uv run python demo/05_server_mode.py
   ```

3. When the interactive prompt opens, begin a short conversation and provide details that are easy to recognize later. For example, share a name, a project preference, or a recurring interest that can be recalled in a later session.

4. After a few turns, run the context inspection command supported by the demo:

   ```text
   /context
   ```

5. Review the returned context to identify the active-turn or short-term memory being sent through the live service.

6. Run the memory search command and look for previously mentioned details.

   ```text
   /search
   ```

7. Run the insights command.

   ```text
   /insights
   ```

8. Observe how the terminal client surfaces the current memory state through the server rather than by directly instantiating the memory workflow inside the demo script.

9. When you are ready to finish this terminal conversation, do not exit yet. You will end the session formally in Task 4.

> [!Important]
> Use the exact slash commands implemented by the demo: `/context`, `/search`, `/insights`, and `/quit`. If you type free-form text instead, the client will treat it as conversation input rather than a command.

> [!Note]
> The purpose of this task is to see that the same memory behavior you explored earlier can be exposed through a long-running service boundary.

## Task 3: Launch and inspect the Streamlit interactive UI

In this task, you will start the Streamlit interface and review how the browser-based client presents the live memory workflow.

1. Open another terminal while keeping the FastAPI server running.

2. Start the Streamlit application from the repository root.

   ```bash
   uv run streamlit run demo/07_interactive_ui.py
   ```

3. Wait for Streamlit to display the local URL, then open it in the lab VM browser. The default local address is typically:

   ```text
   http://localhost:8501
   ```

4. In the Streamlit UI, start a conversation with the same user identity or session context used in the terminal workflow if the interface exposes those fields.

5. Add several messages and inspect the panels or sections that surface memory information.

6. Verify that the UI helps you review memory tiers such as recent turns, summaries, or insights created by the backing service.

7. Compare what you see in the browser with what you observed in the terminal client.

8. Leave the Streamlit window available for reference while you complete the session recall test.

> [!Tip]
> If the page does not load, return to the Streamlit terminal and confirm the process is still running and that port `8501` is not blocked by another local process.

> [!Note]
> Streamlit provides a lightweight way to inspect the same memory system from a browser without changing the underlying service implementation.

## Task 4: End a session and verify cross-session recall

In this task, you will close one interaction session, allow memory summarization or reflection to complete, and then start a new session with the same user identifier to confirm recall across sessions.

1. Return to the terminal client from Task 2.

2. End the current interactive session by using the quit command:

   ```text
   /quit
   ```

3. Watch for the session to close cleanly and note any output indicating that summaries, insights, or memory persistence steps were completed.

4. Start the terminal client again.

   ```bash
   uv run python demo/05_server_mode.py
   ```

5. Reuse the same user identity, if the demo prompts for one, so the server can query the same memory records from the backend.

6. Ask a question that should depend on information you shared earlier, such as a preference, project detail, or personal fact entered in the first session.

7. Verify that the response demonstrates cross-session recall rather than only the current-turn context.

8. If recall is not obvious, use `/search` or `/insights` again to inspect whether the information was persisted and curated.

9. Record what changed between the first and second sessions:
   - What details were still available?
   - Did the demo show summaries or insights?
   - Was the recall immediate, or did it require explicit search?

> [!Important]
> Cross-session recall depends on reusing the same logical user identity. If you start the second session with a different identity, the server will treat it as a different memory history.

<validation step="streamlit_memory_tiers"/>

## Task 5: Switch the backend with `AGENT_MEMORY_DB_TYPE`

In this task, you will change the server backend selection through an environment variable, restart the service, and confirm that the client workflow remains the same from the user perspective.

1. Stop the Uvicorn server from Task 1 by returning to the server terminal and pressing `Ctrl+C`.

2. Open the environment file used by the repo and locate the backend setting for Agent Memory.

3. Set the backend type to `cosmosdb` by updating the environment variable as shown below:

   ```env
   AGENT_MEMORY_DB_TYPE=cosmosdb
   ```

4. Save the file.

5. Confirm that the Cosmos DB configuration values required by the repo are present in the environment before you continue.

6. Restart the FastAPI server.

   ```bash
   uv run uvicorn server.main:app --host 127.0.0.1 --port 8000
   ```

7. In a second terminal, test the health endpoint again.

   ```bash
   curl http://127.0.0.1:8000/health
   ```

8. Start the terminal client again.

   ```bash
   uv run python demo/05_server_mode.py
   ```

9. Verify that the client still works without modifying the application code.

10. Explain the result in your own words: the client experience remains the same because the backend implementation is selected through configuration, while the service and client interaction pattern stays constant.

11. If your lab proctor or earlier exercise guidance asks you to return to SQLite for later work, reset the environment variable before moving on.

   ```env
   AGENT_MEMORY_DB_TYPE=sqlite
   ```

> [!Note]
> This task demonstrates a key architecture benefit of the repo: backend selection is configuration-driven, so the live clients can continue to call the same server endpoints even when persistence moves from SQLite to Azure Cosmos DB.

<question>

## Summary

In this exercise, you hosted the memory application as a live FastAPI service, validated the `/health` endpoint, interacted with the service through both `demo/05_server_mode.py` and `demo/07_interactive_ui.py`, and verified that memory can persist beyond a single conversation session. You also changed `AGENT_MEMORY_DB_TYPE` to demonstrate that backend selection can be handled through configuration while preserving the same client-facing workflow.