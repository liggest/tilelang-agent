# opencode 云服务器安装指南

本文档介绍如何在云服务器上初始化并安装 opencode。

## 概述

opencode 安装过程包含以下三个步骤：

1. 执行 `install_node_js.sh` - 安装 Node.js 环境
2. 执行 `npm install -g opencode-ai` - 安装 opencode
3. 执行 `opencode_apikey_config.sh` - 配置 API Key

## 安装步骤

### 1. 安装 Node.js

`install_node_js.sh` 脚本会自动安装 Node.js 环境。

**功能说明：**
- 使用 nvm (Node Version Manager) 安装 Node.js
- 安装版本：Node.js 22
- 最低版本要求：Node.js 18
- 支持平台：Linux、macOS
- 自动检测已安装版本，如版本过低则升级

**执行命令：**
```bash
bash ai-tile/install_node_js.sh
```

**执行后提示：**
如需在当前 shell 中使用 Node.js，请运行：
```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

或重启终端。


### 2. 安装 opencode

全局安装 opencode 命令行工具。

**执行命令：**
```bash
npm install -g opencode-ai
```


### 3. 配置 API Key

`opencode_apikey_config.sh` 脚本用于配置 opencode 的 API Key。

**功能说明：**
- 交互式输入 API Key
- 交互式输入 END_POINT_ID（例如：ep-202620242022-123456）
- 自动创建配置文件：`~/.config/opencode/opencode.json`
- 配置火山引擎 API 端点

**执行命令：**
```bash
bash ai-tile/opencode_apikey_config.sh
```

**交互输入示例：**
```
请输入 API Key:
[输入您的 API Key]

请输入END_POINT_ID (例如: ep-202620242022-123456):
[输入您的 END_POINT_ID]
```

## 完整安装流程

在云服务器初始化时，按顺序执行以下命令：

```bash
# 1. 安装 Node.js
bash tilelang-ascend/install_node_js.sh

# 2. 加载 nvm 环境（如需要）
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. 安装 opencode
npm install -g opencode-ai

# 4. 配置 API Key
bash tilelang-ascend/opencode_apikey_config.sh
```

## 验证安装

安装完成后，可以通过以下命令验证：

```bash
# 检查 Node.js 版本
node -v

# 检查 npm 版本
npm -v

# 检查 opencode 版本
opencode --version
```

## 配置文件位置

opencode 配置文件位置：`~/.config/opencode/opencode.json`

配置文件示例：
```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "myprovider": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "volcengine",
      "options": {
        "baseURL": "https://ark.cn-beijing.volces.com/api/v3",
        "apiKey": "your-api-key"
      },
      "models": {
        "ep-202620242022-123456": {
          "name": "GLM-4-7-ep-202620242022-123456"
        }
      }
    }
  }
}
```

## 注意事项

1. 确保 Node.js 版本 >= 18
2. API Key 和 END_POINT_ID 需要提前准备好
3. 安装过程中需要网络连接
4. 建议使用 bash 执行脚本
