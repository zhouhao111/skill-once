#!/bin/bash
# 添加所有 skill 到仓库

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

echo "📦 扫描所有 Agent 的 skill..."
echo ""

# 获取所有 Agent 的 skill 目录
AGENTS=(
    "$HOME/.claude/skills"
    "$HOME/.cursor/skills"
    "$HOME/.trae/skills"
    "$HOME/.trae-cn/skills"
    "$HOME/.hermes/skills"
    "$HOME/.qoder/skills"
    "$HOME/.junie/skills"
    "$HOME/.lingma/skills"
)

ADDED=0
SKIPPED=0

for agent_dir in "${AGENTS[@]}"; do
    [ -d "$agent_dir" ] || continue
    
    for skill in "$agent_dir"/*/; do
        [ -d "$skill" ] || continue
        [ -L "$skill" ] && continue
        
        name=$(basename "$skill")
        [ "$name" = "skill-once" ] && continue
        
        if [ -d "$SKILL_DIR/$name" ]; then
            ((SKIPPED++))
            continue
        fi
        
        echo "  📦 从 $(basename "$agent_dir") 添加: $name"
        cp -r "$skill" "$SKILL_DIR/$name"
        ((ADDED++))
    done
done

echo ""
echo "添加完成:"
echo "  📦 已添加: $ADDED 个"
echo "  ⏭️  已跳过: $SKIPPED 个"
