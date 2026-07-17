# Exercise 1 – Agent Memory with SQLite
**Estimated Duration:** 80 Minutes

## Objective
Configure Agent Memory using SQLite, run the local demo, and understand persistent memory.

### Task 1 – Configure the Agent Memory Environment
**Instructions**
1. Clone the Agent Memory repository.
2. Create and activate a Python virtual environment.
3. Install the required dependencies.
4. Configure Azure OpenAI endpoint, deployment name, and API key.
5. Verify the environment by running the sample validation command.

**Validation**
- Environment is created successfully.
- Dependencies install without errors.

### Task 2 – Configure SQLite Backend
1. Open the configuration file.
2. Set the backend to SQLite.
3. Save the configuration.
4. Run the application once to initialize the database.

**Validation**
- SQLite database file is created.

### Task 3 – Run the SQLite Demo
1. Start the demo application.
2. Verify successful startup.
3. Review console logs.
4. Confirm the AI agent is ready.

### Task 4 – Interact with the AI Agent
1. Ask the agent your name.
2. Tell the agent about your interests.
3. Ask follow-up questions.
4. Observe how previous information is remembered.

### Task 5 – Validate SQLite Memory
1. Open the SQLite database.
2. Review stored conversations.
3. Restart the application.
4. Verify that memories persist.
