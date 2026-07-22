# Lab 1: Configure Azure OpenAI and Run the Basic Agent Memory Notebook

### Estimated Duration: 60 Minutes

## 📘 Scenario

Contoso Health Services is building AI agents that can remember users across conversations. Before developing full agent applications, the organization must connect its development environment to the pre-provisioned **Azure OpenAI** resource and validate the **Agent Memory** framework end to end using a Jupyter notebook.

In this lab, you will act as an AI Engineer responsible for retrieving the Azure OpenAI endpoint and key, configuring the project's environment variables, and validating the memory system by executing the basic memory notebook cell by cell.

## 📖 Overview

In this lab, you will locate the pre-created Azure OpenAI resource in the Azure Portal, collect its endpoint and API key, and configure them in the project's `.env` file.

You will then open the `01_basic_memory.ipynb` notebook in Visual Studio Code, select the correct Python kernel, and execute each cell while understanding what it does — from initializing `AgentMemory` with buffer management, through an 8-turn conversation that triggers automatic summarization, to cross-session recall and semantic search.

## 🎯 Objectives

In this lab, you will perform:

- Task 1: Retrieve Azure OpenAI Endpoint and Key, and Configure the .env File
- Task 2: Run and Understand the Basic Memory Notebook

## Task 1: Retrieve Azure OpenAI Endpoint and Key, and Configure the .env File

In this task, you will navigate to the pre-created Azure OpenAI resource, open it in the Foundry portal, copy the endpoint and API key, and paste them into the project's `.env` file.

> **Note:** The Azure OpenAI resource and its model deployments have already been created in this lab environment — you do not need to create any new resources.

1. On the **Azure Portal**, in the search bar at the top, search for **Azure OpenAI (1)**, and select **Azure OpenAI (2)** from the **Services** section.

1. From the list of resources, select the pre-created Azure OpenAI resource available in your resource group.

1. On the resource **Overview** pane, click on **Go to Foundry portal** (or **Explore Azure AI Foundry portal**) to open the resource in the Foundry portal.

   > **Note:** If prompted to sign in, use the same lab credentials provided in the **Environment** tab.

1. In the Foundry portal, from the left navigation pane, select **Deployments**, and verify the required model deployments are listed (a chat model and an embedding model).

1. From the left navigation pane, navigate to the **Overview** (or **Home**) page of your project, and locate the **Endpoint and keys** section.

1. Copy the **Azure OpenAI endpoint (1)** — it looks like the following — and paste it into Notepad for later use:

   ```
   https://<your-resource-name>.openai.azure.com/
   ```

1. Copy the **API Key (2)** and paste it into Notepad for later use.

   > **Note:** Ensure you copy the **Azure OpenAI** endpoint (ending in `openai.azure.com`), not the generic project endpoint — the notebook's client requires the Azure OpenAI format.

1. On the Desktop of your Lab VM, launch **Visual Studio Code**.

1. Go to **File (1)** and click **Open Folder... (2)**.

1. Navigate to the location of the **agent-memory** project folder, select it, and click **Select Folder**.

   > **Note:** If a notification says the folder is in Restricted mode, click on **Manage**, then click **Trust** in the Workspace Trust wizard and close it.

1. In the Explorer pane, open the **.env** file located in the project root.

   > **Note:** If a `.env` file does not exist, open **.env.example**, and after editing, save it as `.env` using **File > Save As**.

1. In the `.env` file, provide the following environment variables using the values you copied to Notepad:

   - **AZURE_OPENAI_ENDPOINT**: Paste the endpoint value you copied in Step 6.
   - **AZURE_OPENAI_API_KEY**: Paste the API key you copied in Step 7.

   ```
   AZURE_OPENAI_ENDPOINT=https://<your-resource-name>.openai.azure.com/
   AZURE_OPENAI_API_KEY=<your-api-key>
   ```

