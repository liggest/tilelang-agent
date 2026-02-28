#!/bin/bash
# ======================================================
# 首次备份脚本：将当前家目录备份到持久化目录
# 配置说明（请根据实际情况修改）：
#   SOURCE_HOME   - 当前容器内的家目录路径
#   TARGET_HOME   - 持久化目标目录路径（挂载的 /work 下）
#   EXCLUDE_LIST  - 不需要备份的文件/目录名（顶层名称）
# 执行时机：第一次运行容器后，手动执行一次
# ======================================================

set -e

# ---------- 用户配置区域 ----------
SOURCE_HOME="/home/developer"
TARGET_HOME="/mnt/workspace/home"
# 排除列表：这些名称的顶层文件/目录将不被复制到 TARGET_HOME
EXCLUDE_LIST=(
    "Ascend"
    "ascend"
    "opensource"
)
# ---------- 配置结束 ----------

# 检查源家目录是否存在
if [ ! -d "$SOURCE_HOME" ]; then
    echo "错误：源家目录 $SOURCE_HOME 不存在！"
    exit 1
fi

# 如果目标目录已存在且不为空，询问是否继续
if [ -d "$TARGET_HOME" ] && [ "$(ls -A "$TARGET_HOME")" ]; then
    echo "警告：目标目录 $TARGET_HOME 已存在且不为空。"
    read -p "是否继续？这可能会覆盖现有文件 (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

# 创建目标目录（如果不存在）
mkdir -p "$TARGET_HOME"

echo "开始备份 $SOURCE_HOME 到 $TARGET_HOME ..."

# 进入源家目录
cd "$SOURCE_HOME"

# 处理所有顶层条目（包括隐藏文件）
for item in .* *; do
    # 跳过 . 和 ..
    [ "$item" = "." ] || [ "$item" = ".." ] && continue

    # 检查是否在排除列表中
    excluded=0
    for excl in "${EXCLUDE_LIST[@]}"; do
        if [ "$item" = "$excl" ]; then
            excluded=1
            break
        fi
    done

    if [ $excluded -eq 1 ]; then
        echo "跳过排除项: $item"
    else
        # 非排除项：复制到目标目录
        echo "复制: $item"
        cp -a "$item" "$TARGET_HOME/"
    fi
done

echo "备份完成。"

