#!/bin/bash
# 检测各 Agent 的 skill 规则

SKILL_ONCE="$HOME/.agents/skill-once"
ADAPTERS="$SKILL_ONCE/adapters"

echo "🔍 检测 Agent skill 规则..."
echo ""

# 检测已安装的 Agent
detect_agent() {
    local name="$1"
    local path="$2"
    local builtin_hint="$3"
    
    if [ -d "$path" ]; then
        echo "📦 $name"
        echo "   用户 skill 目录: $path"
        
        # 检测内置 skill 目录
        if [ -d "$builtin_hint" ]; then
            echo "   内置 skill 目录: $builtin_hint"
            builtin_count=$(ls "$builtin_hint" 2>/dev/null | wc -l | tr -d ' ')
            echo "   内置 skill 数量: $builtin_count"
        else
            echo "   内置 skill 目录: 未检测到"
        fi
        
        # 检测当前 skill 数量
        skill_count=$(ls -d "$path"/*/ 2>/dev/null | grep -v "\.bak" | wc -l | tr -d ' ')
        symlink_count=$(ls -l "$path" 2>/dev/null | grep "^l" | wc -l | tr -d ' ')
        echo "   用户 skill: $symlink_count 个 symlink"
        echo ""
        return 0
    fi
    return 1
}

# 检测各 Agent
detect_agent "Claude Code" "$HOME/.claude/skills" "$HOME/.claude/builtin"
detect_agent "Cursor" "$HOME/.cursor/skills" "$HOME/.cursor/skills-cursor"
detect_agent "Trae" "$HOME/.trae/skills" "$HOME/.trae/builtin"
detect_agent "Trae CN" "$HOME/.trae-cn/skills" "$HOME/.trae-cn/builtin"
detect_agent "Hermes" "$HOME/.hermes/skills" "$HOME/.hermes/hermes-agent/skills"
detect_agent "Qoder" "$HOME/.qoder/skills" "$HOME/.qoder/builtin"
detect_agent "Junie" "$HOME/.junie/skills" "$HOME/.junie/builtin"
detect_agent "Lingma" "$HOME/.lingma/skills" "$HOME/.lingma/builtin"

echo "检测完成"
