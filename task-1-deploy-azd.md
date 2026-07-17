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
