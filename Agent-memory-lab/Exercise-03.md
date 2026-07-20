# Exercise 03: Azure Cosmos DB Backend

### Estimated Duration: 75 Minutes

## Scenario

In the first two exercises, you worked with local memory persistence and framework-based orchestration. In this exercise, you will extend that same agent memory pattern to a cloud-backed persistence layer by running the repository's Azure Cosmos DB examples. You will review the backend configuration used by the project, run the Cosmos DB demo, confirm that memory persists across runs, and compare Cosmos DB with the other backend options referenced in the repository.

## Overview

In this exercise, you will verify your lab environment, inspect the repository's Cosmos DB example files, run the Azure Cosmos DB demo from the prepared project folder, review the output for persisted memory behavior, and validate the trade-offs between local and cloud-backed backends.

## Objectives

- Task 1: Verify the lab connection and inspect Cosmos DB demo files
- Task 2: Run the Azure Cosmos DB demo
- Task 3: Confirm persisted data and bounded memory behavior
- Task 4: Compare backend choices in the repository

## Task 1: Verify the lab connection and inspect Cosmos DB demo files

In this task, you will sign in to Azure, confirm the subscription context for your lab, and inspect the repository files used for the Cosmos DB backend walkthrough.

1. On the lab virtual machine, open a browser and sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. Confirm that you are working in the correct Azure context:
   - Subscription: <inject key="SubscriptionID"></inject>
   - Tenant: <inject key="TenantID"></inject>
   - Deployment ID: **<inject key="DeploymentID" enableCopy="false"></inject>**

3. Open **Windows Terminal** or **PowerShell** on the lab VM.

4. Run the following command to verify the signed-in Azure CLI context:

   ```bash
   az account show --output table
   ```

5. Open the preloaded repository in Visual Studio Code from the prepared workspace folder used in this lab.

6. In the Explorer pane, review the following folders and files that are relevant to the cloud persistence workflow:
   - `demo/04_cosmosdb.py`
   - `demo/09_itemized_insights_cosmos.py`
   - `memory/`
   - `infra/`
   - `.env` or `.env.example`

7. Open `demo/04_cosmosdb.py` and identify the code sections that switch the memory backend from local SQLite to Azure Cosmos DB.

8. Open `.env` or the generated environment file for the lab and locate the Azure OpenAI and Azure Cosmos DB settings that the demo expects.

> [!Note]
> The exact variable names in the environment file can vary by repo version, but the goal is to confirm that the prepared environment includes Azure OpenAI settings and Cosmos DB connection values needed by `demo/04_cosmosdb.py`.

9. In the Azure portal, use the global search bar to look for **Azure Cosmos DB accounts**. If a Cosmos DB account has been provisioned for the lab, open it and review these areas:
   - **Overview**
   - **Keys**
   - **Data Explorer**

> [!Tip]
> Data Explorer is the portal experience commonly used to inspect databases, containers, and JSON items stored in an Azure Cosmos DB account.

## Task 2: Run the Azure Cosmos DB demo

In this task, you will install any missing dependencies in the repo environment and run the Cosmos DB-backed sample.

1. In the terminal, change to the root of the repository if you are not already there.

2. Synchronize the Python environment used by the lab:

   ```bash
   uv sync --extra dev
   ```

3. Run the Azure Cosmos DB demo:

   ```bash
   uv run python demo/04_cosmosdb.py
   ```

4. Watch the console output and note how the demo differs from the local SQLite flow from Exercise 1.

5. As the script runs, identify output that indicates the demo is:
   - Initializing or connecting to the Azure Cosmos DB backend
   - Writing conversation or memory records
   - Recalling stored context from previous interactions

6. If the script reports a missing environment variable, return to the environment file and compare the expected variable names with the configuration code in `demo/04_cosmosdb.py`.

> [!Important]
> Do not rename repository files during the lab. If you need to troubleshoot configuration, inspect `demo/04_cosmosdb.py`, the backend implementation under `memory/`, and the prepared environment file together so you can match the expected settings.

## Task 3: Confirm persisted data and bounded memory behavior

In this task, you will validate that Azure Cosmos DB preserves memory beyond a single run and then execute the itemized-insights variation that uses the same cloud persistence pattern.

1. Re-run the Cosmos DB demo:

   ```bash
   uv run python demo/04_cosmosdb.py
   ```

2. Compare the second run with the first run and look for evidence that the application can recall information persisted outside the local process.

3. If a Cosmos DB account is available in the portal, return to **Data Explorer** and inspect the database and container structure created or used by the sample.

4. Expand the relevant database and container nodes in **Data Explorer** and review one or more JSON items to see how data is persisted.

> [!Note]
> In Azure Cosmos DB for NoSQL, data is stored as JSON items inside containers. The demo code may organize memory content, summaries, or insight records across one or more logical containers depending on the repo implementation.

5. Run the bounded long-term memory example that uses Azure Cosmos DB:

   ```bash
   uv run python demo/09_itemized_insights_cosmos.py
   ```

6. Review the output and identify how this example differs from the broader synthesis behavior you observed earlier:
   - Itemized insights are explicitly persisted
   - The long-term memory set is bounded
   - Recalled facts can survive across runs through the cloud backend

7. Record a short comparison in your notes between these two scripts:
   - `demo/04_cosmosdb.py`
   - `demo/09_itemized_insights_cosmos.py`

8. Summarize what you observed about cross-run recall, persistence location, and the effect of using a bounded memory strategy with a cloud store.

<validation step="Azure Cosmos DB Backend"/>

## Task 4: Compare backend choices in the repository

In this task, you will review the backend options referenced by the repository and explain when each is appropriate.

1. Open the repo documentation or backend-related code and locate references to these backend options:
   - `sqlite`
   - `cosmosdb`
   - `azure_ai_search`
   - `postgresql`

2. Create a short comparison table in your notes using the following columns:
   - Backend
   - Best fit
   - Strength
   - Limitation

3. Use your observations from this lab to complete the comparison. Your conclusions should align with the following patterns:
   - **SQLite** is best for local development and fast experimentation on a single machine.
   - **Cosmos DB** is best when you want managed cloud persistence, JSON item storage, and cross-run durability for distributed or longer-lived applications.
   - **Azure AI Search** is useful when retrieval quality and search-centric indexing patterns are the primary concern.
   - **PostgreSQL** is useful when the application architecture already standardizes on relational storage or needs SQL-oriented operational patterns.

4. Based on the demos you have run so far, explain why Azure Cosmos DB is a practical intermediate step between local prototyping and a more production-ready deployment model.

5. Save your notes for use in the later architecture and production-review exercises.

## Summary

In this exercise, you switched from a local memory backend to a cloud-backed Azure Cosmos DB workflow using `demo/04_cosmosdb.py` and `demo/09_itemized_insights_cosmos.py`. You verified the lab's Azure context, inspected the repo files that configure the backend, observed persisted memory behavior across runs, and compared Cosmos DB with the other backend choices referenced in the project. These skills prepare you for the later server-mode, testing, and production-readiness portions of the lab.