#!/bin/bash
# 初始化 SkillOnce

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"
DEFAULT_SKILL_DIR="$HOME/.agents/.mySkillRepository"
LOCAL_BIN="$HOME/.local/bin"
CLI_LINK="$LOCAL_BIN/skill-once"

# 检查是否已配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
    echo "✅ SkillOnce 已初始化"
    echo "  Skill 仓库: $SKILL_DIR"
    
    # 检查 CLI 链接是否存在
    if [ ! -L "$CLI_LINK" ]; then
        echo ""
        echo "🔧 配置 CLI 命令..."
        mkdir -p "$LOCAL_BIN"
        ln -sf "$SKILL_ONCE/bin/skill-once" "$CLI_LINK"
        echo "  ✅ 已创建符号链接: $CLI_LINK"
        
        # 检查是否在 PATH 中
        if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
            echo ""
            echo "📌 需要添加到 PATH，在 shell 配置文件中添加:"
            echo "   export PATH=\"$LOCAL_BIN:\$PATH\""
        fi
    fi
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

# 配置 CLI 命令
echo ""
echo "🔧 配置 CLI 命令..."
mkdir -p "$LOCAL_BIN"
ln -sf "$SKILL_ONCE/bin/skill-once" "$CLI_LINK"
echo "  ✅ 已创建符号链接: $CLI_LINK"

# 添加到 shell 配置文件
SHELL_CONFIG=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_CONFIG="$HOME/.bash_profile"
fi

if [ -n "$SHELL_CONFIG" ]; then
    if ! grep -q "$LOCAL_BIN" "$SHELL_CONFIG" 2>/dev/null; then
        echo "" >> "$SHELL_CONFIG"
        echo "# SkillOnce CLI" >> "$SHELL_CONFIG"
        echo "export PATH=\"$LOCAL_BIN:\$PATH\"" >> "$SHELL_CONFIG"
        echo "  ✅ 已添加到 $SHELL_CONFIG"
    else
        echo "  ℹ️  已存在于 $SHELL_CONFIG"
    fi
else
    echo "  ⚠️  未找到 shell 配置文件，请手动添加:"
    echo "     export PATH=\"$LOCAL_BIN:\$PATH\""
fi

echo ""
echo "✅ SkillOnce 初始化完成"
echo "  管理工具: $SKILL_ONCE"
echo "  Skill 仓库: $SKILL_DIR"
echo "  CLI 命令: $CLI_LINK"
echo ""
echo "📌 请重新打开终端或执行以下命令使配置生效:"
echo "   source $SHELL_CONFIG"
echo ""
echo "📌 然后可以直接使用 skill-once 命令:"
echo "   skill-once sync    # 同步 skill"
echo "   skill-once list    # 列出 skill"
echo "   skill-once status  # 查看状态"
echo "   skill-once help    # 查看帮助"
