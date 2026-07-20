# Exercise 06: Validation, Testing & Troubleshooting

### Estimated Duration: 1 Hour

## Scenario

In the previous exercises, you used the repository's local, cloud-backed, and server-mode experiences to understand how Agent Memory behaves across sessions. In this exercise, you will validate that the environment is working as expected, run the repository's test assets, and troubleshoot common setup issues that can prevent the demos and server workflows from working correctly.

## Overview

You will confirm lab access, run the repository's non-live tests, execute environment validation checks for Azure OpenAI and optional Azure Cosmos DB connectivity, and then work through practical troubleshooting steps that map directly to the kinds of issues developers encounter when moving from a local proof of concept to a repeatable development workflow.

## Objectives

- Task 1: Confirm lab access and locate the validation assets
- Task 2: Run the repository's non-live tests
- Task 3: Run live validation checks for Azure OpenAI and optional Cosmos DB settings
- Task 4: Troubleshoot common environment and configuration issues

## Task 1: Confirm lab access and locate the validation assets

In this task, you will sign in to Azure, verify your current subscription context, and locate the repository folders that contain the test and troubleshooting assets used in this exercise.

1. Sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. Open a terminal on the lab VM and verify the Azure CLI context by running:

   ```bash
   az account show --query "{subscriptionId:id, tenantId:tenantId, user:user.name}" -o json
   ```

3. Confirm that the subscription ID shown in the output is <inject key="SubscriptionID"></inject> and that the tenant ID is <inject key="TenantID"></inject>.

4. Record the deployment identifier for this lab run as **Deployment ID: <inject key="DeploymentID" enableCopy="false"/>**. You may need it later when correlating your work with the lab environment.

5. In the repository root, list the folders you have worked with throughout the lab and confirm that `tests/` is present.

   ```bash
   pwd
   ls
   ```

6. Inspect the test folder and any project configuration files that help you understand how tests are executed.

   ```bash
   ls tests
   ls pyproject.toml
   ```

> [!Note]
> This exercise is grounded in the repository's current files. If the original TOC document references older filenames, always prefer the files that are present in the imported repository on the lab VM.

> [!Tip]
> If `az account show` fails, run `az login` and then rerun the command. In this lab, the expected subscription is <inject key="SubscriptionID"></inject>.

## Task 2: Run the repository's non-live tests

In this task, you will install or confirm the development dependencies and run the repository's non-live tests to validate the local development environment without depending on external cloud calls.

1. From the repository root, make sure the project dependencies are synchronized, including development dependencies used for testing.

   ```bash
   uv sync --extra dev
   ```

2. Review the test files that exist in the `tests/` folder so you can see what is available in the current repo import.

   ```bash
   find tests -maxdepth 2 -type f
   ```

3. Run the non-live test suite.

   ```bash
   uv run pytest tests -m "not live"
   ```

4. Review the test output and identify the following:
   - How many tests were collected
   - How many tests passed, skipped, or failed
   - Whether any markers such as `live` are used to separate cloud-dependent tests from local tests

5. If the full non-live test command reports no matching marker selection, inspect `pyproject.toml` and the test files, then run the repo's available local tests with one of the current patterns supported by the imported repo, such as:

   ```bash
   uv run pytest tests
   ```

   or, if the repo separates files by purpose, run a specific local test module shown by your `find` output.

6. After the tests complete, open one representative test file from `tests/` and compare its assertions to behavior you already observed in the demos.

> [!Important]
> Do not invent filenames from the TOC if they are not present in the imported repository. The correct command is the one that matches the files and markers available in your lab VM copy of the repo.

> [!Note]
> Non-live tests are useful for validating installation, imports, local orchestration logic, and SQLite-based behavior before you spend time troubleshooting Azure connectivity.

<validation step="Run the Non-Live Test Suite"/>

## Task 3: Run live validation checks for Azure OpenAI and optional Cosmos DB settings

In this task, you will verify that the environment variables needed by the live demos are present and then run the repository's live validation tests if those tests exist in the imported repo.

