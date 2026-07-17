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
