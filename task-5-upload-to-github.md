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
