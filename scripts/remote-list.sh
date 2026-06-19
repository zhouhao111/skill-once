#!/bin/bash
# 列出远程仓库

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

# 获取远程仓库列表
remotes=$(git remote)

if [ -z "$remotes" ]; then
    echo "ℹ️  没有配置远程仓库"
    echo ""
    echo "💡 要添加远程仓库，请运行:"
    echo "   skill-once remote add origin <URL>"
    exit 0
fi

echo "🔗 远程仓库列表:"
echo ""

for remote in $remotes; do
    url=$(git remote get-url "$remote")
    echo "  $remote -> $url"
done
