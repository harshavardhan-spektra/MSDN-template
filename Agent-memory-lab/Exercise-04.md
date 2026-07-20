# Exercise 04: Bounded Long-Term Memory & Insight Curation

### Estimated Duration: 1 Hour

## Scenario

In earlier exercises, you used the repository’s local and cloud-backed memory flows to observe how Agent Memory preserves context across sessions. In this exercise, you will focus on how the project manages **long-term insights** over time. Specifically, you will compare the bounded, itemized insight strategy in `demo/08_itemized_insights.py` with the broader synthesis-oriented behavior demonstrated in `demo/06_insight_curation.py`. This helps you understand how different memory curation patterns affect recall quality, scale, and production maintainability.

## Overview

In this exercise, you will review the itemized-insights implementation, run the SQLite-based bounded long-term memory demo, and compare its results with the earlier insight curation demo. You will use the prepared lab VM and preloaded repository tied to **Deployment ID <inject key="DeploymentID" enableCopy="false"></inject>** to inspect how the sample application limits insight growth while still preserving useful user knowledge across sessions.

## Objectives

- Task 1: Inspect the bounded itemized insights pattern
- Task 2: Run the SQLite itemized insights demo
- Task 3: Compare bounded insights with synthesized curation

## Task 1: Inspect the bounded itemized insights pattern

In this task, you will sign in to Azure, open the prepared environment, and inspect the repository file that demonstrates bounded long-term memory with itemized insights.

1. Open a browser and sign in to the Azure portal at <https://portal.azure.com> using the following credentials:
   - Username: <inject key="AzureAdUserEmail"></inject>
   - Password: <inject key="AzureAdUserPassword"></inject>

2. On the lab VM, open a terminal session and browse to the preloaded repository folder that was prepared for this lab.

3. Review the current Azure subscription context for the lab environment if needed:

   ```bash
   az account show --output table
   ```

   Confirm that the subscription matches <inject key="SubscriptionID"></inject> and the tenant matches <inject key="TenantID"></inject>.

4. In Visual Studio Code or your preferred editor on the lab VM, open the file `demo/08_itemized_insights.py`.

5. Read through the script and identify the sections that implement a **bounded** insight strategy. As you inspect the code, look for these design cues from the repo sample:
   - the demo is focused on itemized insight storage rather than unlimited narrative accumulation
   - insight growth is intentionally constrained so the long-term memory set remains manageable
   - the script is designed to show how repeated sessions can preserve useful facts without letting memory expand without limit

6. Record your findings in a scratchpad or notes file. Specifically, identify:
   - where the script defines or initializes the memory workflow
   - where it demonstrates multiple sessions or repeated interactions
   - where you can infer that the number of retained insights is capped or curated
   - how this differs conceptually from the broader curation behavior you saw in `demo/06_insight_curation.py`

> [!Note]
> This exercise is grounded in the repository demos, so your goal is to understand the implementation pattern exposed by the sample files rather than to build a new application.

> [!Tip]
> If you want to compare both implementations side by side, open `demo/06_insight_curation.py` in a second editor tab before starting Task 2.

<question>

## Task 2: Run the SQLite itemized insights demo

In this task, you will execute the bounded long-term memory sample and observe how insights are retained across sessions while remaining constrained.

1. In the terminal, ensure you are at the root of the repository.

2. If dependencies were not already installed in your session, synchronize them now:

   ```bash
   uv sync --extra dev
   ```

3. Run the itemized insights demo:

   ```bash
   uv run python demo/08_itemized_insights.py
   ```

4. As the script runs, observe the output carefully. Compare what you see across the demo’s sessions and note evidence that the long-term memory is being curated into bounded, itemized insights.

5. Review the output for indicators such as:
   - repeated user traits, preferences, or facts being retained
   - insights being updated or curated instead of expanding without control
   - a stable set of long-term items that remains useful across session boundaries

6. Re-run the same demo one more time:

   ```bash
   uv run python demo/08_itemized_insights.py
   ```

7. Compare the second run with the first run. Determine whether the behavior remains understandable and compact, and consider why a bounded strategy can be helpful for longer-lived agent applications.

8. In your notes, summarize the practical effect of bounded itemized insights for these areas:
   - memory readability
   - long-term maintainability
   - consistency of recall
   - suitability for repeated user sessions

> [!Important]
> This demo uses the repository’s local SQLite-oriented workflow for this exercise. You are evaluating memory behavior and curation strategy, not changing the backend in this step.

## Task 3: Compare bounded insights with synthesized curation

In this task, you will compare the bounded itemized pattern with the earlier long-term synthesis pattern to evaluate trade-offs for real-world implementations.

1. Run the synthesis-oriented insight curation demo again:

   ```bash
   uv run python demo/06_insight_curation.py
   ```

2. After the script completes, compare its output with the output you observed from `demo/08_itemized_insights.py`.

3. Use the following comparison categories to guide your review:
   - **Scale:** Which approach appears easier to manage as the number of sessions increases?
   - **Contradiction handling:** Which approach seems better suited to replacing, refining, or constraining prior insights?
   - **Human readability:** Which output would be easier for a developer or operator to review?
   - **Production fit:** Which pattern appears better aligned to applications that need long-running memory with predictable behavior?

4. Create a short comparison table in your notes with two columns labeled `demo/06_insight_curation.py` and `demo/08_itemized_insights.py`.

5. Add at least one conclusion for each of the following prompts:
   - When is synthesized long-term curation helpful?
   - When is bounded itemized curation preferable?
   - Why might a production team choose bounded memory even if broader synthesis is more expressive?

6. Keep both scripts open and review the implementation structure one final time. Identify which file you would use as your starting point if you needed a memory design that stays compact over many sessions.

7. Confirm that you can clearly explain the difference between:
   - a long-form synthesized memory view
   - a bounded set of itemized long-term insights

<validation step="Bounded Long-Term Memory & Insight Curation"/>

## Summary

In this exercise, you examined how the repository demonstrates bounded long-term memory using `demo/08_itemized_insights.py` and compared it with the synthesis-heavy approach in `demo/06_insight_curation.py`. You observed how itemized insights can keep long-term memory more compact, reviewable, and operationally predictable across repeated sessions. This comparison prepares you to evaluate which memory curation strategy is the best fit for a production agent solution.