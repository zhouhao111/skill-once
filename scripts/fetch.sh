#!/bin/bash
# 从远程仓库获取更新

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

# 检查是否是 git 仓库
if [ ! -d "$SKILL_DIR/.git" ]; then
    echo "❌ skill 仓库不是 git 仓库"
    echo "   请先运行: cd $SKILL_DIR && git init"
    exit 1
fi

cd "$SKILL_DIR"

# 获取所有远程仓库的更新
echo "📥 从远程仓库获取更新..."
echo ""

git fetch --all

echo ""
echo "✅ 已获取所有远程仓库的更新"
