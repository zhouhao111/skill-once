#!/bin/bash
# 同步 skill（支持交互式选择 Agent）

SKILL_ONCE="$HOME/.agents/skill-once"
CONFIG="$SKILL_ONCE/config.yaml"

# 读取配置
if [ -f "$CONFIG" ]; then
    SKILL_DIR=$(grep "^skill_dir:" "$CONFIG" | awk '{print $2}')
    SKILL_DIR=$(eval echo "$SKILL_DIR")
else
    SKILL_DIR="$HOME/.agents/.mySkillRepository"
fi

# 检查 Agent 是否安装了 SkillOnce
is_installed() {
    local agent_path="$1"
    [ -L "$agent_path/skill-once" ] || [ -d "$agent_path/skill-once" ]
}

# 获取所有已安装的 Agent
get_installed_agents() {
    local agents=()
    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

        if is_installed "$agent_path"; then
            agents+=("$agent_name")
        fi
    done
    echo "${agents[@]}"
}

# 交互式选择 Agent
select_agents() {
    echo "📋 Agent 安装状态扫描:"
    echo ""
    echo "  序号  状态      Agent 名称"
    echo "  ----  --------  ----------"
    
    local index=1
    local installed_list=()
    local not_installed_list=()
    local all_list=()
    
    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        agent_name=$(grep "^name:" "$conf" | awk '{print $2}')
        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

        all_list+=("$agent_name")
        
        if is_installed "$agent_path"; then
            echo "  $index     ✅ 已安装  $agent_name"
            installed_list+=("$agent_name")
        else
            echo "  $index     ❌ 未安装  $agent_name"
            not_installed_list+=("$agent_name")
        fi
        ((index++))
    done
    
    echo ""
    echo "  ─────────────────────────────────"
    echo "  已安装: ${#installed_list[@]} 个 (已接入 skill-once)"
    echo "  未安装: ${#not_installed_list[@]} 个 (未接入 skill-once)"
    echo "  ─────────────────────────────────"
    echo ""
    echo "  💡 已安装 = Agent skill 目录下存在 skill-once，可正常同步"
    echo "  💡 未安装 = Agent 未接入 skill-once，同步会失败"
    echo ""
    echo "  操作选项:"
    echo "    1. 同步到所有已安装的 Agent (${#installed_list[@]} 个)"
    echo "    2. 同步到所有 Agent (${#all_list[@]} 个，包括未安装的)"
    echo "    3. 手动选择要同步的 Agent"
    echo "    4. 取消"
    echo ""
    read -p "请选择操作 [1-4]: " choice

    case "$choice" in
        1)
            if [ ${#installed_list[@]} -eq 0 ]; then
                echo ""
                echo "❌ 没有已安装 SkillOnce 的 Agent"
                exit 1
            fi
            echo "${installed_list[@]}"
            ;;
        2)
            echo "${all_list[@]}"
            ;;
        3)
            echo ""
            echo "请输入要同步的 Agent 序号 (多个用空格分隔，如: 1 3 5): "
            read -p "> " nums
            
            local selected=()
            for num in $nums; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le $((index-1)) ]; then
                    selected+=("${all_list[$((num-1))]}")
                fi
            done
            
            if [ ${#selected[@]} -eq 0 ]; then
                echo ""
                echo "❌ 无效的选择"
                exit 1
            fi
            
            echo "${selected[@]}"
            ;;
        4|q|Q)
            echo ""
            echo "已取消"
            exit 0
            ;;
        *)
            echo ""
            echo "❌ 无效的选择，请输入 1-4"
            exit 1
            ;;
    esac
}

# 主逻辑
INTERACTIVE=false
SYNC_ALL=false

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--interactive)
            INTERACTIVE=true
            shift
            ;;
        -a|--all)
            SYNC_ALL=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# 确定要同步的 Agent
if [ "$INTERACTIVE" = true ]; then
    TARGET_AGENTS=($(select_agents))
elif [ "$SYNC_ALL" = true ]; then
    TARGET_AGENTS=($(get_installed_agents))
else
    # 默认：同步所有已安装的 Agent
    TARGET_AGENTS=($(get_installed_agents))
fi

echo "🔄 同步 skill..."
echo "   Skill 仓库: $SKILL_DIR"
echo "   目标 Agent: ${TARGET_AGENTS[*]}"
echo ""

SYNCED=0
SKIPPED=0
PULLED=0

# Step 1: 从已安装的 Agent 拉取 skill 到仓库
echo "📥 Step 1: 从 Agent 拉取 skill 到仓库"
for agent_name in "${TARGET_AGENTS[@]}"; do
    # 找到对应的配置
    for conf in "$SKILL_ONCE/adapters/"*.yaml; do
        [ -f "$conf" ] || continue
        [[ "$(basename "$conf")" == _* ]] && continue

        conf_name=$(grep "^name:" "$conf" | awk '{print $2}')
        [ "$conf_name" != "$agent_name" ] && continue

        agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
        agent_path=$(eval echo "$agent_path")

        [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

        # 获取 builtin_paths
        builtin_paths=$(grep -A 10 "builtin_paths:" "$conf" | grep "  -" | awk '{print $2}')

        # 检查 Agent 中的 skill
        for skill in "$agent_path"/*/; do
            [ -d "$skill" ] || continue
            [ -L "$skill" ] && continue

            name=$(basename "$skill")
            [ "$name" = "skill-once" ] && continue

            # 跳过内置 skill
            skip=false
            for bp in $builtin_paths; do
                bp=$(eval echo "$bp")
                if [ -d "$bp/$name" ]; then
                    skip=true
                    break
                fi
            done
            $skip && continue

            if [ ! -d "$SKILL_DIR/$name" ]; then
                echo "  📦 从 $agent_name 拉取: $name"
                cp -r "$skill" "$SKILL_DIR/$name"
                ((PULLED++))
            fi
        done
        break
    done
done
echo ""

# Step 2: 从仓库推送到已安装的 Agent
echo "📤 Step 2: 从仓库推送到 Agent"
for skill in "$SKILL_DIR"/*/; do
    [ -d "$skill" ] || continue
    name=$(basename "$skill")

    for agent_name in "${TARGET_AGENTS[@]}"; do
        # 找到对应的配置
        for conf in "$SKILL_ONCE/adapters/"*.yaml; do
            [ -f "$conf" ] || continue
            [[ "$(basename "$conf")" == _* ]] && continue

            conf_name=$(grep "^name:" "$conf" | awk '{print $2}')
            [ "$conf_name" != "$agent_name" ] && continue

            agent_path=$(grep "^path:" "$conf" | awk '{print $2}')
            agent_path=$(eval echo "$agent_path")

            [ -z "$agent_path" ] || [ ! -d "$agent_path" ] && continue

            if [ -L "$agent_path/$name" ]; then
                ((SKIPPED++))
                continue
            fi

            if [ -d "$agent_path/$name" ]; then
                ((SKIPPED++))
                continue
            fi

            mkdir -p "$agent_path"
            ln -s "$skill" "$agent_path/$name"
            echo "  ✅ $name → $agent_name"
            ((SYNCED++))
            break
        done
    done
done

echo ""
echo "同步完成:"
echo "  📥 从 Agent 拉取: $PULLED 个"
echo "  📤 推送到 Agent: $SYNCED 个"
echo "  ⏭️  跳过: $SKIPPED 个"
