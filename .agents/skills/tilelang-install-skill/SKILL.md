---
name: tilelang-install
description: Complete TileLang installation on Linux systems. Use this skill whenever the user wants to install TileLang, mentions setting up TileLang, or needs help with the TileLang installation process including SSH key setup, repository cloning, submodule management, or running the install_ascend.sh script. This skill handles the full installation workflow from initial system checks through final verification.
---

# TileLang Installation Skill

This skill guides you through the complete TileLang installation process on Linux systems.

## Overview

TileLang installation requires multiple steps:
1. System compatibility check (Linux only)
2. SSH key configuration for GitHub access
3. Repository cloning
4. Submodule mirror configuration for faster downloads
5. Submodule initialization and update
6. Installation script execution
7. Verification

## Prerequisites

Before starting, verify the user has:
- Linux operating system (not macOS or Windows)
- Git installed
- Python 3.10 or higher
- Bash shell
- GitHub account with repository access

## Installation Steps

### Step 1: Check System Compatibility

Verify the operating system is Linux. TileLang installation only supports Linux.

```bash
uname -s
```

If the output is not "Linux", inform the user that this installation is only supported on Linux systems.

### Step 2: SSH Key Configuration

Check for existing SSH keys and help configure if needed.

**Check for existing keys:**
```bash
ls -la ~/.ssh/id_ed25519.pub
ls -la ~/.ssh/id_rsa.pub
```

**If SSH key doesn't exist, offer to generate one:**
```bash
ssh-keygen -t ed25519 -C "user_email@example.com"
```

**Display the public key and instruct user to add to GitHub:**
```bash
cat ~/.ssh/id_ed25519.pub
```

Instruct the user to:
1. Go to https://github.com/settings/keys
2. Click "New SSH key"
3. Paste the public key
4. Save

**Test SSH connection:**
```bash
ssh -T git@github.com
```

### Step 3: Clone Repository

Clone the TileLang repository. Default repository is `git@github.com:tile-ai/tilelang-ascend.git`.

Before cloning, ask the user if they want to use a fork repository instead:
- Ask: "Do you want to use a fork repository instead of the default?"
- If yes, prompt for the fork repository URL
- If no, use the default repository

Check if the target directory (`tilelang-ascend`) already exists. If it does, ask the user if they want to remove it and re-clone.

```bash
git clone git@github.com:tile-ai/tilelang-ascend.git
cd tilelang-ascend
```

### Step 4: Configure GitHub Mirror

Configure a GitHub mirror to accelerate submodule downloads.

```bash
git config --global url."https://ghfast.top/https://github.com/".insteadOf "https://github.com/"
```

### Step 5: Update Submodules

Clean existing submodule cache and initialize/update all submodules.

```bash
# Clean submodule cache
git submodule deinit --all 2>/dev/null || true
rm -rf .git/modules/3rdparty 2>/dev/null || true
rm -rf 3rdparty/cutlass 3rdparty/tvm 3rdparty/composable_kernel 3rdparty/catlass 3rdparty/pto-isa 3rdparty/shmem 2>/dev/null || true

# Initialize and update submodules
git submodule update --init --recursive

# Verify submodule status
git submodule status
```

### Step 6: Execute Installation Script

Run the TileLang installation script located at `tilelang-ascend/install_ascend.sh`.

```bash
bash tilelang-ascend/install_ascend.sh
```

Monitor the installation progress. The script will:
- Check Python version (requires 3.10+)
- Install Python requirements
- Clone and build TVM
- Configure CMake
- Build TileLang

### Step 7: Cleanup

Remove the mirror configuration to restore normal GitHub access.

```bash
git config --global --unset url."https://ghfast.top/https://github.com/".insteadOf 2>/dev/null || true
```

### Step 8: Verify Installation

Help the user verify the installation was successful.

```bash
# Check submodule status
git submodule status

# Check Python package
python3 -c "import tilelang; print(tilelang.__version__)"

# Check build artifacts
ls -la build/
```

## Troubleshooting

### SSH Key Issues

If SSH key is missing or connection fails:
- Ensure SSH key is generated
- Verify public key is added to GitHub account
- Check SSH key permissions: `chmod 600 ~/.ssh/id_ed25519`

### Submodule Download Failures

If submodule update fails:
- The mirror configuration should help, but if issues persist:
  - Suggest checking network connection
  - Consider manual proxy configuration
  - Verify repository accessibility

### Permission Issues

If script execution fails due to permissions:
```bash
chmod +x tilelang-ascend/install_tilelang.sh
./tilelang-ascend/install_tilelang.sh
```

## Alternative: One-Click Script

If the user prefers a fully automated approach, inform them about the one-click installation script:

```bash
bash tilelang-ascend/install_tilelang.sh
```

This script automates all the steps above. It accepts optional arguments:
- `--repo URL`: Specify custom repository URL
- `--help`: Display help information

## Uninstallation

If the user needs to uninstall TileLang:

```bash
# Remove project directory
rm -rf tilelang-ascend

# Clean submodule cache
rm -rf ~/.git/modules
```

## Communication Style

- Be clear and direct about each step
- Explain why each step is necessary
- Provide context about what the installation process is doing
- Offer progress updates during long-running operations
- If any step fails, provide specific error messages and actionable solutions
- Use emojis for visual clarity (🔹 for info, ✅ for success, ❌ for errors, ⚠️ for warnings)

## Final Confirmation

After installation completes, confirm with the user:
- All steps completed successfully
- TileLang is ready to use
- Next steps for getting started with TileLang
