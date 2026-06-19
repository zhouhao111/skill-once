#!/bin/bash
# 添加 skill 到 skill 仓库（从当前 Agent）

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
    echo "用法: skill-once add <name>"
    exit 1
fi

# 检查是否已存在
if [ -d "$SKILL_DIR/$name" ]; then
    echo "❌ skill '$name' 已存在于仓库"
    exit 1
fi

# 在所有 Agent 中查找 skill
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

FOUND=false
SOURCE=""
AGENT_NAME=""

for agent_dir in "${AGENTS[@]}"; do
    [ -d "$agent_dir" ] || continue
    
    if [ -d "$agent_dir/$name" ] && [ ! -L "$agent_dir/$name" ]; then
        FOUND=true
        SOURCE="$agent_dir/$name"
        AGENT_NAME=$(basename "$agent_dir")
        break
    fi
done

if [ "$FOUND" = false ]; then
    echo "❌ 未在任何 Agent 中找到 skill '$name'"
    echo ""
    echo "💡 请确保 skill 存在于以下目录之一："
    for agent_dir in "${AGENTS[@]}"; do
        [ -d "$agent_dir" ] && echo "  - $agent_dir"
    done
    exit 1
fi

echo "📦 添加 skill: $name"
echo "   来源: $AGENT_NAME"
echo ""

# 复制到仓库
cp -r "$SOURCE" "$SKILL_DIR/$name"
echo "  ✅ 已复制到 $SKILL_DIR/$name"

# 替换为符号链接
rm -rf "$SOURCE"
ln -s "$SKILL_DIR/$name" "$SOURCE"
echo "  ✅ 已替换为符号链接: $SOURCE -> $SKILL_DIR/$name"

echo ""
echo "✅ skill '$name' 已添加到仓库"
