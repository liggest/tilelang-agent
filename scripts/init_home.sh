#!/bin/bash
# ======================================================
# 容器启动初始化脚本（简化版，无进程检查）
# 功能：确保指定路径在 SOURCE_HOME 中是符号链接指向 TARGET_HOME。
#       如果原路径存在且不是链接，尝试将其移动到 BACKUP_HOME 再创建链接。
#       若移动失败（如进程占用），则报错退出。
# 配置必须与 backup_home.sh 保持一致。
# 注意：请确保在运行此脚本前，没有进程占用相关路径（如 vscode-server）。
# ======================================================

set -e  # 遇到错误立即退出

# ---------- 用户配置区域（必须与 backup_home.sh 一致） ----------
SOURCE_HOME="/home/developer"
TARGET_HOME="/mnt/workspace/home"
# 需要持久化的路径（可以是文件或目录，相对于 SOURCE_HOME）
MAPPED_PATHS=(
"agent"
".bashrc"
".bash_aliases"
".bash_history"
".bun"
".cache"
"CANNBot"
"codearts"
".codearts-server/extensions"
".config"
".gitconfig"
".local"
"log"
".opencode"
".pip"
".profile"
".ssh"
"var"
".vscode-server"    
# 添加其他你想要持久化的路径
)
# ---------- 配置结束 ----------

BACKUP_HOME="${SOURCE_HOME}.bak"

# 检查目标持久化目录是否存在
if [ ! -d "$TARGET_HOME" ]; then
    echo "错误：持久化目录 $TARGET_HOME 不存在！" >&2
    echo "请先运行 backup_home.sh 进行首次备份。" >&2
    exit 1
fi

# 确保当前工作目录不在 SOURCE_HOME 下
cd /

# 遍历每个映射路径
for relpath in "${MAPPED_PATHS[@]}"; do
    src="$SOURCE_HOME/$relpath"
    dst="$TARGET_HOME/$relpath"

    # 检查目标是否存在（必须存在）
    if [ ! -e "$dst" ]; then
        echo "错误：目标 $dst 不存在，请先运行 backup_home.sh。如果home本来就没有，可以手动创建该文件或目录" >&2
        exit 1
    fi

    # 如果源路径已经是正确的符号链接，跳过
    if [ -L "$src" ] && [ "$(readlink "$src")" = "$dst" ]; then
        echo "✓ $relpath 已正确映射"
        continue
    fi

    # 如果源路径存在且不是链接，则需要移动
    if [ -e "$src" ] && [ ! -L "$src" ]; then
        echo "处理 $relpath ..."

        # 在备份目录中创建对应的父目录
        backup_path="$BACKUP_HOME/$relpath"
        mkdir -p "$(dirname "$backup_path")"

        # 尝试移动原文件/目录到备份目录
        echo "移动 $src -> $backup_path"
        if ! mv "$src" "$backup_path"; then
            echo "错误：无法移动 $src 到 $backup_path" >&2
            echo "可能原因：有进程正在使用该文件/目录（例如 vscode-server）。" >&2
            echo "请手动终止占用进程后重新运行此脚本。" >&2
            exit 1
        fi
    elif [ -L "$src" ]; then
        # 如果是错误的链接，直接删除
        echo "删除错误的符号链接 $src"
        rm "$src"
    fi

    # 创建新的符号链接（确保父目录存在）
    mkdir -p "$(dirname "$src")"
    echo "创建链接: $src -> $dst"
    ln -s "$dst" "$src"

    # 修复链接本身的权限
    sudo chown -h developer:developer "$src"
done

echo "家目录映射初始化完成。"

