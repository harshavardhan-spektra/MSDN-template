# Hands-on Lab: Agent Memory — SQLite, Cosmos DB & Server Mode

**Total Duration:** 4 hours (240 minutes)
**Level:** Beginner → Intermediate
**Repo:** [james-tn/agent-memory](https://github.com/james-tn/agent-memory)

## Lab Files

| File | Covers | Duration |
|---|---|---|
| [`exercise-1-sqlite.md`](./exercise-1-sqlite.md) | Agent Memory with SQLite (local learning/prototyping) | 80 min |
| [`exercise-2-cosmosdb.md`](./exercise-2-cosmosdb.md) | Agent Memory with Azure Cosmos DB (production-style) | 90 min |
| [`exercise-3-fastapi-server.md`](./exercise-3-fastapi-server.md) | Agent Memory with FastAPI Server Mode (remote integration) | 70 min |

Work through them in order — Exercise 3 reuses the Cosmos DB backend from Exercise 2, so it should be completed last.

## Prerequisites (do this before Exercise 1)

- Python 3.10+ and [`uv`](https://docs.astral.sh/uv/) installed
- Access to an **Azure OpenAI** resource (endpoint, API key, and chat + embedding deployment names) — provided by your organization
- Access to an **Azure Cosmos DB** account (endpoint + key), with a database/container already created by your organization — needed for Exercise 2 and 3
- A terminal with two or three tabs/windows available (you'll run a server in one and clients in others during Exercise 3)

```bash
git clone https://github.com/james-tn/agent-memory.git
cd agent-memory
uv sync --extra dev --extra docs
```

Create a `.env` file in the repo root:

```bash
AZURE_OPENAI_ENDPOINT=https://your-resource.openai.azure.com/
AZURE_OPENAI_API_KEY=your-key
AZURE_OPENAI_API_VERSION=2025-04-01-preview
AZURE_OPENAI_REASONING_MODEL=your-chat-deployment
AZURE_OPENAI_PROCESSING_MODEL=your-processing-deployment
AZURE_OPENAI_EMB_DEPLOYMENT=text-embedding-ada-002
```

> **Facilitator note:** This lab assumes the repo ships ready-to-run demo scripts per backend (e.g. under an `examples/` folder) and a console-runnable FastAPI server module. Confirm the exact file paths/commands against the live repo before delivering — the commands below use best-guess names based on the README and should be corrected if they differ. Also confirm your Cosmos DB database/container already exists with a partition key set (see Exercise 2, Task 1) — this cannot be changed after creation.

## What "done" looks like

By the end of this lab you will have:
1. Run the same Agent Memory API against two different backends (SQLite, Cosmos DB) without changing application code.
2. Proven that memory persists across a full application restart (SQLite) and across separate script/process runs (Cosmos DB, then again over the network in Exercise 3).
3. Accessed Cosmos DB-backed memory both in-process and remotely through a FastAPI server — the same backend, two different access patterns.
