# SkillOnce

> 一次安装，处处可用。AI Agent 公共 Skill 仓库管理工具。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.en.md) | 简体中文

## 目录

- [概述](#概述)
- [核心特性](#核心特性)
- [工作原理](#工作原理)
- [支持的 Agent](#支持的-agent)
- [安装](#安装)
- [使用指南](#使用指南)
- [配置](#配置)
- [项目结构](#项目结构)
- [命令参考](#命令参考)
- [添加新 Agent](#添加新-agent)
- [故障排除](#故障排除)
- [FAQ](#faq)
- [Roadmap](#roadmap)
- [贡献](#贡献)
- [License](#license)

---

## 概述

你是否同时使用多个 AI Agent 工具（Claude Code、Cursor、Trae、Hermes 等）？是否为同一个 skill 需要在每个 agent 中重复安装而烦恼？

**SkillOnce** 解决这个问题。它作为中心仓库，通过 symlink 将 skill 同步到所有 agent，实现：

- **一处安装，处处可用** — skill 只存一份，所有 agent 共享
- **一处修改，处处生效** — 修改源文件，所有 agent 立即更新
- **内置保护** — 不会覆盖任何 agent 的原生 skill

## 核心特性

| 特性 | 说明 |
|------|------|
| **Symlink 同步** | 基于符号链接，零副本，修改即生效 |
| **自动检测** | 自动识别已安装的 Agent 及其 skill 规则 |
| **内置保护** | 跳过 Agent 的原生 skill，不会造成冲突 |
| **可配置** | skill 存储路径可自定义 |
| **轻量级** | 纯 bash 脚本，无额外依赖 |
| **可扩展** | 轻松添加对新 Agent 的支持 |

## 工作原理

```
~/.agents/.mySkillRepository/         ← 唯一真相源（你的 skill）
├── my-skill-1/
│   └── SKILL.md
├── my-skill-2/
│   └── SKILL.md
└── ...

~/.agents/skill-once/                 ← 管理工具
├── SKILL.md                          ← 告诉 Agent 如何管理 skill
├── config.yaml                       ← 配置文件
├── adapters/                         ← Agent 适配器
└── scripts/                          ← 管理脚本

各 Agent 通过 symlink 引用：
~/.claude/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.cursor/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.hermes/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
...
```

## 支持的 Agent

| Agent | 用户 Skill 目录 | 内置 Skill 目录 | 状态 |
|-------|----------------|----------------|------|
| Claude Code | `~/.claude/skills/` | 无 | ✅ 支持 |
| Cursor | `~/.cursor/skills/` | `~/.cursor/skills-cursor/` | ✅ 支持 |
| Trae | `~/.trae/skills/` | - | ✅ 支持 |
| Trae CN | `~/.trae-cn/skills/` | `~/.trae-cn/builtin/` | ✅ 支持 |
| Hermes | `~/.hermes/skills/` | `~/.hermes/hermes-agent/skills/` | ✅ 支持 |
| Qoder | `~/.qoder/skills/` | - | ✅ 支持 |
| Junie | `~/.junie/skills/` | - | ✅ 支持 |
| Lingma | `~/.lingma/skills/` | - | ✅ 支持 |

## 安装

### 前置要求

- macOS 或 Linux
- Bash shell
- Git

### 步骤 1：克隆仓库

```bash
git clone https://github.com/your-username/skill-once.git ~/.agents/skill-once
```

### 步骤 2：初始化

```bash
bash ~/.agents/skill-once/scripts/init.sh
```

首次运行会提示选择 skill 存储位置：

```
🔧 SkillOnce 首次初始化

请选择 skill 仓库位置:
  1) ~/.agents/.mySkillRepository (默认，本地仓库)
  2) ~/.my-skills
  3) 自定义路径

输入选项 [1]: 
```

### 步骤 3：检测已安装的 Agent

```bash
bash ~/.agents/skill-once/scripts/detect.sh
```

输出示例：

```
📦 Claude Code
   用户 skill 目录: ~/.claude/skills
   内置 skill 目录: 未检测到

📦 Cursor
   用户 skill 目录: ~/.cursor/skills
   内置 skill 目录: ~/.cursor/skills-cursor
   内置 skill 数量: 18
```

### 步骤 4：生成 Agent 配置

```bash
bash ~/.agents/skill-once/scripts/gen-config.sh
```

### 步骤 5：同步 Skill

```bash
bash ~/.agents/skill-once/scripts/sync.sh
```

输出示例：

```
🔄 同步 skill 到各 agent...
   Skill 仓库: ~/.agents/.mySkillRepository

  ✅ my-skill → claude-code
  ✅ my-skill → cursor
  ✅ my-skill → hermes
  ...

同步完成: 24 个创建, 0 个已存在, 0 个跳过
```

## 使用指南

### 添加新 Skill

```bash
# 从本地目录添加
bash ~/.agents/skill-once/scripts/add.sh my-skill /path/to/my-skill

# 从 Git 仓库添加
git clone https://github.com/user/skill-repo.git /tmp/my-skill
bash ~/.agents/skill-once/scripts/add.sh my-skill /tmp/my-skill
```

### 修改 Skill

直接编辑 skill 源文件，然后同步：

```bash
# 编辑 skill
vim ~/.agents/.mySkillRepository/my-skill/SKILL.md

# 同步到所有 agent
bash ~/.agents/skill-once/scripts/sync.sh
```

### 删除 Skill

```bash
bash ~/.agents/skill-once/scripts/remove.sh my-skill
```

### 查看状态

```bash
bash ~/.agents/skill-once/scripts/status.sh
```

输出示例：

```
📊 SkillOnce 部署状态
======================
Skill 仓库: ~/.agents/.mySkillRepository

📦 my-skill
   ✅ claude-code
   ✅ cursor
   ✅ hermes
   ...

======================
共 6 个 skill
```

## 配置

### config.yaml

```yaml
# SkillOnce 配置
# skill_dir: skill 存储路径
skill_dir: ~/.agents/.mySkillRepository
```

### Adapter 配置示例

```yaml
# ~/.agents/skill-once/adapters/cursor.yaml
name: cursor
path: ~/.cursor/skills
supports_symlink: true
builtin_paths:
  - ~/.cursor/skills-cursor/
notes: |
  Cursor 内置 skill 在 skills-cursor/ 目录，由 Cursor 维护。
  我们只同步到用户目录 skills/。
```

## 项目结构

```
~/.agents/skill-once/
├── SKILL.md                    # Agent 读取的 skill 定义
├── README.md                   # 项目文档
├── config.yaml                 # 配置文件
├── adapters/                   # Agent 适配器配置
│   ├── _base.yaml              # 公共配置
│   ├── claude-code.yaml
│   ├── cursor.yaml
│   ├── hermes.yaml
│   ├── trae.yaml
│   ├── trae-cn.yaml
│   ├── qoder.yaml
│   ├── junie.yaml
│   └── lingma.yaml
├── scripts/                    # 管理脚本
│   ├── init.sh                 # 初始化
│   ├── detect.sh               # 检测 Agent
│   ├── gen-config.sh           # 生成配置
│   ├── sync.sh                 # 同步 skill
│   ├── add.sh                  # 添加 skill
│   ├── remove.sh               # 删除 skill
│   └── status.sh               # 查看状态
└── templates/                  # Skill 模板
    └── new-skill/
```

## 命令参考

| 命令 | 说明 | 示例 |
|------|------|------|
| `init.sh` | 初始化 SkillOnce | `bash scripts/init.sh` |
| `detect.sh` | 检测已安装的 Agent | `bash scripts/detect.sh` |
| `gen-config.sh` | 生成 Agent 配置 | `bash scripts/gen-config.sh` |
| `sync.sh` | 同步所有 skill | `bash scripts/sync.sh` |
| `add.sh` | 添加新 skill | `bash scripts/add.sh name path` |
| `remove.sh` | 删除 skill | `bash scripts/remove.sh name` |
| `status.sh` | 查看部署状态 | `bash scripts/status.sh` |

## 添加新 Agent

### 步骤 1：创建 Adapter 配置

在 `~/.agents/skill-once/adapters/` 创建 `<agent-name>.yaml`：

```yaml
name: agent-name
path: ~/.<agent-name>/skills
supports_symlink: true
builtin_paths:
  - ~/.<agent-name>/builtin/    # 可选：内置 skill 目录
notes: |
  说明信息...
```

### 步骤 2：运行同步

```bash
bash ~/.agents/skill-once/scripts/sync.sh
```

## 故障排除

### Symlink 已存在

**现象**：`⚠️ xxx 在 agent_name 中是真实目录，跳过`

**原因**：该 skill 在 agent 中是真实目录（非 symlink），可能是 agent 原生或手动安装的。

**解决**：
1. 如果是手动安装的，可删除后重新同步
2. 如果是 agent 原生的，无需处理（会被保护）

### Skill 未同步到某个 Agent

**现象**：`status.sh` 显示某个 agent 未安装

**原因**：该 agent 的 skill 目录不存在或未配置。

**解决**：
1. 运行 `detect.sh` 检测 agent
2. 运行 `gen-config.sh` 生成配置
3. 重新运行 `sync.sh`

### 如何修改 Skill 存储路径

编辑 `~/.agents/skill-once/config.yaml`：

```yaml
skill_dir: ~/.新的路径
```

然后重新运行 `sync.sh`。

## FAQ

### Q: SkillOnce 会覆盖 Agent 的内置 skill 吗？

**A: 不会。** sync 脚本会跳过已存在的目录，只创建 symlink。Agent 的内置 skill 完全不受影响。

### Q: 可以只同步到部分 Agent 吗？

**A: 可以。** 编辑 `adapters/` 目录下不需要的 agent 配置文件，将其移除或重命名（以 `_` 开头的文件会被跳过）。

### Q: Skill 仓库可以放在 Git 仓库中吗？

**A: 可以。** 默认路径 `~/.agents/.mySkillRepository` 是一个 Git 仓库，你可以推送到 GitHub 实现多机同步。

### Q: 如何备份我的 Skill？

**A:** Skill 仓库是独立的 Git 仓库，只需备份 `~/.agents/.mySkillRepository` 目录即可。

### Q: 支持 Windows 吗？

**A: 目前不支持。** SkillOnce 使用 bash 脚本和 symlink，仅支持 macOS 和 Linux。

## Roadmap

### Phase 1: 基础功能 ✅

- [x] Symlink 同步机制
- [x] 自动检测 Agent
- [x] 配置生成
- [x] 内置 skill 保护

### Phase 2: 增强功能

- [ ] `--dry-run` 预览模式
- [ ] `validate` 命令验证 skill 格式
- [ ] 增量同步（基于文件哈希）
- [ ] 多 skill 仓库支持

### Phase 3: Maven 模式

- [ ] `skill.yaml` 格式（类似 pom.xml）
- [ ] 依赖管理
- [ ] 版本控制
- [ ] 中央仓库支持

## 贡献

欢迎贡献！请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

### 开发流程

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 创建 Pull Request

## License

MIT License - 详见 [LICENSE](LICENSE)

---

<p align="center">
  <sub>Built with ❤️ for the AI Agent community</sub>
</p>
