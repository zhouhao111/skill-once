# SkillOnce

> Git-style AI Agent Skill Management Tool.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

English | [简体中文](README.md)

## What is this?

Do you use multiple AI Agents (Claude Code, Cursor, Trae, Hermes, etc.)?

**SkillOnce** lets you install a skill in any Agent, and it automatically syncs to all Agents. Install once, use everywhere.

```
You install a skill
     ↓
SkillOnce automatically syncs to all Agents
     ↓
Claude Code ✅  Cursor ✅  Trae ✅  Hermes ✅  ...
```

---

## Core Features

### 🔄 Git-style Commands

```bash
skill-once init                    # Initialize repository
skill-once add my-skill ./my-skill # Add skill
skill-once add .                   # Add all skills
skill-once sync                    # Sync to all Agents
skill-once pull my-skill           # Pull skill
skill-once push origin             # Push to remote
```

### 🌐 Remote Repository Management

```bash
skill-once remote add origin https://github.com/user/repo.git
skill-once remote add gitee https://gitee.com/user/repo.git
skill-once remote list
skill-once fetch
skill-once pull origin
skill-once push origin
```

### 📊 Status Viewing

```bash
skill-once status    # View deployment status
skill-once diff      # View changes
skill-once log       # View history
```

---

## Scenarios

### Scenario 1: I installed a new skill

**What you do**: Install a skill in any Agent

**What SkillOnce does**:
1. Detects the new skill
2. Syncs to skill repository
3. Deploys to all other Agents via symlink
4. All Agents can use it immediately

**Result**: A skill you installed in Claude Code is available in Cursor, Trae, Hermes, etc.

---

### Scenario 2: I modified a skill

**What you do**: Edit a skill file in any Agent

**What SkillOnce does**:
1. Changes take effect immediately due to symlink
2. All Agents see the same file
3. No re-sync needed

**Result**: Changes you made in Claude Code are immediately visible in Cursor.

---

### Scenario 3: I deleted a skill

**What you do**: Delete a skill from any Agent

**What SkillOnce does**:
1. Removes the skill from all Agents
2. Deletes from skill repository

**Result**: The skill is gone from all Agents.

---

### Scenario 4: I installed a new Agent

**What you do**: Install a new AI Agent (e.g., Junie)

**What SkillOnce does**:
1. Auto-detects the new Agent on next sync
2. Syncs all existing skills to the new Agent
3. New Agent immediately has all skills

**Result**: All skills you previously installed are available in the new Agent.

---

### Scenario 5: I want to backup my skills

**What you do**: Backup the skill repository directory

**What SkillOnce does**:
1. Skill repository is a Git repository
2. Can push to GitHub/Gitee
3. Clone to restore on another computer

**Result**: All your skills have version control and cloud backup.

---

## Supported Agents

| Agent | Status |
|-------|--------|
| Claude Code | ✅ Supported |
| Cursor | ✅ Supported |
| Trae | ✅ Supported |
| Trae CN | ✅ Supported |
| Hermes | ✅ Supported |
| Qoder | ✅ Supported |
| Junie | ✅ Supported |
| Lingma | ✅ Supported |

---

## Installation

### Method 1: npx skills (Recommended)

```bash
npx skills add zhouhao111/skill-once
```

After installation, using skill-once in an AI Agent will prompt for initialization.

### Method 2: Git Clone

```bash
# Clone repository
git clone https://github.com/zhouhao111/skill-once.git ~/.agents/skill-once

# Run initialization wizard
bash ~/.agents/skill-once/scripts/init.sh
```

The initialization wizard will automatically:
1. Detect your installed Agents
2. Generate adapter configurations
3. Prompt for skill storage location
4. Configure CLI commands (auto-add to PATH)

### After Initialization

```bash
# Sync all skills to all Agents
skill-once sync
```

### Verify Installation

```bash
# View deployment status
skill-once status
```

---

## Quick Start

### Install Skill from GitHub

```bash
# Install specific skill
skill-once add https://github.com/user/repo --skill skill-name

# Install entire repository (if only one skill)
skill-once add https://github.com/user/repo
```

### Install Skill from Local

```bash
# Add from local directory
skill-once add my-skill /path/to/my-skill

# Sync to all Agents
skill-once sync
```

### Push Skill to Repository (Without Affecting Other Agents)

```bash
# Push to repository only, don't sync to other Agents
skill-once push my-skill /path/to/my-skill

# If other Agents need this skill, run sync
skill-once sync
```

### Sync from Remote Repository

```bash
# Add remote repository
skill-once remote add origin https://github.com/user/repo.git

# Pull from remote
skill-once pull origin

# Push to remote
skill-once push origin
```

### Delete Skill

```bash
skill-once remove my-skill
```

### View Status

```bash
skill-once status
```

---

## Command Reference

### Basic Commands

| Command | Description |
|---------|-------------|
| `skill-once init` | Initialize skill repository |
| `skill-once add <name> <path>` | Add skill to repository |
| `skill-once add .` | Add all skills |
| `skill-once remove <name>` | Remove skill from repository |
| `skill-once list` | List all skills |

