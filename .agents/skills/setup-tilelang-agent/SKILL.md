---
name: setup-tilelang-agent
description: Install tilelang-agent into a tilelang-ascend project by creating symbolic links to .agents and AGENTS.md. Use this skill when the user wants to install/mount/setup tilelang-agent or "this repository" (这个仓库), or mentions setting up agents, linking .agents/AGENTS.md, or configuring a tilelang-ascend project with custom AI capabilities.
---

# Setup TileLang Agent

This skill installs the tilelang-agent's custom prompts and skills into a tilelang-ascend project by creating symbolic links from the tilelang-agent/tilelang-agent subdirectory (not the root directory) and updating .gitignore.

## When to Use

Use this skill when the user wants to:
- Install (安装) or mount (挂载) this repository (tilelang-agent)
- Install tilelang-agent into a tilelang-ascend project
- Set up custom AI agent skills and prompts
- Configure the development environment for tilelang-ascend
- Create symbolic links for .agents directory and AGENTS.md
- Prevent custom agent files from being committed to git

## Installation Process

### 1. Determine Installation Directory

The installation directory is determined in this order:
1. User-provided directory (if specified)
2. `TL_ROOT` environment variable
3. Ask the user if neither is available

Check if the directory exists and is writable. If not, ask the user for the correct path.

### 2. Confirm with User

Before proceeding, display the installation information to the user:
- TileLang-Agent root directory
- Installation target directory
- Symbolic links to be created
- .gitignore updates

Ask for explicit confirmation before proceeding.

### 3. Run Installation Script

Execute the `install.py` script located in this skill directory:

```bash
python3 install.py
```

The script will:
- Create symbolic links for `.agents` and `AGENTS.md` from `tilelang-agent/tilelang-agent/` subdirectory
- Update `.gitignore` to ignore these links
- Verify the installation
- Report success or errors

### 4. Handle Existing Installations

The installation is idempotent:
- If symbolic links already exist and point correctly, skip them
- If symbolic links exist but point elsewhere, remove and recreate
- If .gitignore entries already exist, don't duplicate them

### 5. Verify Installation

After installation, verify that:
- Symbolic links are created correctly
- Links point to the correct source paths
- `.gitignore` contains the necessary entries

## Expected Output

The installation script will output:
- Installation summary with paths
- Confirmation prompt
- Progress messages for each step
- Verification results
- Success or error message

## Error Handling

Handle these scenarios:
- Missing or invalid installation directory → prompt user
- Permission denied → report error and suggest solution
- Existing symbolic links → inform user and handle appropriately
- Invalid paths → report error and ask for correct path

## User Confirmation

Always show the installation details before proceeding:
```
Installation Summary:
====================
TileLang-Agent Root: /path/to/tilelang-agent
Installation Target: /path/to/tilelang-ascend
====================

Symbolic links to be created:
  /path/to/tilelang-ascend/.agents -> /path/to/tilelang-agent/tilelang-agent/.agents
  /path/to/tilelang-ascend/AGENTS.md -> /path/to/tilelang-agent/tilelang-agent/AGENTS.md

.gitignore will be updated to ignore these links.
====================

Proceed with installation? [y/N]:
```

## Success Criteria

Installation is successful when:
- Both symbolic links are created
- Links point to correct source paths
- .gitignore contains `.agents` and `AGENTS.md` entries
- Verification passes all checks
