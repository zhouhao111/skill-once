#!/bin/bash
# 同步所有 skill 到各 agent

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

SYNCED=0
SKIPPED=0
WARNED=0

echo "🔄 同步 skill 到各 agent..."
echo "   Skill 仓库: $SKILL_DIR"
echo ""

for skill in "$SKILL_DIR"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")

    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] && continue

        if [ -L "$agent_path/$name" ]; then
            ((SKIPPED++))
            continue
        fi

        if [ -d "$agent_path/$name" ]; then
            echo "  ⚠️  $name 在 $agent_name 中是真实目录，跳过"
            ((WARNED++))
            continue
        fi

        mkdir -p "$agent_path"
        ln -s "$skill" "$agent_path/$name"
        echo "  ✅ $name → $agent_name"
        ((SYNCED++))
    done
done

echo ""
echo "同步完成: $SYNCED 个创建, $SKIPPED 个已存在, $WARNED 个跳过"
