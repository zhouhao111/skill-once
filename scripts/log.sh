#!/bin/bash
# 查看提交历史

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

# 查看提交历史
echo "📜 提交历史:"
echo ""

git log --oneline -20
