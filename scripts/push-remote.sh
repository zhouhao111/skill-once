#!/bin/bash
# 推送到远程仓库

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

remote="$1"

if [ -z "$remote" ]; then
    echo "用法: bash push-remote.sh <remote>"
    echo "  remote: origin, github, gitee"
    exit 1
fi

# 检查是否是 git 仓库
if [ ! -d "$SKILL_DIR/.git" ]; then
    echo "❌ skill 仓库不是 git 仓库"
    echo "   请先运行: cd $SKILL_DIR && git init"
    exit 1
fi

cd "$SKILL_DIR"

# 检查远程仓库是否存在
if ! git remote | grep -q "^$remote$"; then
    echo "❌ 远程仓库 '$remote' 不存在"
    echo "   请先运行: skill-once remote add $remote <URL>"
    exit 1
fi

echo "📤 推送到远程仓库: $remote"
echo ""

# 添加所有变更
git add .

# 检查是否有变更
if git diff --cached --quiet; then
    echo "ℹ️  没有变更需要提交"
    exit 0
fi

# 提交变更
git commit -m "feat: 更新 skill 仓库"

# 推送到远程
git push "$remote" main

echo ""
echo "✅ 已推送到 $remote"
