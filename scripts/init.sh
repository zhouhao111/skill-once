#!/bin/bash
# 初始化 SkillOnce

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"
DEFAULT_SKILL_DIR="$HOME/.agents/.mySkillRepository"

# 检查是否已配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
    echo "✅ SkillOnce 已初始化"
    echo "  Skill 仓库: $SKILL_DIR"
    exit 0
fi

# 首次初始化，提示选择存储位置
echo "🔧 SkillOnce 首次初始化"
echo ""
echo "请选择 skill 仓库位置:"
echo "  1) $DEFAULT_SKILL_DIR (默认，本地仓库)"
echo "  2) ~/.my-skills"
echo "  3) 自定义路径"
echo ""
read -p "输入选项 [1]: " choice

case "$choice" in
    2)
        SKILL_DIR="$HOME/.my-skills"
        ;;
    3)
        read -p "输入自定义路径: " SKILL_DIR
        SKILL_DIR=$(eval echo "$SKILL_DIR")
        ;;
    *)
        SKILL_DIR="$DEFAULT_SKILL_DIR"
        ;;
esac

# 创建目录
mkdir -p "$SKILL_DIR"
mkdir -p "$SKILL_ONCE"/{adapters,scripts}

# 写入配置
echo "# SkillOnce 配置" > "$CONFIG"
echo "skill_dir: $SKILL_DIR" >> "$CONFIG"

# 初始化 git（skill 仓库）
if [ ! -d "$SKILL_DIR/.git" ]; then
    cd "$SKILL_DIR" && git init -q 2>/dev/null
    echo "  Skill 仓库已初始化"
fi

echo ""
echo "✅ SkillOnce 初始化完成"
echo "  管理工具: $SKILL_ONCE"
echo "  Skill 仓库: $SKILL_DIR"
echo ""
echo "📌 下一步: 运行 sync 开始同步 skill"
echo "   bash $SKILL_ONCE/scripts/sync.sh"
