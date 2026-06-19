#!/bin/bash
# 添加远程仓库

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
url="$2"

if [ -z "$name" ] || [ -z "$url" ]; then
    echo "用法: bash remote-add.sh <name> <url>"
    exit 1
fi

# 检查是否是 git 仓库
if [ ! -d "$SKILL_DIR/.git" ]; then
    echo "❌ skill 仓库不是 git 仓库"
    echo "   请先运行: cd $SKILL_DIR && git init"
    exit 1
fi

cd "$SKILL_DIR"

# 检查远程仓库是否已存在
if git remote | grep -q "^$name$"; then
    echo "⚠️  远程仓库 '$name' 已存在"
    echo "   要修改请先运行: skill-once remote remove $name"
    exit 1
fi

# 添加远程仓库
git remote add "$name" "$url"

echo "✅ 已添加远程仓库: $name"
echo "   URL: $url"
