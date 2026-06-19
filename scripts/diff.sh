#!/bin/bash
# 查看 skill 变更

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

skill_name="$1"

if [ -z "$skill_name" ]; then
    echo "用法: bash diff.sh <skill-name>"
    exit 1
fi

# 检查 skill 是否存在
if [ ! -d "$SKILL_DIR/$skill_name" ]; then
    echo "❌ skill '$skill_name' 不存在"
    exit 1
fi

# 检查是否是 git 仓库
if [ ! -d "$SKILL_DIR/.git" ]; then
    echo "❌ skill 仓库不是 git 仓库"
    echo "   请先运行: cd $SKILL_DIR && git init"
    exit 1
fi

cd "$SKILL_DIR"

# 查看变更
echo "📝 查看变更: $skill_name"
echo ""

git diff "$skill_name"
