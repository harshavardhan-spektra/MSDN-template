# Exercise 07: Production Hardening & Architecture Review

### Estimated Duration: 30 Minutes

## Scenario

You have validated the Agent Memory samples locally, integrated memory with Microsoft Agent Framework, and exercised both SQLite and Azure Cosmos DB backends. In this final exercise, you will review how the repository moves from workshop configuration toward a production-ready deployment model by examining the authentication guidance in `docs/ENTRA_ID_AUTH_SETUP.md` and the infrastructure guidance in `infra/README.md` together with the related infra files.

## Overview

In this exercise, you will review the repository’s production-oriented guidance, verify how Azure authentication should work in a hardened deployment, and connect the repo’s infrastructure assets to the runtime components you used in earlier exercises. The goal is not to deploy a new environment, but to identify the concrete changes required to run the solution securely and repeatably in Azure.

## Objectives

- Task 1: Review Azure sign-in context and Entra ID authentication guidance
- Task 2: Map the infrastructure files to the application architecture
- Task 3: Perform a production readiness review

## Task 1: Review Azure sign-in context and Entra ID authentication guidance

In this task, you will confirm the Azure context for your lab environment and review how the repo documents Microsoft Entra ID-based authentication for production use.

1. Sign in to the Azure portal at <https://portal.azure.com> with the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. Confirm that your active Azure context matches this lab environment:
   - Subscription: <inject key="SubscriptionID"></inject>
   - Tenant: <inject key="TenantID"></inject>
   - Deployment ID: **<inject key="DeploymentID" enableCopy="false"></inject>**

3. On the lab VM, open a terminal in the repository root and run the following commands. Replace TENANT_ID and SUBSCRIPTION_ID with the values shown above for this lab environment.

   ```bash
   az login --tenant TENANT_ID
   az account set --subscription SUBSCRIPTION_ID
   az account show --output table
   ```

4. Open `docs/ENTRA_ID_AUTH_SETUP.md` in the repo and identify the sections that describe Microsoft Entra ID authentication, service principals or managed identity usage, and any references to replacing static secrets with Azure identity-based access.

5. From that document, capture the design intent for production authentication in your notes. Your review should answer these questions:
   - Where would `DefaultAzureCredential` fit in this solution?
   - Which local development credential source is acceptable for the lab VM?
   - Why is managed identity preferable to storing long-lived secrets in `.env` files for deployed workloads?

> [!Important]
> For this exercise, you are reviewing the production design and repo guidance. Do not replace the lab’s working configuration unless the instructions in the repo explicitly tell you to do so.

> [!Note]
> In Azure SDK-based applications, `DefaultAzureCredential` is commonly used to authenticate with developer credentials during local work and managed identity in Azure-hosted environments. For production deployments, managed identity is preferred because it avoids embedding credentials in application configuration.

## Task 2: Map the infrastructure files to the application architecture

In this task, you will inspect the `infra/` assets and connect them to the application runtime that you explored throughout the lab.

1. Open `infra/README.md` and identify the primary infrastructure entry points and any referenced template or parameter files.

2. In the `infra/` folder, review the main infrastructure files referenced by the README. As you inspect them, identify where the deployment defines or expects resources for the following areas:
   - Azure OpenAI connectivity
   - Azure Cosmos DB connectivity
   - Compute or host environment assumptions
   - Environment variables or application settings
   - Identity and access configuration

3. In your notes, map the infrastructure assets to the repo folders you used earlier in the lab:
   - `demo/`
   - `memory/`
   - `agent/`
   - `server/`
   - `client/`
   - `tests/`

4. If the infra files include ARM, Bicep, parameter, or environment configuration artifacts, identify which values are deployment-time concerns and which values remain application runtime concerns.

5. Review whether the current infrastructure appears optimized for a workshop environment, a development environment, or a production baseline. Be prepared to justify your answer using evidence from `infra/README.md` and at least one infra file.

> [!Tip]
> A useful production review separates concerns into three layers: provisioning, configuration, and application behavior. If a value is created by infrastructure, injected at deployment time, or resolved through identity, it should not be hard-coded in application source files.

## Task 3: Perform a production readiness review

In this task, you will summarize the hardening changes that would make this solution more production-ready.

1. Create a short review table in your notes with the following columns:
   - Area
   - Current lab approach
   - Production recommendation
   - Repo file or folder reference

2. Include at least these review areas:
   - Authentication to Azure services
   - Secret management
   - Backend selection for memory persistence
   - API hosting approach for `server.main:app`
   - Observability and troubleshooting
   - Infrastructure repeatability

3. Based on your earlier exercises, explain when each backend would be appropriate:
   - `sqlite`
   - `cosmosdb`
   - `azure_ai_search`
   - `postgresql`

4. Add a short recommendation describing how you would host the server-mode application in Azure if you needed repeatable deployments, identity-based auth, and centralized configuration.

5. Conclude your review by listing the top three production hardening actions you would implement first.

<question>

## Summary

In this exercise, you reviewed the repo’s Microsoft Entra ID authentication guidance, mapped the `infra/` assets to the Agent Memory solution architecture, and summarized the production hardening decisions required for a secure Azure deployment. You should now be able to explain where identity-based authentication, infrastructure-as-code, and backend selection fit into a production-ready Agent Memory implementation.