1. Inspect the current environment configuration and verify that the Azure OpenAI-related variables required by the repository are available in `.env`, `.env.example`, or your active shell session.

   ```bash
   grep -E "AZURE_OPENAI|OPENAI|COSMOS|AGENT_MEMORY" .env 2>/dev/null || true
   ```

2. Confirm that the key Azure OpenAI settings expected by the repo are populated. At minimum, you should expect an endpoint and one or more deployment-related values used by the demos.

3. If the repository includes live-marked tests, run them with pytest.

   ```bash
   uv run pytest tests -m live
   ```

4. If the imported repo does not use a `live` marker, identify the cloud-connected validation entry points from the current repo contents and run the most appropriate validation path actually present in the repo, such as a dedicated live test file or one of the demos you already used earlier in the lab:
   - `uv run python demo/01_basic_memory.py`
   - `uv run python demo/04_cosmosdb.py`
   - `uv run python demo/05_server_mode.py`

5. For Azure OpenAI validation, confirm that a cloud-connected script can start successfully and progress beyond initial configuration loading.

6. For Azure Cosmos DB validation, only continue if the environment includes Cosmos-specific settings. Re-run the Cosmos-backed demo you used earlier:

   ```bash
   uv run python demo/04_cosmosdb.py
   ```

7. Review the output and determine whether the issue, if any, is related to:
   - Missing environment variables
   - Authentication or authorization
   - Network reachability
   - Incorrect database, container, or endpoint configuration

> [!Note]
> The plan for this lab explicitly treats Cosmos DB validation as conditional. If Cosmos settings are not configured in the current environment, document that limitation and continue with Azure OpenAI validation and the non-live tests.

> [!Tip]
> A successful live validation path does not always mean every demo succeeds. It means your environment variables, package dependencies, and external connectivity are sufficient for the selected cloud-backed workflow to initialize correctly.

## Task 4: Troubleshoot common environment and configuration issues

In this task, you will use targeted checks to diagnose the most common causes of failures in this repository.

1. If a Python import fails, confirm the virtual environment and dependency state, then resync packages:

   ```bash
   uv sync --extra dev
   uv run python --version
   ```

2. If a demo or test reports that an Azure OpenAI setting is missing, reopen `.env` and verify the variable names expected by the current repo version. Compare the names used in `.env.example`, the demo file you are running, and any helper modules under `memory/`, `agent/`, or `server/`.

3. If authentication appears to be the problem, confirm that the signed-in Azure context is still valid:

   ```bash
   az account show --query "{subscriptionId:id, tenantId:tenantId}" -o json
   ```

4. If the SQLite-based demos pass but Cosmos DB fails, isolate the problem by comparing the local and cloud-backed execution paths:
   - Re-run `uv run python demo/01_basic_memory.py`
   - Re-run `uv run python demo/04_cosmosdb.py`
   - Note whether only the backend-specific configuration changes between the two runs

5. If the server workflow fails, restart the API service and test the health endpoint before troubleshooting the client side:

   ```bash
   uv run uvicorn server.main:app --host 127.0.0.1 --port 8000
   ```

   In a second terminal:

   ```bash
   curl http://127.0.0.1:8000/health
   ```

6. If tests fail unexpectedly, rerun pytest with additional detail and capture the first failing test for investigation:

   ```bash
   uv run pytest tests -vv
   ```

7. Summarize your findings in your own notes by listing:
   - The command that failed
   - The exact error message
   - Whether the issue was local-only or cloud-dependent
   - The file or setting you checked to narrow down the problem

8. After addressing one issue, rerun the relevant command to confirm that the problem is resolved rather than assumed.

> [!Important]
> Troubleshooting is most effective when you change one thing at a time. Avoid editing multiple environment variables and code files before rerunning the failing command.

> [!Tip]
> When a TOC document and an imported repo differ, trust the imported repo structure on disk. Your goal is to validate the environment that actually exists in this lab, not a historical file layout.

<question>

<validation step="Run Live Validation Tests"/>

## Summary

In this exercise, you validated the current lab environment by locating the repository's test assets, running non-live tests, checking the live validation path for Azure OpenAI and optional Cosmos DB connectivity, and working through a structured troubleshooting process. You are now better prepared to distinguish local setup issues from external service configuration problems and to support a more production-ready Agent Memory workflow.
