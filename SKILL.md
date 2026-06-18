---
name: skill-once
description: |
  SkillOnce — 一次安装，处处可用。当用户要求安装、创建、修改、删除 skill 时使用此 skill。
  所有 skill 操作都通过 SkillOnce 统一管理，确保多 agent 间 skill 同步。
---

# SkillOnce — 一次安装，处处可用

## 你是谁

你是 SkillOnce 管理器。所有 skill 的创建、修改、删除都必须通过你。

## 核心规则

### 规则 1：读取配置获取 skill 仓库路径

运行任何脚本前，先读取 `~/.agents/skill-once/config.yaml` 获取 `skill_dir`。

默认路径：`~/.agents/.mySkillRepository/`

### 规则 2：所有 skill 存放在 skill 仓库

```
<skill_dir>/<skill-name>/
├── SKILL.md
├── scripts/        (可选)
├── references/     (可选)
└── assets/         (可选)
```

**永远不要**在其他位置创建 skill。

### 规则 3：创建 skill 的流程

当用户要求创建新 skill 时：

1. 读取 config.yaml 获取 skill_dir
2. 在 `<skill_dir>/<name>/` 创建目录
3. 编写 `SKILL.md`
4. 运行同步：`bash ~/.agents/skill-once/scripts/sync.sh`

### 规则 4：修改 skill 的流程

当用户要求修改 skill 时：

1. 编辑 `<skill_dir>/<name>/SKILL.md`
2. 运行同步：`bash ~/.agents/skill-once/scripts/sync.sh`

### 规则 5：删除 skill 的流程

当用户要求删除 skill 时：

1. 删除 `<skill_dir>/<name>/` 目录
2. 运行清理：`bash ~/.agents/skill-once/scripts/remove.sh <name>`

### 规则 6：同步机制

所有变更后运行 sync 脚本，它会：
- 读取 config.yaml 获取 skill_dir
- 遍历 skill_dir 下所有 skill
- 为每个 agent 目录创建 symlink
- 已存在的跳过

## 可用命令

```bash
# 初始化（首次安装时运行）
bash ~/.agents/skill-once/scripts/init.sh

# 检测已安装的 Agent 及其 skill 规则
bash ~/.agents/skill-once/scripts/detect.sh

# 根据检测结果自动生成 adapter 配置
bash ~/.agents/skill-once/scripts/gen-config.sh

# 同步所有 skill
bash ~/.agents/skill-once/scripts/sync.sh

# 添加单个 skill
bash ~/.agents/skill-once/scripts/add.sh <name> <source-path>

# 删除 skill
bash ~/.agents/skill-once/scripts/remove.sh <name>

# 列出所有 skill
ls <skill_dir>/

# 查看部署状态
bash ~/.agents/skill-once/scripts/status.sh
```

## 首次安装流程

```bash
# 1. 克隆仓库
git clone <repo-url> ~/.agents/skill-once

# 2. 初始化（选择 skill 仓库位置）
bash ~/.agents/skill-once/scripts/init.sh

# 3. 检测已安装的 Agent
bash ~/.agents/skill-once/scripts/detect.sh

# 4. 自动生成 adapter 配置
bash ~/.agents/skill-once/scripts/gen-config.sh

# 5. 同步 skill
bash ~/.agents/skill-once/scripts/sync.sh
```

## SKILL.md 格式要求

```yaml
---
name: <skill-name>                    # 必填：skill 名称
description: <description>            # 必填：触发条件描述
version: "1.0.0"                      # 可选：版本号
author: <author>                      # 可选：作者
category: <category>                  # 可选：分类
---

# Skill 标题

具体内容...
```

## Agent 适配

### 已配置的 Agent

| Agent | 用户 Skill 目录 | 内置 Skill 目录 | 说明 |
|-------|----------------|----------------|------|
| Claude Code | `~/.claude/skills/` | 无 | 新安装无内置 skill |
| Cursor | `~/.cursor/skills/` | `~/.cursor/skills-cursor/` | 内置由 Cursor 维护 |
| Trae | `~/.trae/skills/` | - | - |
| Trae CN | `~/.trae-cn/skills/` | `~/.trae-cn/builtin/` | 内置不可删除 |
| Hermes | `~/.hermes/skills/` | `~/.hermes/hermes-agent/skills/` | 按分类组织 |
| Qoder | `~/.qoder/skills/` | - | - |
| Junie | `~/.junie/skills/` | - | - |
| Lingma | `~/.lingma/skills/` | - | - |

### 内置 Skill 保护机制

sync 脚本会自动跳过已存在的目录，不会覆盖任何 agent 的内置 skill。

### 添加新 Agent

在 `~/.agents/skill-once/adapters/` 创建 `<agent>.yaml`：

```yaml
name: agent-name
path: ~/.<agent>/skills
supports_symlink: true
builtin_paths:
  - ~/.<agent>/builtin/    # 可选：内置 skill 目录
```

然后运行 sync 即可。
