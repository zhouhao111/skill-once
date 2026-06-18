#!/bin/bash
# 添加 skill 到 skill 仓库

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

name="$1"
source="$2"

if [ -z "$name" ] || [ -z "$source" ]; then
    echo "用法: bash add.sh <name> <source-path>"
    exit 1
fi

if [ -d "$SKILL_DIR/$name" ]; then
    echo "❌ skill '$name' 已存在"
    exit 1
fi

if [ ! -e "$source" ]; then
    echo "❌ 源路径不存在: $source"
    exit 1
fi

echo "📦 添加 skill: $name"

cp -r "$source" "$SKILL_DIR/$name"
echo "  已复制到 $SKILL_DIR/$name"

bash "$SKILL_ONCE/scripts/sync.sh"

echo ""
echo "✅ skill '$name' 已添加并同步"
