# SkillOnce

> Install once, use everywhere. A skill repository manager for multiple AI Agents.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [How It Works](#how-it-works)
- [Supported Agents](#supported-agents)
- [Installation](#installation)
- [Usage Guide](#usage-guide)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Command Reference](#command-reference)
- [Adding New Agents](#adding-new-agents)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

Do you use multiple AI Agent tools (Claude Code, Cursor, Trae, Hermes, etc.) at the same time? Are you tired of installing the same skill repeatedly in each agent?

**SkillOnce** solves this problem. It acts as a central repository, syncing skills to all agents via symlinks:

- **Install once, use everywhere** — Skills are stored once, shared by all agents
- **Modify once, update everywhere** — Edit the source file, all agents update immediately
- **Built-in protection** — Never overwrites any agent's native skills

## Key Features

| Feature | Description |
|---------|-------------|
| **Symlink Sync** | Zero-copy, modifications take effect immediately |
| **Auto Detection** | Automatically identifies installed agents and their skill rules |
| **Built-in Protection** | Skips agent's native skills to avoid conflicts |
| **Configurable** | Customizable skill repository path |
| **Lightweight** | Pure bash scripts, no dependencies |
| **Extensible** | Easily add support for new agents |

## How It Works

```
~/.agents/.mySkillRepository/         ← Single source of truth (your skills)
├── my-skill-1/
│   └── SKILL.md
├── my-skill-2/
│   └── SKILL.md
└── ...

~/.agents/skill-once/                 ← Management tool
├── SKILL.md                          ← Tells agents how to manage skills
├── config.yaml                       ← Configuration file
├── adapters/                         ← Agent adapters
└── scripts/                          ← Management scripts

Agents reference via symlinks:
~/.claude/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.cursor/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.hermes/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
...
```

## Supported Agents

| Agent | User Skill Directory | Built-in Skill Directory | Status |
|-------|---------------------|-------------------------|--------|
| Claude Code | `~/.claude/skills/` | None | ✅ Supported |
| Cursor | `~/.cursor/skills/` | `~/.cursor/skills-cursor/` | ✅ Supported |
| Trae | `~/.trae/skills/` | - | ✅ Supported |
| Trae CN | `~/.trae-cn/skills/` | `~/.trae-cn/builtin/` | ✅ Supported |
| Hermes | `~/.hermes/skills/` | `~/.hermes/hermes-agent/skills/` | ✅ Supported |
| Qoder | `~/.qoder/skills/` | - | ✅ Supported |
| Junie | `~/.junie/skills/` | - | ✅ Supported |
| Lingma | `~/.lingma/skills/` | - | ✅ Supported |

## Installation

### Method 1: npx skills (Recommended)

```bash
npx skills add zhouhao111/skill-once
```

After installation, you'll be prompted to initialize when using skill-once in an AI Agent.

### Method 2: Git Clone

```bash
# Clone the repository
git clone https://github.com/zhouhao111/skill-once.git ~/.agents/skill-once

# Run initialization wizard
bash ~/.agents/skill-once/scripts/init.sh
```

First run will prompt you to choose a skill storage location:

```
🔧 SkillOnce First Initialization

Please choose skill repository location:
  1) ~/.agents/.mySkillRepository (default, local repository)
  2) ~/.my-skills
  3) Custom path

Enter option [1]: 
```

### After Initialization

```bash
# Sync all skills to all Agents
bash ~/.agents/skill-once/scripts/sync.sh
```

### Verify Installation

```bash
# View deployment status
skill-once status
# Or
bash ~/.agents/skill-once/scripts/status.sh
```

## Usage Guide

### Installing Skills from GitHub

```bash
# Install a specific skill
skill-once add https://github.com/user/repo --skill skill-name

# Install the entire repository (if it contains only one skill)
skill-once add https://github.com/user/repo
```

### Adding Skills from Local Directory

```bash
# Add from local directory
skill-once add my-skill /path/to/my-skill

# Sync to all agents
skill-once sync
```

### Modifying a Skill

Edit the skill source file directly, then sync:

```bash
# Edit skill
vim ~/.agents/.mySkillRepository/my-skill/SKILL.md

# Sync to all agents
skill-once sync
```

### Deleting a Skill

```bash
skill-once remove my-skill
```

### Viewing Status

```bash
skill-once status
```

Example output:

```
📊 SkillOnce Deployment Status
======================
Skill repository: ~/.agents/.mySkillRepository

📦 my-skill
   ✅ claude-code
   ✅ cursor
   ✅ hermes
   ...

======================
Total: 6 skills
```

## Configuration

### config.yaml

```yaml
# SkillOnce Configuration
# skill_dir: Skill storage path
skill_dir: ~/.agents/.mySkillRepository
```

### Adapter Configuration Example

```yaml
# ~/.agents/skill-once/adapters/cursor.yaml
name: cursor
path: ~/.cursor/skills
supports_symlink: true
builtin_paths:
  - ~/.cursor/skills-cursor/
notes: |
  Cursor built-in skills are in skills-cursor/ directory, maintained by Cursor.
  We only sync to user directory skills/.
```

## Project Structure

```
~/.agents/skill-once/
├── SKILL.md                    # Skill definition read by agents
├── README.md                   # Project documentation (Chinese)
├── README.en.md                # Project documentation (English)
├── LICENSE                     # MIT License
├── package.json                # npm package configuration
├── config.yaml                 # Configuration file
├── bin/                        # CLI entry point
│   └── skill-once              # Global CLI command
├── adapters/                   # Agent adapter configurations
│   ├── _base.yaml              # Base configuration
│   ├── claude-code.yaml
│   ├── cursor.yaml
│   ├── hermes.yaml
│   ├── trae.yaml
│   ├── trae-cn.yaml
│   ├── qoder.yaml
│   ├── junie.yaml
│   └── lingma.yaml
├── scripts/                    # Management scripts
│   ├── init.sh                 # Initialize
│   ├── detect.sh               # Detect agents
│   ├── gen-config.sh           # Generate configuration
│   ├── sync.sh                 # Sync skills
│   ├── add.sh                  # Add skill from local
│   ├── add-from-git.sh         # Add skill from GitHub
│   ├── remove.sh               # Remove skill
│   └── status.sh               # View status
└── templates/                  # Skill templates
    └── new-skill/
```

## Command Reference

| Command | Description | Example |
|---------|-------------|---------|
| `skill-once init` | Initialize SkillOnce | `skill-once init` |
| `skill-once add <name> <path>` | Add skill from local | `skill-once add my-skill ./my-skill` |
| `skill-once add <URL> --skill <name>` | Install from GitHub | `skill-once add https://github.com/user/repo --skill xxx` |
| `skill-once remove <name>` | Delete skill | `skill-once remove my-skill` |
| `skill-once sync` | Sync all skills | `skill-once sync` |
| `skill-once status` | View deployment status | `skill-once status` |
| `skill-once list` | List all skills | `skill-once list` |
| `skill-once detect` | Detect installed agents | `skill-once detect` |

## Adding New Agents

### Step 1: Create Adapter Configuration

Create `<agent-name>.yaml` in `~/.agents/skill-once/adapters/`:

```yaml
name: agent-name
path: ~/.<agent-name>/skills
supports_symlink: true
builtin_paths:
  - ~/.<agent-name>/builtin/    # Optional: built-in skill directory
notes: |
  Description...
```

### Step 2: Run Sync

```bash
bash ~/.agents/skill-once/scripts/sync.sh
```

## Troubleshooting

### Symlink Already Exists

**Symptom**: `⚠️ xxx in agent_name is a real directory, skipped`

**Cause**: The skill is a real directory in the agent (not a symlink), possibly native or manually installed.

**Solution**:
1. If manually installed, delete it and re-sync
2. If agent-native, no action needed (will be protected)

### Skill Not Synced to an Agent

**Symptom**: `status.sh` shows an agent as not installed

**Cause**: The agent's skill directory doesn't exist or isn't configured.

**Solution**:
1. Run `detect.sh` to detect the agent
2. Run `gen-config.sh` to generate configuration
3. Run `sync.sh` again

### How to Change Skill Repository Path

Edit `~/.agents/skill-once/config.yaml`:

```yaml
skill_dir: ~/.new-path
```

Then run `sync.sh` again.

## FAQ

### Q: Will SkillOnce overwrite Agent's built-in skills?

**A: No.** The sync script skips existing directories and only creates symlinks. Agent's built-in skills are completely unaffected.

### Q: Can I sync only to specific Agents?

**A: Yes.** Edit or remove the adapter configuration files in `adapters/` directory for agents you don't want. Files starting with `_` are skipped.

### Q: Can the skill repository be in a Git repository?

**A: Yes.** The default path `~/.agents/.mySkillRepository` is a Git repository. You can push to GitHub for multi-machine sync.

### Q: How do I backup my skills?

**A:** The skill repository is an independent Git repository. Just backup `~/.agents/.mySkillRepository` directory.

### Q: Does it support Windows?

**A: Not currently.** SkillOnce uses bash scripts and symlinks, supporting only macOS and Linux.

## Roadmap

### Phase 1: Core Features ✅

- [x] Symlink sync mechanism
- [x] Auto-detect agents
- [x] Configuration generation
- [x] Built-in skill protection

### Phase 2: Enhanced Features

- [ ] `--dry-run` preview mode
- [ ] `validate` command for skill format validation
- [ ] Incremental sync (file hash based)
- [ ] Multiple skill repository support

### Phase 3: Maven Mode

- [ ] `skill.yaml` format (similar to pom.xml)
- [ ] Dependency management
- [ ] Version control
- [ ] Central repository support

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md).

### Development Process

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Create a Pull Request

## License

MIT License - See [LICENSE](LICENSE) for details.

---

<p align="center">
  <sub>Built with ❤️ for the AI Agent community</sub>
</p>
