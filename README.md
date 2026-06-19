# SkillOnce

> 像 git 一样优雅的 AI Agent Skill 管理工具。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[English](README.en.md) | 简体中文

## 这是什么？

你同时使用多个 AI Agent（Claude Code、Cursor、Trae、Hermes 等）吗？

**SkillOnce** 让你在任何 Agent 中安装的 skill，自动同步到所有 Agent。你只需安装一次，所有 Agent 都能用。

```
你装了一个 skill
     ↓
SkillOnce 自动同步到所有 Agent
     ↓
Claude Code ✅  Cursor ✅  Trae ✅  Hermes ✅  ...
```

---

## 核心特性

### 🔄 像 git 一样优雅

```bash
skill-once init                    # 初始化仓库
skill-once add my-skill ./my-skill # 添加 skill
skill-once add .                   # 添加所有 skill
skill-once sync                    # 同步到所有 Agent
skill-once pull my-skill           # 拉取 skill
skill-once push origin             # 推送到远程
```

### 🌐 远程仓库管理

```bash
skill-once remote add origin https://github.com/user/repo.git
skill-once remote add gitee https://gitee.com/user/repo.git
skill-once remote list
skill-once fetch
skill-once pull origin
skill-once push origin
```

### 📊 状态查看

```bash
skill-once status    # 查看部署状态
skill-once diff      # 查看变更
skill-once log       # 查看历史
```

---

## 场景说明

### 场景 1：我装了一个新 skill

**你做的事**：在任意 Agent 中安装一个 skill

**SkillOnce 自动做的事**：
1. 检测到新 skill
2. 同步到 skill 仓库
3. 通过 symlink 部署到所有其他 Agent
4. 所有 Agent 立即可用

**结果**：你在 Claude Code 装的 skill，Cursor、Trae、Hermes 都能用。

---

### 场景 2：我修改了 skill 的内容

**你做的事**：编辑任意 Agent 中的 skill 文件

**SkillOnce 自动做的事**：
1. 由于 symlink 机制，修改直接生效
2. 所有 Agent 看到的是同一个文件
3. 无需重新同步

**结果**：你在 Claude Code 修改了 skill，Cursor 立即看到最新版本。

---

### 场景 3：我删除了一个 skill

**你做的事**：删除任意 Agent 中的 skill

**SkillOnce 自动做的事**：
1. 从所有 Agent 中移除该 skill
2. 从 skill 仓库中删除

**结果**：所有 Agent 中该 skill 都消失了。

---

### 场景 4：我安装了一个新的 Agent

**你做的事**：安装新的 AI Agent（比如 Junie）

**SkillOnce 自动做的事**：
1. 下次同步时自动检测到新 Agent
2. 将所有已有 skill 同步到新 Agent
3. 新 Agent 立即拥有所有 skill

**结果**：你之前装的所有 skill，新 Agent 都能用。

---

### 场景 5：我想备份我的 skill

**你做的事**：备份 skill 仓库目录

**SkillOnce 自动做的事**：
1. skill 仓库是一个 Git 仓库
2. 可以推送到 GitHub/Gitee
3. 换电脑时直接 clone 恢复

**结果**：你的所有 skill 都有版本控制和云端备份。

---

## 支持的 Agent

| Agent | 状态 |
|-------|------|
| Claude Code | ✅ 支持 |
| Cursor | ✅ 支持 |
| Trae | ✅ 支持 |
| Trae CN | ✅ 支持 |
| Hermes | ✅ 支持 |
| Qoder | ✅ 支持 |
| Junie | ✅ 支持 |
| Lingma | ✅ 支持 |

---

## 安装

### 方式 1：npx skills（推荐）

```bash
npx skills add zhouhao111/skill-once
```

安装后，在 AI Agent 中使用 skill-once 时会自动提示初始化。

### 方式 2：Git Clone

```bash
# 克隆仓库
git clone https://github.com/zhouhao111/skill-once.git ~/.agents/skill-once

# 运行初始化向导
bash ~/.agents/skill-once/scripts/init.sh
```

初始化向导会自动：
1. 检测你已安装的 Agent
2. 生成适配器配置
3. 提示选择 skill 存储位置
4. 配置 CLI 命令（自动添加到 PATH）

### 初始化完成后

```bash
# 同步所有 skill 到各 Agent
skill-once sync
```

### 验证安装

```bash
# 查看部署状态
skill-once status
```

---

## 快速开始

### 从 GitHub 安装 Skill

```bash
# 安装指定 skill
skill-once add https://github.com/user/repo --skill skill-name

# 安装整个仓库（如果只有一个 skill）
skill-once add https://github.com/user/repo
```

### 从本地安装 Skill

```bash
# 从本地目录添加
skill-once add my-skill /path/to/my-skill

# 同步到所有 Agent
skill-once sync
```

### 推送 Skill 到仓库（不影响其他 Agent）

```bash
# 只推送到仓库，不同步到其他 Agent
skill-once push my-skill /path/to/my-skill

# 如果其他 Agent 也需要使用，执行同步
skill-once sync
```

### 从远程仓库同步

```bash
# 添加远程仓库
skill-once remote add origin https://github.com/user/repo.git

# 从远程拉取
skill-once pull origin

# 推送到远程
skill-once push origin
```

### 删除 Skill

```bash
skill-once remove my-skill
```

### 查看状态

```bash
skill-once status
```

---

## 命令参考

### 基础命令

| 命令 | 说明 |
|------|------|
| `skill-once init` | 初始化 skill 仓库 |
| `skill-once add <名称> <路径>` | 添加 skill 到仓库 |
| `skill-once add .` | 添加所有 skill |
| `skill-once remove <名称>` | 从仓库删除 skill |
| `skill-once list` | 列出所有 skill |

