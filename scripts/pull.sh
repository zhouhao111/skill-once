#!/bin/bash
# 拉取模式：检查并同步单个 skill

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
    echo "用法: bash pull.sh <skill-name>"
    exit 1
fi

# 检查 skill 是否在仓库中
if [ ! -d "$SKILL_DIR/$skill_name" ]; then
    echo "❌ skill '$skill_name' 不在仓库中"
    echo "   仓库路径: $SKILL_DIR"
    exit 1
fi

echo "🔍 检查 skill: $skill_name"
echo "   仓库: $SKILL_DIR/$skill_name"
echo ""

SYNCED=0
SKIPPED=0

for conf in "$SKILL_ONCE/adapters/"*.yaml; do
    [ -f "$conf" ] || continue
    [[ "$(basename "$conf")" == _* ]] && continue

    agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
    agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
    agent_path=$(eval echo "$agent_path")

    [ -z "$agent_path" ] && continue

    if [ -L "$agent_path/$skill_name" ]; then
        ((SKIPPED++))
        continue
    fi

    if [ -d "$agent_path/$skill_name" ]; then
        echo "  ⚠️  $agent_name 中已存在真实目录，跳过"
        ((SKIPPED++))
        continue
    fi

    mkdir -p "$agent_path"
    ln -s "$SKILL_DIR/$skill_name" "$agent_path/$skill_name"
    echo "  ✅ $skill_name → $agent_name"
    ((SYNCED++))
done

echo ""
if [ $SYNCED -gt 0 ]; then
    echo "✅ 已拉取到 $SYNCED 个 agent"
elif [ $SKIPPED -gt 0 ]; then
    echo "ℹ️  所有 agent 已有该 skill，无需同步"
fi
