---
name: skill-once
description: |
  Install once, use everywhere. After install, run: bash ~/.agents/skill-once/scripts/init.sh && bash ~/.agents/skill-once/scripts/sync.sh. A skill repository manager for multiple AI Agents (Claude Code, Cursor, Trae, Hermes, Qoder, Junie, Lingma). Use this skill when: user wants to install, create, modify, delete, or sync skills across multiple AI agents.
---

# SkillOnce — 一次安装，处处可用

## 自动检查（首次使用时执行）

当用户提到或使用 skill-once 时，**必须先执行以下检查**：

```bash
# 检查是否已初始化
cat ~/.agents/skill-once/config.yaml 2>/dev/null | head -1
```

**如果输出为空或报错**，说明尚未初始化，立即提醒用户并询问：

"SkillOnce 尚未初始化，是否现在执行初始化和同步？"

如果用户同意，执行：

```bash
# 1. 初始化（选择 skill 仓库位置）
bash ~/.agents/skill-once/scripts/init.sh

# 2. 同步所有 skill 到各 Agent
bash ~/.agents/skill-once/scripts/sync.sh
```

**如果输出正常**（显示 skill_dir 路径），说明已初始化，继续执行用户请求的操作。
---

SkillOnce 是一个 skill 仓库管理器，让你在任何 Agent 中安装的 skill 自动同步到所有 Agent。

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

**区分两种情况：**

**情况A：卸载 skill-once 本身**
- 只删除当前 AI Agent 的 skill 目录下的 symlink
- **不要**删除仓库中的 skill-once（`~/.agents/skill-once/`）
- 命令：`rm ~/.claude/skills/skill-once`（以Claude Code为例）

**情况B：卸载其他 skill**
- 从仓库中删除：`rm -rf <skill_dir>/<name>/`
- **检测断链并清理**：
  ```bash
  # 检测所有agent目录下的断链
  find ~/.claude/skills ~/.cursor/skills ~/.hermes/skills ~/.trae/skills ~/.trae-cn/skills ~/.junie/skills ~/.lingma/skills ~/.qoder/skills -type l ! -exec test -e {} \; -print 2>/dev/null
  ```
- 发现断链后提醒用户并删除：
  ```
  发现断链：
  - ~/.cursor/skills/xxx（指向不存在的文件）
  
  是否删除这些断链？
  ```

判断方法：如果 `<name>` 等于 `skill-once`，执行情况A；否则执行情况B。

### 规则 6：拉取模式（推荐）

当用户要求使用某个 skill 时：

1. 检查 skill 是否在仓库中：`ls ~/.agents/.mySkillRepository/<skill-name>`
2. 如果存在但本地没有 symlink，自动拉取：
   ```bash
   bash ~/.agents/skill-once/scripts/pull.sh <skill-name>
   ```
3. 然后执行 skill

### 规则 7：推送模式（批量同步）

所有变更后可运行 sync 脚本，批量同步所有 skill：
- 读取 config.yaml 获取 skill_dir
- 遍历 skill_dir 下所有 skill
- 为每个 agent 目录创建 symlink
- 已存在的跳过

### 规则 8：断链检测

当用户提到"断链"、"清理"、"检查skill"时，执行断链检测：

```bash
# 检测所有agent目录下的断链
find ~/.claude/skills ~/.cursor/skills ~/.hermes/skills ~/.trae/skills ~/.trae-cn/skills ~/.junie/skills ~/.lingma/skills ~/.qoder/skills -type l ! -exec test -e {} \; -print 2>/dev/null
```

发现断链后：
1. 列出所有断链
2. 询问用户是否删除
3. 用户确认后删除断链

## 可用命令

```bash
# 初始化（首次安装时运行）
bash ~/.agents/skill-once/scripts/init.sh

# 检测已安装的 Agent 及其 skill 规则
bash ~/.agents/skill-once/scripts/detect.sh

# 根据检测结果自动生成 adapter 配置
bash ~/.agents/skill-once/scripts/gen-config.sh

# 拉取单个 skill（推荐）
bash ~/.agents/skill-once/scripts/pull.sh <skill-name>

# 同步所有 skill（批量）
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