### 同步命令

| 命令 | 说明 |
|------|------|
| `skill-once sync` | 同步所有 skill 到各 Agent |
| `skill-once pull <名称>` | 从仓库拉取 skill 到当前 Agent |
| `skill-once push <名称> <路径>` | 推送 skill 到仓库 |

### 远程命令

| 命令 | 说明 |
|------|------|
| `skill-once remote add <名称> <URL>` | 添加远程仓库 |
| `skill-once remote remove <名称>` | 删除远程仓库 |
| `skill-once remote list` | 列出远程仓库 |
| `skill-once fetch` | 从远程仓库获取更新 |
| `skill-once pull origin` | 从远程仓库拉取 |
| `skill-once push origin` | 推送到远程仓库 |

### 查看命令

| 命令 | 说明 |
|------|------|
| `skill-once status` | 查看部署状态 |
| `skill-once diff <名称>` | 查看 skill 变更 |
| `skill-once log` | 查看提交历史 |

---

## 常见问题

### Q: 会覆盖 Agent 的内置 skill 吗？

**A: 不会。** SkillOnce 自动跳过已存在的目录，只创建 symlink。Agent 的内置 skill 完全不受影响。

### Q: 可以只同步到部分 Agent 吗？

**A: 可以。** 在 `adapters/` 目录下，将不需要的 Agent 配置文件重命名（以 `_` 开头）即可跳过。

### Q: Skill 仓库可以放在 Git 仓库中吗？

**A: 可以。** 默认路径 `~/.agents/.mySkillRepository` 是一个 Git 仓库，你可以推送到 GitHub 实现多机同步。

### Q: 如何备份我的 Skill？

**A:** Skill 仓库是独立的 Git 仓库，只需备份 `~/.agents/.mySkillRepository` 目录即可。

### Q: 支持 Windows 吗？

**A: 目前不支持。** SkillOnce 使用 bash 脚本和 symlink，仅支持 macOS 和 Linux。

### Q: CLI 命令如何使用？

**A:** 初始化后，CLI 命令会自动添加到 PATH。如果无法使用，请执行：

```bash
# 重新初始化
skill-once init

# 或手动添加到 PATH
export PATH="$HOME/.local/bin:$PATH"
```

---

## 底层原理（技术细节）

> 以下内容适合想了解实现细节的用户。普通用户无需阅读。

### 工作机制

```
~/.agents/.mySkillRepository/         ← 唯一真相源（你的 skill）
├── my-skill-1/
│   └── SKILL.md
├── my-skill-2/
│   └── SKILL.md
└── ...

各 Agent 通过 symlink 引用：
~/.claude/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.cursor/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
~/.hermes/skills/my-skill-1 → ~/.agents/.mySkillRepository/my-skill-1
```

### 核心特性

| 特性 | 说明 |
|------|------|
| **Symlink 同步** | 基于符号链接，零副本，修改即生效 |
| **自动检测** | 自动识别已安装的 Agent 及其 skill 规则 |
| **内置保护** | 跳过 Agent 的原生 skill，不会造成冲突 |
| **可配置** | skill 存储路径可自定义 |
| **轻量级** | 纯 bash 脚本，无额外依赖 |
| **可扩展** | 轻松添加对新 Agent 的支持 |
| **Git 风格** | 像 git 一样优雅的 CLI 命令 |

### 项目结构

```
~/.agents/skill-once/
├── SKILL.md                    # Agent 读取的 skill 定义
├── config.yaml                 # 配置文件
├── bin/                        # CLI 命令
│   └── skill-once              # 主命令
├── adapters/                   # Agent 适配器配置
├── scripts/                    # 管理脚本
│   ├── init.sh                 # 初始化
│   ├── add.sh                  # 添加 skill
│   ├── add-all.sh              # 添加所有 skill
│   ├── remove.sh               # 删除 skill
│   ├── sync.sh                 # 同步 skill
│   ├── pull.sh                 # 拉取 skill
│   ├── push-to-repo.sh         # 推送到仓库
│   ├── push-remote.sh          # 推送到远程
│   ├── pull-remote.sh          # 从远程拉取
│   ├── remote-add.sh           # 添加远程仓库
│   ├── remote-remove.sh        # 删除远程仓库
│   ├── remote-list.sh          # 列出远程仓库
│   ├── fetch.sh                # 从远程获取
│   ├── diff.sh                 # 查看变更
│   ├── log.sh                  # 查看历史
│   ├── status.sh               # 查看状态
│   └── detect.sh               # 检测 Agent
└── templates/                  # Skill 模板
```

### 添加新 Agent

在 `~/.agents/skill-once/adapters/` 创建 `<agent-name>.yaml`：

```yaml
name: agent-name
path: ~/.<agent-name>/skills
supports_symlink: true
builtin_paths:
  - ~/.<agent-name>/builtin/    # 可选：内置 skill 目录
```

然后运行 `skill-once sync` 即可。

---

## Roadmap

- [x] Symlink 同步机制
- [x] 自动检测 Agent
- [x] 配置生成
- [x] 内置 skill 保护
- [x] Git 风格 CLI 命令
- [x] 远程仓库管理
- [x] 自动配置 PATH
- [ ] `--dry-run` 预览模式
- [ ] `validate` 命令验证 skill 格式
- [ ] 增量同步（基于文件哈希）
- [ ] 多 skill 仓库支持

## 贡献

欢迎贡献！请参阅 [CONTRIBUTING.md](CONTRIBUTING.md)。

## License

MIT License - 详见 [LICENSE](LICENSE)

---

<p align="center">
  <sub>Built with ❤️ for the AI Agent community</sub>
</p>
