#!/bin/bash

set -euo pipefail

# ========================
#       常量定义
# ========================
MIRROR_URL="https://ghfast.top/https://github.com/"
DEFAULT_REPO="git@github.com:jackwangc/ai-tile.git"
PROJECT_DIR="ai-tile"

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

log_warning() {
    echo "⚠️  $*" >&2
}

# ========================
#   系统检查函数
# ========================

check_system() {
    log_info "Checking system compatibility..."
    
    local platform=$(uname -s)
    
    if [ "$platform" != "Linux" ]; then
        log_error "Unsupported platform: $platform. This script only supports Linux."
        exit 1
    fi
    
    log_success "Platform check passed: Linux"
}

# ========================
#   SSH 密钥检查函数
# ========================

check_ssh_key() {
    log_info "Checking SSH key configuration..."
    
    if [ -f ~/.ssh/id_ed25519.pub ] || [ -f ~/.ssh/id_rsa.pub ]; then
        log_success "SSH key found"
        
        if [ -f ~/.ssh/id_ed25519.pub ]; then
            log_info "Public key (ed25519):"
            cat ~/.ssh/id_ed25519.pub
        elif [ -f ~/.ssh/id_rsa.pub ]; then
            log_info "Public key (rsa):"
            cat ~/.ssh/id_rsa.pub
        fi
        
        log_warning "Please ensure this SSH key is added to your GitHub account"
        log_info "GitHub SSH keys URL: https://github.com/settings/keys"
        
        read -p "Press Enter to continue after verifying SSH key is added to GitHub..."
    else
        log_warning "SSH key not found"
        read -p "Do you want to generate a new SSH key? (y/n): " generate_key
        
        if [ "$generate_key" = "y" ] || [ "$generate_key" = "Y" ]; then
            read -p "Enter your email for SSH key: " email
            
            if [ -z "$email" ]; then
                log_error "Email is required"
                exit 1
            fi
            
            log_info "Generating SSH key (ed25519)..."
            ssh-keygen -t ed25519 -C "$email" -f ~/.ssh/id_ed25519 -N ""
            
            log_success "SSH key generated"
            log_info "Public key:"
            cat ~/.ssh/id_ed25519.pub
            
            log_warning "Please add this SSH key to your GitHub account"
            log_info "GitHub SSH keys URL: https://github.com/settings/keys"
            
            read -p "Press Enter to continue after adding SSH key to GitHub..."
        else
            log_error "SSH key is required for cloning the repository"
            exit 1
        fi
    fi
    
    log_info "Testing SSH connection to GitHub..."
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        log_success "SSH connection to GitHub successful"
    else
        log_warning "SSH connection test failed, but continuing..."
    fi
}

# ========================
#   克隆仓库函数
# ========================

clone_repository() {
    local repo_url="${1:-$DEFAULT_REPO}"
    
    log_info "Cloning repository from: $repo_url"
    
    if [ -d "$PROJECT_DIR" ]; then
        log_warning "Directory $PROJECT_DIR already exists"
        read -p "Do you want to remove it and re-clone? (y/n): " reclone
        
        if [ "$reclone" = "y" ] || [ "$reclone" = "Y" ]; then
            log_info "Removing existing directory..."
            rm -rf "$PROJECT_DIR"
        else
            log_info "Using existing directory"
            cd "$PROJECT_DIR"
            return 0
        fi
    fi
    
    if git clone "$repo_url" "$PROJECT_DIR"; then
        log_success "Repository cloned successfully"
        cd "$PROJECT_DIR"
    else
        log_error "Failed to clone repository"
        exit 1
    fi
}

# ========================
#   配置镜像函数
# ========================

configure_mirror() {
    log_info "Configuring GitHub mirror for faster submodule download..."
    
    if git config --global url."$MIRROR_URL".insteadOf "https://github.com/"; then
        log_success "Mirror configured: $MIRROR_URL"
    else
        log_error "Failed to configure mirror"
        exit 1
    fi
}

# ========================
#   更新 Submodule 函数
# ========================

update_submodules() {
    log_info "Initializing and updating submodules..."
    
    log_info "Cleaning existing submodule cache..."
    git submodule deinit --all 2>/dev/null || true
    rm -rf .git/modules/3rdparty 2>/dev/null || true
    rm -rf 3rdparty/cutlass 3rdparty/tvm 3rdparty/composable_kernel 3rdparty/catlass 3rdparty/pto-isa 3rdparty/shmem 2>/dev/null || true
    
    log_info "Updating submodules recursively..."
    if git submodule update --init --recursive; then
        log_success "Submodules updated successfully"
    else
        log_error "Failed to update submodules"
        exit 1
    fi
    
    log_info "Submodule status:"
    git submodule status
}

# ========================
#   执行安装脚本函数
# ========================

execute_install_script() {
    local install_script="tilelang-ascend/install_ascend.sh"
    
    if [ ! -f "$install_script" ]; then
        log_error "Install script not found: $install_script"
        exit 1
    fi
    
    log_info "Executing install script: $install_script"
    
    if bash "$install_script"; then
        log_success "Install script executed successfully"
    else
        log_error "Install script execution failed"
        exit 1
    fi
}

# ========================
#   清理函数
# ========================

cleanup() {
    log_info "Cleaning up mirror configuration..."
    git config --global --unset url."$MIRROR_URL".insteadOf 2>/dev/null || true
    log_success "Mirror configuration removed"
}

# ========================
#        主流程
# ========================

main() {
    echo "🚀 TileLang One-Click Installation Script"
    echo ""
    
    local repo_url=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --repo)
                repo_url="$2"
                shift 2
                ;;
            --help|-h)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --repo URL              Repository URL (default: git@github.com:jackwangc/ai-tile.git)"
                echo "  --help, -h              Show this help message"
                echo ""
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    check_system
    check_ssh_key
    clone_repository "$repo_url"
    configure_mirror
    update_submodules
    execute_install_script
    
    echo ""
    log_success "🎉 Installation completed successfully!"
    echo ""
    log_info "Next steps:"
    echo "  1. Source the environment variables (if needed)"
    echo "  2. Start using TileLang"
    echo ""
}

trap cleanup EXIT

main "$@"
