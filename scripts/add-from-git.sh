#!/bin/bash
# 从 GitHub 安装 skill

set -e

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

URL="$1"
SKILL_NAME="$2"

if [ -z "$URL" ]; then
    echo "❌ 用法: add-from-git.sh <GitHub URL> [skill-name]"
    exit 1
fi

# 创建临时目录
TMP_DIR=$(mktemp -d)
trap "rm -rf $TMP_DIR" EXIT

echo "📥 克隆仓库: $URL"
git clone --depth 1 "$URL" "$TMP_DIR/repo" 2>/dev/null

# 如果指定了 skill 名称，从仓库中提取
if [ -n "$SKILL_NAME" ]; then
    # 查找 skill 目录
    SKILL_PATH=""
    
    # 尝试多种路径模式
    for path in "$SKILL_NAME" "skills/$SKILL_NAME" "$SKILL_NAME/"; do
        if [ -d "$TMP_DIR/repo/$path" ]; then
            SKILL_PATH="$TMP_DIR/repo/$path"
            break
        fi
    done
    
    # 检查是否有 SKILL.md
    if [ -z "$SKILL_PATH" ]; then
        # 在仓库根目录查找包含 SKILL.md 的目录
        for dir in "$TMP_DIR/repo"/*/; do
            if [ -f "$dir/SKILL.md" ]; then
                dir_name=$(basename "$dir")
                if [ "$dir_name" = "$SKILL_NAME" ]; then
                    SKILL_PATH="$dir"
                    break
                fi
            fi
        done
    fi
    
    if [ -z "$SKILL_PATH" ] || [ ! -d "$SKILL_PATH" ]; then
        echo "❌ 未找到 skill: $SKILL_NAME"
        echo ""
        echo "仓库中可用的 skills:"
        for dir in "$TMP_DIR/repo"/*/; do
            [ -d "$dir" ] || continue
            if [ -f "$dir/SKILL.md" ]; then
                echo "  - $(basename "$dir")"
            fi
        done
        exit 1
    fi
    
    DEST_NAME="$SKILL_NAME"
    SOURCE_PATH="$SKILL_PATH"
else
    # 没有指定 skill，尝试从仓库根目录安装
    if [ -f "$TMP_DIR/repo/SKILL.md" ]; then
        # 仓库本身就是一个 skill
        DEST_NAME=$(basename "$URL" .git)
        SOURCE_PATH="$TMP_DIR/repo"
    else
        # 查找所有 skills
        SKILLS=()
        for dir in "$TMP_DIR/repo"/*/; do
            [ -d "$dir" ] || continue
            if [ -f "$dir/SKILL.md" ]; then
                SKILLS+=("$(basename "$dir")")
            fi
        done
        
        if [ ${#SKILLS[@]} -eq 0 ]; then
            echo "❌ 仓库中未找到任何 skill"
            echo "请使用 --skill 参数指定 skill 名称"
            exit 1
        fi
        
        if [ ${#SKILLS[@]} -eq 1 ]; then
            DEST_NAME="${SKILLS[0]}"
            SOURCE_PATH="$TMP_DIR/repo/$DEST_NAME"
        else
            echo "📦 仓库包含多个 skills，请选择一个:"
            echo ""
            for i in "${!SKILLS[@]}"; do
                echo "  $((i+1)). ${SKILLS[$i]}"
            done
            echo ""
            read -p "请选择 [1-${#SKILLS[@]}]: " choice
            
            if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#SKILLS[@]} ]; then
                DEST_NAME="${SKILLS[$((choice-1))]}"
                SOURCE_PATH="$TMP_DIR/repo/$DEST_NAME"
            else
                echo "❌ 无效的选择"
                exit 1
            fi
        fi
    fi
fi

echo "📦 安装 skill: $DEST_NAME"

# 检查是否已存在
if [ -d "$SKILL_DIR/$DEST_NAME" ]; then
    echo "⚠️  skill 已存在: $DEST_NAME"
    read -p "是否覆盖? [y/N]: " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "已取消"
        exit 0
    fi
    rm -rf "$SKILL_DIR/$DEST_NAME"
fi

# 复制到仓库
mkdir -p "$SKILL_DIR"
cp -r "$SOURCE_PATH" "$SKILL_DIR/$DEST_NAME"

echo "✅ skill 已添加: $SKILL_DIR/$DEST_NAME"

# 同步到所有 Agent
echo ""
echo "🔄 同步到所有 Agent..."
bash "$SKILL_ONCE/scripts/sync.sh"
