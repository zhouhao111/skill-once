#!/bin/bash
# 从远程仓库拉取

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

remote="$1"

if [ -z "$remote" ]; then
    echo "用法: bash pull-remote.sh <remote>"
    echo "  remote: origin, github, gitee"
    exit 1
fi

# 检查是否是 git 仓库
if [ ! -d "$SKILL_DIR/.git" ]; then
    echo "❌ skill 仓库不是 git 仓库"
    echo "   请先运行: cd $SKILL_DIR && git init"
    exit 1
fi

cd "$SKILL_DIR"

# 检查远程仓库是否存在
if ! git remote | grep -q "^$remote$"; then
    echo "❌ 远程仓库 '$remote' 不存在"
    echo "   请先运行: skill-once remote add $remote <URL>"
    exit 1
fi

echo "📥 从远程仓库拉取: $remote"
echo ""

# 拉取更新
git pull "$remote" main

echo ""
echo "✅ 已从 $remote 拉取"
