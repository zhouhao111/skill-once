#!/bin/bash
# 推送 skill 到仓库（不影响其他 Agent）

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
    echo "用法: bash push-to-repo.sh <name> <source-path>"
    exit 1
fi

# 检查源路径是否存在
if [ ! -e "$source" ]; then
    echo "❌ 源路径不存在: $source"
    exit 1
fi

# 检查是否已存在
if [ -d "$SKILL_DIR/$name" ]; then
    echo "⚠️  skill '$name' 已存在，将覆盖"
    rm -rf "$SKILL_DIR/$name"
fi

echo "📦 推送 skill 到仓库: $name"

# 复制到仓库
cp -r "$source" "$SKILL_DIR/$name"
echo "  ✅ 已复制到 $SKILL_DIR/$name"

echo ""
echo "✅ skill '$name' 已推送到仓库"
echo ""
echo "💡 提示: 如果其他 Agent 也需要使用此 skill，请执行:"
echo "   skill-once sync"
echo "   或"
echo "   bash ~/.agents/skill-once/scripts/pull.sh $name"
