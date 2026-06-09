# Keeping Machines Synchronised

Because `apply-global.sh` uses symlinks by default, changes pushed to the repo are automatically picked up by all machines that cloned it.

## Update Workflow

```bash
# On any machine with the repo cloned
cd ~/repos/ws-agents
git pull
```

That's it. The symlinks installed by `apply-global.sh` point into this repo, so the next CLI session reads the updated files.

## Regenerating Generated Files

If you updated shared personas and need to regenerate the combined files:

```bash
./scripts/build.sh
```

## When Symlinks Don't Work

Some tools don't follow symlinks (e.g., some Copilot integrations). In that case, re-run the installer with `--copy`:

```bash
./scripts/apply-global.sh --force --copy
```

## Verifying Sync

```bash
cd ~/repos/ws-agents
git status          # check what changed
git diff --stat     # file-level diff
./scripts/doctor.sh # verify symlinks point to the right place
```

## Testing a Fresh Install

```bash
# Clone into a temp directory
git clone <repo-url> /tmp/ws-agents-test
cd /tmp/ws-agents-test

# Dry run
./scripts/apply-global.sh --dry-run

# Full install
./scripts/apply-global.sh --force

# Verify
./scripts/doctor.sh
```
