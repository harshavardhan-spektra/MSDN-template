# Exercise 02: Agent Framework Integration

### Estimated Duration: 1.5 Hour(s)

## Scenario

In the previous exercise, you used the repository's direct memory flow to observe how conversation state, summaries, and recall behave with a local backend. In this exercise, you will move to the framework-driven pattern described in the TOC document by examining how the repo integrates memory into an agent workflow. You will inspect the integration code in `demo/02_agent_framework.py`, run the financial advisor scenario, compare that experience with `demo/03_agent_driven.py`, and then study how `demo/06_insight_curation.py` builds longer-lived user understanding across sessions.

## Overview

In this exercise, you will review the Microsoft Agent Framework integration pattern used by the repo, run multiple demos from the preloaded project, and compare two different approaches to memory retrieval:

- framework-managed context injection with `context_providers=[memory]`
- explicit or agent-driven retrieval patterns that surface memory more intentionally
- insight curation that turns repeated sessions into durable profile knowledge

You will work entirely from the prepared lab VM and the repository that was staged during deployment **<inject key="DeploymentID" enableCopy="false"></inject>**.

## Objectives

- Task 1: Inspect the Agent Framework integration in `demo/02_agent_framework.py`
- Task 2: Run the financial advisor demo and verify cross-session recall
- Task 3: Compare framework-managed memory with `demo/03_agent_driven.py`
- Task 4: Run `demo/06_insight_curation.py` and analyze long-term memory behavior

## Task 1: Inspect the Agent Framework integration in demo/02_agent_framework.py

In this task, you will sign in to Azure, verify your lab context, and inspect the framework integration points used by the repository.

1. Sign in to the Azure portal at <https://portal.azure.com> using the following lab credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. Open a terminal in the lab VM and sign in to Azure CLI if your session is not already authenticated.

3. Run the following command to confirm the active lab subscription context:

   ```bash
   az account show --output table
   ```

4. Confirm that the subscription matches <inject key="SubscriptionID"></inject> and that the tenant matches <inject key="TenantID"></inject>.

   > [!Note]
   > The Azure CLI command `az account show` is the supported way to confirm the active subscription context before you use Azure-connected demos or supporting services.

5. Change to the root folder of the preloaded repository if it is not already open in your terminal.

6. Open `demo/02_agent_framework.py` in your editor.

7. Locate the section where the agent is constructed and identify the memory integration pattern. Specifically, find the use of `context_providers=[memory]`.

8. Continue reading the file and identify the lifecycle hooks that connect memory to the agent run. Confirm where `before_run()` is called and where `after_run()` is called.

9. As you inspect the script, answer the following questions in your notes:
   - What object is responsible for supplying prior context to the agent?
   - At what point is context loaded before the model response is generated?
   - At what point are new conversation turns written back into memory?

10. Compare this structure with what you saw in Exercise 1. Notice that the application code is no longer manually orchestrating every retrieval step in the main demo flow; instead, the framework pattern allows memory to participate as a context provider around the run lifecycle.

<question>

<validation step="agent_framework_context_provider"/>

## Task 2: Run the financial advisor demo and verify cross-session recall

In this task, you will execute the Agent Framework demo and observe how memory from one session influences a later interaction.

1. If you have not already installed the development dependencies in this environment, run the following command from the repository root:

   ```bash
   uv sync --extra dev
   ```

2. Review your local environment file and confirm that the Azure OpenAI settings expected by the demos are present.

   > [!Important]
   > This exercise assumes the lab bootstrap prepared the `.env` file or equivalent environment variables required by the repo. If the demo fails immediately with missing configuration, pause and verify the Azure OpenAI values prepared for the lab environment.

3. Run the financial advisor Agent Framework demo:

   ```bash
   uv run python demo/02_agent_framework.py
   ```

4. Watch the output carefully and identify the first conversation flow, which establishes user preferences or facts during Session 1.

5. Continue through the demo until Session 2 executes. Verify that the later session references information established earlier rather than behaving like a stateless first-time conversation.

6. Record at least two examples of information that appears to have been recalled from previous interaction history.

7. Re-run the demo one more time if needed to better observe the boundaries between:
   - the active conversation turns
   - memory supplied before the run
   - updated memory written after the run

8. Summarize in your notes why this pattern is useful for scenarios such as a financial advisor, where user preferences, goals, or risk posture may need to persist across multiple interactions.

> [!Tip]
> If the output scrolls too quickly, copy the console output to a text file or use your terminal scrollback so you can compare Session 1 and Session 2 side by side.

## Task 3: Compare framework-managed memory with demo/03_agent_driven.py

In this task, you will compare the framework-managed memory pattern with a demo that surfaces agent-driven retrieval more explicitly.

1. Open `demo/03_agent_driven.py` in your editor.

2. Review the script and note how the memory interaction differs from `demo/02_agent_framework.py`.

3. Run the comparison demo:

   ```bash
   uv run python demo/03_agent_driven.py
   ```

4. Observe how the application presents memory access in this demo. Look for evidence that retrieval is being invoked more deliberately or more visibly than in the context-provider pattern.

5. Compare the two demos using the following prompts:
   - In `demo/02_agent_framework.py`, what appears automatic because memory is registered as a context provider?
   - In `demo/03_agent_driven.py`, what is easier to reason about because retrieval behavior is more explicit?
   - Which approach would be easier to debug if a user reports that important context was not recalled?
   - Which approach would feel more natural in a multi-turn agent experience?

6. Create a short comparison table in your notes with the headings **Pattern**, **Strength**, **Trade-off**, and **Best-fit scenario**.

7. Keep both files open and compare how each demo balances convenience, control, and transparency.

> [!Note]
> The goal of this task is not to declare one pattern universally better. Instead, you are identifying when framework-managed context injection is helpful and when explicit retrieval can offer better observability or control.

## Task 4: Run demo/06_insight_curation.py and analyze long-term memory behavior

In this task, you will run the insight curation demo and observe how repeated sessions can evolve into durable user understanding.

1. Open `demo/06_insight_curation.py` and skim the structure before running it.

2. Identify where the script appears to move beyond short conversational recall into summary generation, extracted insights, or profile-like memory.

3. Run the demo:

   ```bash
   uv run python demo/06_insight_curation.py
   ```

4. Observe the output across the full run and identify examples of the following:
   - session summaries
   - extracted insights
   - changes in the evolving user profile across sessions

5. As you review the output, consider how this differs from simply replaying recent turns from a buffer. Note how curated insights can compress repeated interactions into higher-value long-term memory.

6. In your notes, answer these questions:
   - What information appears important enough to survive beyond a single session?
   - How could curated insights help avoid repeatedly asking the same background questions?
   - What risks might appear if poor-quality insights are retained for too long?

7. Based on your observations from this task and the prior two demos, write a short conclusion describing the progression from:
   - direct memory usage
   - framework-integrated memory
   - agent-driven retrieval
   - long-term insight curation

8. Save your notes because you will use the same mental model again when you move into cloud-backed persistence and bounded long-term memory in later exercises.

## Summary

In this exercise, you inspected how the repository integrates memory with an agent lifecycle by using `context_providers=[memory]` and the `before_run()` and `after_run()` hooks in `demo/02_agent_framework.py`. You then ran the financial advisor scenario to confirm cross-session recall, compared that framework-managed approach with `demo/03_agent_driven.py`, and used `demo/06_insight_curation.py` to see how repeated interactions can be distilled into longer-term user insights. You are now prepared to extend the same concepts into Azure-backed persistence in the next exercise.