# Task 1: Deploy Infrastructure with azd

**Estimated Duration:** 20 minutes

## Steps

1. **Install the Azure Developer CLI** (if not already available):
   ```bash
   curl -fsSL https://aka.ms/install-azd.sh | bash
   ```

2. **Authenticate**:
   ```bash
   azd auth login
   ```

3. **Provision infrastructure**:
   ```bash
   azd provision
   ```
   This creates: Azure OpenAI, Cosmos DB, Azure AI Search, PostgreSQL Flexible Server, and Container Apps, as defined under `infra/`.

4. **Review outputs**:
   ```bash
   azd env get-values
   ```
   Confirm all resource endpoints/keys were generated and note the region used for PostgreSQL (override in `infra/main.parameters.json` if you hit a regional capacity error).

## Checkpoint
- [ ] `azd auth login` completed successfully
- [ ] `azd provision` completed without errors
- [ ] Resource outputs reviewed and captured

# Task 2: Running Automated Tests

**Estimated Duration:** 20 minutes

## Steps

1. **Run focused non-live unit tests**:
   ```bash
   uv run pytest tests/ -k "not live"
   ```
   This covers Azure Search, PostgreSQL, and hybrid search logic using mocks.

2. **Run server/client compatibility tests**:
   ```bash
   uv run pytest tests/test_server_client.py
   ```

3. **Run live Azure smoke tests** (requires provisioned resources from Task 1):
   ```bash
   uv run pytest -m live
   ```

4. **Review results** across all four cloud-backed test paths (SQLite, Azure AI Search, PostgreSQL, Cosmos DB) and confirm all pass before moving on.

## Checkpoint
- [ ] Non-live unit tests pass
- [ ] Server/client compatibility tests pass
- [ ] Live smoke tests pass against real Azure resources

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

# Task 4: Reviewing Project Structure (Optional/Read Only)

**Estimated Duration:** 5 minutes

## Steps

1. **Explore the core package**:
   ```bash
   find memory/ -maxdepth 2 -type f -name "*.py"
   ```
   Review `memory/core`, `memory/db`, and `memory/providers`.

2. **Review server and client code**:
   ```bash
   find server/ client/ -maxdepth 2 -type f -name "*.py"
   ```

3. **Browse infrastructure and tests**:
   ```bash
   find infra/ tests/ -maxdepth 2 -type f
   ```

4. **Identify extension points** — look at `memory/db/` to see how an existing backend (e.g. PostgreSQL) is implemented, as a template for adding a new one.

## Checkpoint
- [ ] Core package structure reviewed
- [ ] Server/client code reviewed
- [ ] Infra/tests structure reviewed
- [ ] Extension point for a new backend identified

# Task 5: Uploading Your Lab Files to GitHub

**Estimated Duration:** 10 minutes

## Steps

1. **Create a new repository on GitHub**
   - Via the web UI: go to [github.com/new](https://github.com/new), name it (e.g. `agent-memory-lab`), and click **Create repository**.
   - Or via CLI (from CloudShell or your terminal, if `gh` is installed):
     ```bash
     gh repo create agent-memory-lab --public --confirm
     ```

2. **Initialize git in your local lab folder**
   ```bash
   cd agent-memory-lab
   git init
   git add .
   git commit -m "Add agent-memory lab guide"
   ```

3. **Link your local folder to the GitHub repo**
   ```bash
   git remote add origin https://github.com/<your-username>/agent-memory-lab.git
   ```

4. **Push your files**
   ```bash
   git branch -M main
   git push -u origin main
   ```

5. **View the lab guide**
   Open `https://github.com/<your-username>/agent-memory-lab` in your browser — GitHub automatically renders `README.md` and lets you click through to each exercise/task file.

## Checkpoint
- [ ] GitHub repository created
- [ ] Local folder initialized and committed
- [ ] Remote linked and files pushed
- [ ] Lab guide viewable and navigable on GitHub
