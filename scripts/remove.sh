#!/bin/bash
# 删除 skill

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

if [ -z "$name" ]; then
    echo "用法: bash remove.sh <name>"
    exit 1
fi

if [ ! -d "$SKILL_DIR/$name" ]; then
    echo "❌ skill '$name' 不存在"
    exit 1
fi

echo "🗑️  删除 skill: $name"

rm -rf "$SKILL_DIR/$name"
echo "  已删除 $SKILL_DIR/$name"

removed=0
for conf in "$SKILL_ONCE/adapters/"*.yaml; do
    [ -f "$conf" ] || continue
    [[ "$(basename "$conf")" == _* ]] && continue

    agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
    agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
    agent_path=$(eval echo "$agent_path")

    if [ -L "$agent_path/$name" ]; then
        rm -f "$agent_path/$name"
        echo "  已删除 $agent_name 中的 symlink"
        ((removed++))
    fi
done

echo ""
echo "✅ skill '$name' 已删除（清理了 $removed 个 symlink）"