### Sync Commands

| Command | Description |
|---------|-------------|
| `skill-once sync` | Sync all skills to all Agents |
| `skill-once pull <name>` | Pull skill to current Agent |
| `skill-once push <name> <path>` | Push skill to repository |

### Remote Commands

| Command | Description |
|---------|-------------|
| `skill-once remote add <name> <URL>` | Add remote repository |
| `skill-once remote remove <name>` | Remove remote repository |
| `skill-once remote list` | List remote repositories |
| `skill-once fetch` | Fetch from remote repositories |
| `skill-once pull origin` | Pull from remote |
| `skill-once push origin` | Push to remote |

### Viewing Commands

| Command | Description |
|---------|-------------|
| `skill-once status` | View deployment status |
| `skill-once diff <name>` | View skill changes |
| `skill-once log` | View commit history |

---

## FAQ

### Q: Will it overwrite Agent's built-in skills?

**A: No.** SkillOnce automatically skips existing directories and only creates symlinks. Agent's built-in skills are completely unaffected.

### Q: Can I sync only to some Agents?

**A: Yes.** In the `adapters/` directory, rename the configuration files for Agents you want to skip (prefix with `_`).

### Q: Can the skill repository be in a Git repository?

**A: Yes.** The default path `~/.agents/.mySkillRepository` is a Git repository. You can push to GitHub for multi-machine sync.

### Q: How do I backup my skills?

**A:** The skill repository is an independent Git repository. Just backup the `~/.agents/.mySkillRepository` directory.

### Q: Does it support Windows?

**A: Not currently.** SkillOnce uses bash scripts and symlinks, only supporting macOS and Linux.

### Q: How do I use the CLI commands?

**A:** After initialization, CLI commands are automatically added to PATH. If they don't work, run:

```bash
# Re-initialize
skill-once init

# Or manually add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

---

## Technical Details

> The following content is for users who want to understand the implementation details. Regular users don't need to read this.

### How It Works

```
~/.agents/.mySkillRepository/         ← Single source of truth (your skills)
├── my-skill-1/
│   └── SKILL.md
├── my-skill-2/
│   └── SKILL.md
└── ...

All Agents reference via symlink:
~/.claude/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.cursor/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.hermes/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
```

### Core Features

| Feature | Description |
|---------|-------------|
| **Symlink Sync** | Based on symlinks, zero copies, changes take effect immediately |
| **Auto Detection** | Automatically detects installed Agents and their skill rules |
| **Built-in Protection** | Skips Agent's native skills, no conflicts |
| **Configurable** | Skill storage path is customizable |
| **Lightweight** | Pure bash scripts, no extra dependencies |
| **Extensible** | Easily add support for new Agents |
| **Git-style** | Git-like CLI commands |

### Project Structure

```
~/.agents/skill-once/
├── SKILL.md                    # Skill definition for Agents
├── config.yaml                 # Configuration file
├── bin/                        # CLI commands
│   └── skill-once              # Main command
├── adapters/                   # Agent adapter configurations
├── scripts/                    # Management scripts
│   ├── init.sh                 # Initialize
│   ├── add.sh                  # Add skill
│   ├── add-all.sh              # Add all skills
│   ├── remove.sh               # Remove skill
│   ├── sync.sh                 # Sync skills
│   ├── pull.sh                 # Pull skill
│   ├── push-to-repo.sh         # Push to repository
│   ├── push-remote.sh          # Push to remote
│   ├── pull-remote.sh          # Pull from remote
│   ├── remote-add.sh           # Add remote repository
│   ├── remote-remove.sh        # Remove remote repository
│   ├── remote-list.sh          # List remote repositories
│   ├── fetch.sh                # Fetch from remote
│   ├── diff.sh                 # View changes
│   ├── log.sh                  # View history
│   ├── status.sh               # View status
│   └── detect.sh               # Detect Agents
└── templates/                  # Skill templates
```

### Adding New Agent

Create `<agent-name>.yaml` in `~/.agents/skill-once/adapters/`:

```yaml
name: agent-name
path: ~/.<agent-name>/skills
supports_symlink: true
builtin_paths:
  - ~/.<agent-name>/builtin/    # Optional: built-in skill directory
```

Then run `skill-once sync`.

---

## Roadmap

- [x] Symlink sync mechanism
- [x] Auto detection of Agents
- [x] Configuration generation
- [x] Built-in skill protection
- [x] Git-style CLI commands
- [x] Remote repository management
- [x] Auto PATH configuration
- [ ] `--dry-run` preview mode
- [ ] `validate` command to verify skill format
- [ ] Incremental sync (based on file hash)
- [ ] Multiple skill repository support

## Contributing

Contributions welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License - See [LICENSE](LICENSE)

---

<p align="center">
  <sub>Built with ❤️ for the AI Agent community</sub>
</p>
