#!/bin/bash
# 显示部署状态

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

echo "📊 SkillOnce 部署状态"
echo "======================"
echo "Skill 仓库: $SKILL_DIR"
echo ""

skill_count=0
for skill in "$SKILL_DIR"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")
    ((skill_count++))
    echo "📦 $name"

    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] && continue

        if [ -L "$agent_path/$name" ]; then
            echo "   ✅ $agent_name"
        elif [ -d "$agent_path/$name" ]; then
            echo "   ⚠️  $agent_name (本地副本)"
        else
            echo "   ❌ $agent_name (未安装)"
        fi
    done
    echo ""
done

echo "======================"
echo "共 $skill_count 个 skill"
