# Exercise 01: Environment Setup & Local Memory

### Estimated Duration: 75 Minutes

## Scenario

In this exercise, you will prepare the lab VM for the rest of the workshop by validating the preloaded developer tools, reviewing the repository layout, confirming the Azure OpenAI configuration used by the demos, and running the local SQLite-based Agent Memory example. You will then inspect how memory is retained across sessions and tune the demo configuration to see how buffer and reflection settings affect memory behavior.

## Overview

You will work inside the preloaded GitHub repository on the Azure lab VM and use the repo's existing demo files instead of building a new application from scratch. The exercise starts with environment verification, moves into configuration review, then runs `demo/01_basic_memory.py` with local SQLite persistence so you can observe session memory, summaries, and semantic recall in action.

## Objectives

- Task 1: Verify tools and inspect the project structure
- Task 2: Review Azure OpenAI environment configuration
- Task 3: Install dependencies and run the basic SQLite demo
- Task 4: Observe memory behavior across sessions
- Task 5: Tune memory configuration and compare results

## Task 1: Verify Tools and Inspect the Project Structure

In this task, you will sign in to Azure, open the prepared repository on the lab VM, verify the required development tools, and confirm the folders used throughout the lab.

1. Sign in to the Azure portal at <https://portal.azure.com> using the following lab credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>
2. Confirm that you are working in subscription <inject key="SubscriptionID"></inject> and tenant <inject key="TenantID"></inject>.
3. Connect to the lab VM by using the method provided for your environment, then open a terminal session.
4. In the terminal, note your deployment identifier for this lab: **Deployment ID: <inject key="DeploymentID" enableCopy="false"/>**.
5. Navigate to the preloaded repository workspace.
6. Run the following commands to confirm Python, uv, and Git are available:

```bash
python --version
uv --version
git --version
```

7. List the top-level contents of the repository:

```bash
ls
```

8. Verify that the repository includes the folders referenced in the lab plan, including `demo/`, `memory/`, `server/`, `client/`, `tests/`, and `infra/`.
9. Open the repository in your preferred editor and briefly inspect these folders:
   - `demo/` for runnable walkthrough scripts
   - `memory/` for memory orchestration and backend logic
   - `server/` for the FastAPI service used later in the lab
   - `client/` for client-side access patterns
   - `tests/` for validation and troubleshooting workflows
   - `infra/` for infrastructure-related assets

> [!Tip]
> If the active terminal session is not already scoped to the correct Azure context, you can verify the subscription from the CLI with `az account show --output table` and, if needed, set it with the subscription ID shown earlier in this task.

## Task 2: Review Azure OpenAI Environment Configuration

In this task, you will inspect the environment configuration used by the repository and identify the core components that connect the demos to Azure OpenAI and the local memory backend.

1. In the root of the repository, locate the environment configuration file used by the demos.
2. Open `.env` if it is already present. If the repo instead provides a sample file, open `.env.example` to review the expected settings.
3. Identify the Azure OpenAI-related entries required by the local demo. Depending on the repo version, these typically include values for:
   - Azure OpenAI endpoint
   - Azure OpenAI API key or other authentication setting
   - Chat or reasoning model deployment name
   - Embedding model deployment name
   - API version, if specified by the repo
4. Confirm that the environment file also contains or implies the local backend selection used for this exercise, which is SQLite.
5. Search the repository for the main memory classes and identify where they are defined or imported:
   - `AgentMemory`
   - `MemoryOrchestrator`
   - the backend implementation layer
6. Open `demo/01_basic_memory.py` and review how the script initializes memory for a local run.
7. Make note of the configuration values that control short-term and long-term memory behavior so you can edit them later in this exercise.

> [!Important]
> This exercise uses the repository's local SQLite-backed workflow. Do not change the backend to Cosmos DB in this exercise.

> [!Note]
> The repo uses Azure OpenAI configuration supplied through the environment file on the lab VM. If a required value is missing, pause here and confirm the bootstrap process has populated the file before continuing.

## Task 3: Install Dependencies and Run the Basic SQLite Demo

In this task, you will install the repository dependencies with uv and run the basic local memory demo from the `demo` folder.

1. In the repository root, synchronize the project dependencies:

```bash
uv sync --extra dev
```

2. Wait for the environment setup to finish and review the output for any package installation errors.
3. Run the basic memory walkthrough exactly as referenced in the plan:

```bash
uv run python demo/01_basic_memory.py
```

4. Allow the script to complete both memory sessions and any semantic search or summary output.
5. If the script prompts for values or logs initialization details, review them without changing the code yet.
6. Record whether the run completed successfully and whether the output clearly shows local memory activity.

> [!Tip]
> If dependency installation fails, rerun the command from the repository root and verify that uv returned a version successfully in Task 1.

<validation step="sqlite_basic_demo"/>

## Task 4: Observe Memory Behavior Across Sessions

In this task, you will analyze the output from the SQLite-backed demo so you can connect the script behavior to the Agent Memory concepts used throughout the rest of the lab.

1. Review the console output from `demo/01_basic_memory.py`.
2. Locate the section representing the first interaction cycle, such as Session 1.
3. Identify where the demo shows short-term conversational context being accumulated.
4. Locate any output related to buffer management, summarization, or reflection.
5. Continue to the second interaction cycle, such as Session 2, and verify that the script can recall details established earlier.
6. Identify the portion of output that demonstrates semantic search or memory retrieval across turns.
7. Explain, in your own words, how the SQLite backend supports local persistence for this demo.
8. Compare the output you observed with the code in `demo/01_basic_memory.py` so you can map the script stages to the memory lifecycle.

> [!Note]
> In this exercise, SQLite is the local persistence mechanism that lets you study memory behavior without introducing cloud database configuration.

<question>

## Task 5: Tune Memory Configuration and Compare Results

In this task, you will edit the configuration block in `demo/01_basic_memory.py`, test how the memory settings affect the output, and then return the demo to its default state.

1. Open `demo/01_basic_memory.py` in your editor.
2. Locate the configuration block that defines values such as `K_TURN_BUFFER` and `REFLECTION_THRESHOLD_TURNS`.
3. Record the original default values before making changes.
4. Change one value at a time. For example:
   - reduce or increase `K_TURN_BUFFER`
   - reduce or increase `REFLECTION_THRESHOLD_TURNS`
5. Save the file.
6. Re-run the demo:

```bash
uv run python demo/01_basic_memory.py
```

7. Compare the new output with your earlier run and note differences in:
   - how many recent turns remain directly available
   - when summarization or reflection occurs
   - how much context is recalled in the later session
8. Restore the original values in `demo/01_basic_memory.py` after your comparison.
9. Run the demo one more time to confirm the baseline behavior has been restored.

> [!Important]
> Always return the file to its original configuration before moving to the next exercise so later demonstrations match the lab instructions.

## Summary

In this exercise, you validated the lab VM toolchain, reviewed the repository structure and Azure OpenAI environment settings, installed dependencies with uv, and ran `demo/01_basic_memory.py` using the local SQLite backend. You also examined how memory persisted across sessions and tested how configuration values such as `K_TURN_BUFFER` and `REFLECTION_THRESHOLD_TURNS` influence summarization, recall, and long-term memory behavior. These foundations prepare you for the next exercise, where the same memory concepts are integrated into the Microsoft Agent Framework pattern.
