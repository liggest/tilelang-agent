#!/bin/bash

set -euo pipefail

# ========================
#       常量定义
# ========================
NODE_MIN_VERSION=18
NODE_INSTALL_VERSION=22
NVM_VERSION="v0.40.3"

# 中国镜像配置
NVM_MIRROR="https://gitee.com/mirrors/nvm/raw"
NODEJS_MIRROR="https://npmmirror.com/mirrors/node"

# ========================
#       工具函数
# ========================

log_info() {
    echo "🔹 $*"
}

log_success() {
    echo "✅ $*"
}

log_error() {
    echo "❌ $*" >&2
}

# ========================
#     Node.js 安装函数
# ========================

install_nodejs() {
    local platform=$(uname -s)

    case "$platform" in
        Linux|Darwin)
            log_info "Installing Node.js on $platform..."

            # 安装 nvm（使用 Gitee 镜像）
            log_info "Installing nvm ($NVM_VERSION) from Gitee mirror..."
            curl -s "$NVM_MIRROR/$NVM_VERSION/install.sh" | bash

            # 加载 nvm
            log_info "Loading nvm environment..."
            \. "$HOME/.nvm/nvm.sh"

            # 设置 Node.js 镜像源
            log_info "Setting Node.js mirror to $NODEJS_MIRROR..."
            export NVM_NODEJS_ORG_MIRROR="$NODEJS_MIRROR"

            # 安装 Node.js
            log_info "Installing Node.js $NODE_INSTALL_VERSION..."
            nvm install "$NODE_INSTALL_VERSION"

            # 设置为默认版本
            log_info "Setting Node.js $NODE_INSTALL_VERSION as default..."
            nvm alias default "$NODE_INSTALL_VERSION"

            # 验证安装
            node -v &>/dev/null || {
                log_error "Node.js installation failed"
                exit 1
            }
            log_success "Node.js installed: $(node -v)"
            log_success "npm version: $(npm -v)"
            ;;
        *)
            log_error "Unsupported platform: $platform"
            exit 1
            ;;
    esac
}

# ========================
#     Node.js 检查函数
# ========================

check_nodejs() {
    if command -v node &>/dev/null; then
        current_version=$(node -v | sed 's/v//')
        major_version=$(echo "$current_version" | cut -d. -f1)

        if [ "$major_version" -ge "$NODE_MIN_VERSION" ]; then
            log_success "Node.js is already installed: v$current_version"
            return 0
        else
            log_info "Node.js v$current_version is installed but version < $NODE_MIN_VERSION. Upgrading..."
            install_nodejs
        fi
    else
        log_info "Node.js not found. Installing..."
        install_nodejs
    fi
}

# ========================
#        主流程
# ========================

main() {
    echo "🚀 Node.js Installation Script (China Mirror)"
    echo ""
    
    check_nodejs
    
    echo ""
    log_success "🎉 Installation completed successfully!"
    echo ""
    echo "📝 To use Node.js in your current shell, run:"
    echo "   export NVM_DIR=\"\$HOME/.nvm\""
    echo "   [ -s \"\$NVM_DIR/nvm.sh\" ] && \\. \"\$NVM_DIR/nvm.sh\""
    echo "   export NVM_NODEJS_ORG_MIRROR=\"$NODEJS_MIRROR\""
    echo ""
    echo "   Or restart your terminal"
}

main "$@"