1. Save the changes made to the `.env` file by pressing **CTRL + S**.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Scroll down in the lab guide and hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
> - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

## Task 2: Run and Understand the Basic Memory Notebook

In this task, you will open the `01_basic_memory.ipynb` notebook, select the correct kernel, and execute each cell while understanding exactly what each one does. The notebook demonstrates how **AgentMemory** adds persistent memory to conversations — storing turns, automatically summarizing older content, recalling context across sessions, and searching memory semantically — all using a zero-configuration SQLite backend.

1. In Visual Studio Code's Explorer pane, navigate to the **demo** folder and open the **01_basic_memory.ipynb** file.

1. Take a moment to read the first markdown cell, **"01 Basic Agent Memory Demo"**. It outlines what you will learn: manual `add_turn()`, context retrieval, automatic buffer management, cross-session memory, and semantic search — and notes that the demo uses **SQLite** for zero-configuration setup.

1. Click **Select Kernel (1)** in the top-right corner and choose **Install/Enable suggested extensions Python + Jupyter (2)** if prompted.

1. Wait for the Python extension to be installed.

1. Once the Python extension is installed, select **Python Environments** to ensure that the Jupyter Notebook runs in the correct Python interpreter with the necessary dependencies installed.

1. Select the project's virtual environment, for example **.venv (Python 3.12.x)**, from the list.

   > **Note:** Python **3.12+** is required — the `sqlite-vec` extension used by the local backend depends on it.

1. Run the first code cell under **Step 1: Setup and Configuration**. This cell prepares everything the demo needs before any AI calls are made:

   - **Imports libraries** (`asyncio`, `os`, `sys`, `pathlib`) and attempts to load `python-dotenv` — if dotenv is missing, it warns but continues.
   - **Finds the project root** by walking up the directory tree looking for `pyproject.toml`, then adds it to `sys.path` so the `memory` package can be imported.
   - **Loads your `.env` file** — this is where the endpoint and key you configured in Task 1 are read into the environment.
   - **Defines the demo identifiers**: `USER_ID = "basic_demo_user"` and the SQLite database path `demo_basic_notebook.db`.
   - **Deletes any previous demo database** so every run starts from a clean state (retrying up to 5 times if the file is locked).

   You should see the output ending with: `✅ Step 1 Complete: All imports and paths configured!`

1. Run the next code cell under **Step 2: Initialize AgentMemory**. This cell creates the memory system itself:

   - **Imports the key classes**: `AzureOpenAI` from the OpenAI SDK, and `AgentMemory` + `AgentMemoryConfig` from the `memory` package.
   - **Validates environment variables** — it checks that `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_API_KEY` are set. If either is missing, the cell prints which one and skips initialization; if this happens, re-check your `.env` from Task 1, save it, and restart the kernel.
   - **Creates the Azure OpenAI client** using your endpoint, key, and API version.
   - **Explains the buffer management concept** — long conversations can't all be sent to the LLM (context limits), so AgentMemory prunes automatically: when the buffer reaches `buffer_size` turns, older turns are compressed into a summary while the most recent `active_turns` stay verbatim.
   - **Creates the configuration**: `buffer_size=6` (prune when the buffer hits 6 turns), `active_turns=4` (keep the last 4 turns verbatim), and `longterm_synthesis_frequency=1` (extract insights after every session).
   - **Initializes AgentMemory** with the user ID, OpenAI client, SQLite path, and the config.

   You should see: `✅ AgentMemory initialized and ready!`

