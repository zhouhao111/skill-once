#!/bin/bash
# 根据检测结果自动生成 adapter 配置

SKILL_ONCE="$HOME/.agents/skill-once"
ADAPTERS="$SKILL_ONCE/adapters"

echo "🔧 自动生成 adapter 配置..."
echo ""

# 生成单个 agent 的配置
gen_adapter() {
    local name="$1"
    local path="$2"
    local builtin_path="$3"
    local file="$ADAPTERS/$4"
    
    if [ ! -d "$path" ]; then
        return
    fi
    
    echo "# $name adapter - 自动生成" > "$file"
    echo "name: $name" >> "$file"
    echo "path: $path" >> "$file"
    echo "supports_symlink: true" >> "$file"
    
    if [ -n "$builtin_path" ] && [ -d "$builtin_path" ]; then
        echo "builtin_paths:" >> "$file"
        echo "  - $builtin_path" >> "$file"
    fi
    
    echo "notes: |" >> "$file"
    echo "  自动检测于 $(date '+%Y-%m-%d')" >> "$file"
    
    echo "  ✅ $name → $file"
}

# 生成各 Agent 配置
gen_adapter "claude-code" "$HOME/.claude/skills" "" "claude-code.yaml"
gen_adapter "cursor" "$HOME/.cursor/skills" "$HOME/.cursor/skills-cursor" "cursor.yaml"
gen_adapter "trae" "$HOME/.trae/skills" "" "trae.yaml"
gen_adapter "trae-cn" "$HOME/.trae-cn/skills" "$HOME/.trae-cn/builtin" "trae-cn.yaml"
gen_adapter "hermes" "$HOME/.hermes/skills" "$HOME/.hermes/hermes-agent/skills" "hermes.yaml"
gen_adapter "qoder" "$HOME/.qoder/skills" "" "qoder.yaml"
gen_adapter "junie" "$HOME/.junie/skills" "" "junie.yaml"
gen_adapter "lingma" "$HOME/.lingma/skills" "" "lingma.yaml"

echo ""
echo "✅ 配置生成完成"
