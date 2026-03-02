#!/usr/bin/env python3
"""
Installation script for setup-tilelang-agent skill.

This script creates symbolic links from a tilelang-ascend project to the
tilelang-agent's .agents directory and AGENTS.md file, and updates
.gitignore to prevent these links from being committed.
"""

import os
import sys
from pathlib import Path


def get_tilelang_agent_root():
    """Get the tilelang-agent root directory."""
    current = Path(__file__).resolve()
    while current != current.parent:
        if (current / "tilelang-agent" / ".agents").exists():
            return current
        current = current.parent
    return None


def get_install_directory(user_path=None):
    """Get the installation directory from user input, environment, or command line."""
    if user_path:
        return Path(user_path).resolve()
    tl_root = os.environ.get("TL_ROOT")
    if tl_root and Path(tl_root).exists():
        return Path(tl_root).resolve()
    return None


def confirm_installation(install_dir, agent_root):
    """Ask user to confirm the installation directory."""
    print(f"\n{'='*60}")
    print(f"Installation Summary:")
    print(f"{'='*60}")
    print(f"TileLang-Agent Root: {agent_root}")
    print(f"Installation Target: {install_dir}")
    print(f"{'='*60}")
    print(f"\nSymbolic links to be created:")
    print(f"  {install_dir}/.agents -> {agent_root}/.agents")
    print(f"  {install_dir}/AGENTS.md -> {agent_root}/AGENTS.md")
    print(f"\n.gitignore will be updated to ignore these links.")
    print(f"{'='*60}\n")
    
    response = input("Proceed with installation? [y/N]: ").strip().lower()
    return response in ['y', 'yes']


def create_symlink(source, target):
    """Create a symbolic link, removing existing one if necessary."""
    target = Path(target)
    source = Path(source)
    
    if not source.exists():
        print(f"Error: Source does not exist: {source}")
        return False
    
    if target.exists() or target.is_symlink():
        if target.is_symlink():
            existing_target = os.readlink(target)
            if existing_target == str(source):
                print(f"Symbolic link already exists: {target}")
                return True
            print(f"Removing existing symbolic link: {target}")
        else:
            print(f"Removing existing file/directory: {target}")
        try:
            if target.is_dir() and not target.is_symlink():
                import shutil
                shutil.rmtree(target)
            else:
                target.unlink()
        except Exception as e:
            print(f"Error removing {target}: {e}")
            return False
    
    try:
        target.symlink_to(source)
        print(f"Created symbolic link: {target} -> {source}")
        return True
    except Exception as e:
        print(f"Error creating symbolic link {target}: {e}")
        return False


def update_gitignore(install_dir):
    """Update .gitignore to ignore symbolic links."""
    gitignore_path = install_dir / ".gitignore"
    entries = [".agents", "AGENTS.md"]
    
    existing_entries = set()
    if gitignore_path.exists():
        with open(gitignore_path, 'r') as f:
            existing_entries = set(line.strip() for line in f if line.strip())
    
    new_entries = [e for e in entries if e not in existing_entries]
    
    if not new_entries:
        print(f".gitignore already contains all necessary entries.")
        return True
    
    try:
        with open(gitignore_path, 'a') as f:
            if gitignore_path.exists() and gitignore_path.stat().st_size > 0:
                f.write('\n')
            for entry in new_entries:
                f.write(f"{entry}\n")
        print(f"Updated .gitignore with entries: {', '.join(new_entries)}")
        return True
    except Exception as e:
        print(f"Error updating .gitignore: {e}")
        return False


def verify_installation(install_dir, agent_root):
    """Verify that the installation was successful."""
    print(f"\n{'='*60}")
    print(f"Verification:")
    print(f"{'='*60}")
    
    agents_link = install_dir / ".agents"
    agents_md_link = install_dir / "AGENTS.md"
    
    success = True
    
    if agents_link.is_symlink():
        target = os.readlink(agents_link)
        expected = str(agent_root / "tilelang-agent" / ".agents")
        if target == expected:
            print(f"✓ .agents link is correct")
        else:
            print(f"✗ .agents link points to: {target}")
            success = False
    else:
        print(f"✗ .agents link not found")
        success = False
    
    if agents_md_link.is_symlink():
        target = os.readlink(agents_md_link)
        expected = str(agent_root / "tilelang-agent" / "AGENTS.md")
        if target == expected:
            print(f"✓ AGENTS.md link is correct")
        else:
            print(f"✗ AGENTS.md link points to: {target}")
            success = False
    else:
        print(f"✗ AGENTS.md link not found")
        success = False
    
    gitignore_path = install_dir / ".gitignore"
    if gitignore_path.exists():
        with open(gitignore_path, 'r') as f:
            content = f.read()
            if ".agents" in content and "AGENTS.md" in content:
                print(f"✓ .gitignore contains necessary entries")
            else:
                print(f"✗ .gitignore missing entries")
                success = False
    else:
        print(f"✗ .gitignore not found")
        success = False
    
    print(f"{'='*60}")
    return success


def main():
    """Main installation function."""
    agent_root = get_tilelang_agent_root()
    if not agent_root:
        print("Error: Could not find tilelang-agent root directory.")
        sys.exit(1)
    
    user_path = sys.argv[1] if len(sys.argv) > 1 else None
    install_dir = get_install_directory(user_path)
    if not install_dir:
        print("Could not determine installation directory.")
        print("Please set the TL_ROOT environment variable or provide the path.")
        sys.exit(1)
    
    if not install_dir.exists():
        print(f"Error: Installation directory does not exist: {install_dir}")
        sys.exit(1)
    
    if not confirm_installation(install_dir, agent_root):
        print("Installation cancelled.")
        sys.exit(0)
    
    print(f"\nInstalling tilelang-agent to: {install_dir}")
    
    success = True
    
    if not create_symlink(agent_root / "tilelang-agent" / ".agents", install_dir / ".agents"):
        success = False
    
    if not create_symlink(agent_root / "tilelang-agent" / "AGENTS.md", install_dir / "AGENTS.md"):
        success = False
    
    if not update_gitignore(install_dir):
        success = False
    
    if success:
        if verify_installation(install_dir, agent_root):
            print(f"\n✓ Installation completed successfully!")
        else:
            print(f"\n✗ Installation completed with errors.")
            sys.exit(1)
    else:
        print(f"\n✗ Installation failed.")
        sys.exit(1)


if __name__ == "__main__":
    main()