1. Run the next code cell under **Step 3: Session 1 — Multi-Turn Conversation with Buffer Pruning**. This is the main demonstration:

   - **Defines a realistic 8-turn conversation** as a hardcoded list of (user, assistant) message pairs — a book-recommendation dialogue covering science fiction, philosophy, novel length preference, and reading habits. You do not type anything; the conversation is pre-scripted in the cell.
   - **Starts Session 1** with `memory.start_session()` and prints the session ID and buffer configuration.
   - **Stores each turn** by looping through the conversation and calling `await memory.add_turn(user_msg, assistant_msg)` — this is the core storage API.
   - **Triggers automatic pruning**: because the conversation has 8 turns and `buffer_size=6`, the buffer fills mid-conversation and older turns are automatically summarized while the last 4 remain verbatim.
   - **Prints the buffer management result**: the final formatted context from `await memory.get_context()`, its size in characters, and a preview — look for a summary block representing turns 1–4 followed by the recent verbatim turns.
   - **Ends the session automatically** when the `async with memory:` context manager exits.

   > **Note:** If you see a handled error mentioning the embedding model, it is a deployment configuration issue rather than a code issue — verify the embedding deployment name in your Azure OpenAI resource matches what the `.env` expects.

1. Run the next code cell under **Step 4: Cross-Session Memory Recall**. This proves persistence across sessions:

   - **Starts a brand-new session** (a different session ID from Session 1) for the same user.
   - **Retrieves context immediately** with `await memory.get_context()` — before any new turns are added.
   - **Shows that the context is not empty**: it prints the loaded context size and a 700-character preview containing content from Session 1.
   - **Prints the key insight**: even in a new session, memory automatically includes (1) previous session summaries, (2) extracted insights and facts, and (3) semantic embeddings of past conversations.

   Verify in the preview that details from the book conversation (Session 1) are present even though this session has stored nothing yet.

1. Run the final code cell under **Step 5: Semantic Search Demonstration**. This shows retrieval by meaning rather than keywords:

   - **Defines three search queries**: `"science fiction book recommendations"`, `"philosophy and consciousness"`, and `"reading habits and preferences"`.
   - **Searches memory** for each query using `await memory.search(query, top_k=2, search_interactions=True, search_insights=True)` — searching across both raw interactions and extracted insights.
   - **Prints a preview of the results** for each query. Notice that matches are found by semantic similarity — the stored turns never used the exact phrase "reading habits", yet the bedtime-reading turn is retrieved.
   - **Prints the final summary** of everything demonstrated: `add_turn()` for storage, `get_context()` for prompt-ready memory, automatic buffer management, cross-session persistence, and semantic search — all with **no Agent Framework required**.

   You should see the output ending with: `🎉 NOTEBOOK COMPLETE!`

1. (Optional) In the Explorer pane, confirm the **demo_basic_notebook.db** file now exists in the project root — this is the SQLite database holding everything the notebook stored.

> **Note:** If you encounter errors such as missing environment variables, recheck your `.env` file. Ensure all values are correct, save the file, and **restart the Jupyter kernel** before re-running the notebook cells — environment variables are read only when the kernel starts.

> **Congratulations** on completing the task! Now, it's time to validate it. Here are the steps:
> - Scroll down in the lab guide and hit the Validate button for the corresponding task. If you receive a success message, you can proceed to the next task.
> - If not, carefully read the error message and retry the step, following the instructions in the lab guide.
> - If you need any assistance, please contact us at cloudlabs-support@spektrasystems.com. We are available 24/7 to help you out.

## 🧾 Summary

In this lab, you accomplished the following:

- Located the pre-created Azure OpenAI resource and opened it in the Foundry portal
- Retrieved the Azure OpenAI endpoint and API key
- Configured the `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_API_KEY` values in the project's `.env` file
- Opened the `01_basic_memory.ipynb` notebook and selected the correct Python kernel
- Executed the setup cell (imports, project root discovery, `.env` loading, database cleanup)
- Initialized `AgentMemory` with buffer management configuration (`buffer_size=6`, `active_turns=4`)
- Ran an 8-turn conversation and observed automatic buffer pruning and summarization
- Validated cross-session memory recall in a brand-new session
- Performed semantic searches across stored interactions and insights

You have successfully completed the lab. Click **Next >>** to continue to the next lab.
