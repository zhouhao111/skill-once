#!/bin/bash
# 同步 skill（只同步已安装 SkillOnce 的 Agent）

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

# 检查 Agent 是否安装了 SkillOnce
is_installed() {
    local agent_path="$1"
    [ -L "$agent_path/skill-once" ] || [ -d "$agent_path/skill-once" ]
}

SYNCED=0
SKIPPED=0
PULLED=0

echo "🔄 同步 skill..."
echo "   Skill 仓库: $SKILL_DIR"
echo ""

# Step 1: 从已安装的 Agent 拉取 skill 到仓库
echo "📥 Step 1: 从 Agent 拉取 skill 到仓库"
for conf in "$SKILL_ONCE/adapters/"*.yaml; do
    [ -f "$conf" ] || continue
    [[ "$(basename "$conf")" == _* ]] && continue

    agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
    agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
    agent_path=$(eval echo "$agent_path")

    [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

    # 只处理已安装 SkillOnce 的 Agent
    if ! is_installed "$agent_path"; then
        continue
    fi

    # 获取 builtin_paths
    builtin_paths=$(grep -A 10 "builtin_paths:" "$conf" | grep "  -" | awk '{print $2}')

    # 检查 Agent 中的 skill（非 symlink 的真实目录）
    for skill in "$agent_path"/*/; do
        [ -d "$skill" ] || continue
        [ -L "$skill" ] && continue  # 跳过 symlink

        name=$(basename "$skill")
        # 跳过 skill-once 本身
        [ "$name" = "skill-once" ] && continue

        # 跳过内置 skill
        skip=false
        for bp in $builtin_paths; do
            bp=$(eval echo "$bp")
            if [ -d "$bp/$name" ]; then
                skip=true
                break
            fi
        done
        $skip && continue

        if [ ! -d "$SKILL_DIR/$name" ]; then
            echo "  📦 从 $agent_name 拉取: $name"
            cp -r "$skill" "$SKILL_DIR/$name"
            ((PULLED++))
        fi
    done
done
echo ""

# Step 2: 从仓库推送到已安装的 Agent
echo "📤 Step 2: 从仓库推送到 Agent"
for skill in "$SKILL_DIR"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")

    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

        # 只处理已安装 SkillOnce 的 Agent
        if ! is_installed "$agent_path"; then
            continue
        fi

        if [ -L "$agent_path/$name" ]; then
            ((SKIPPED++))
            continue
        fi

        if [ -d "$agent_path/$name" ]; then
            ((SKIPPED++))
            continue
        fi

        mkdir -p "$agent_path"
        ln -s "$skill" "$agent_path/$name"
        echo "  ✅ $name → $agent_name"
        ((SYNCED++))
    done
done

echo ""
echo "同步完成:"
echo "  📥 从 Agent 拉取: $PULLED 个"
echo "  📤 推送到 Agent: $SYNCED 个"
echo "  ⏭️  跳过: $SKIPPED 个"
