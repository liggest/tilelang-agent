# ai tilelang

## 环境配置

当前算力平台已上线，可以通过个人电脑、开源空间、黄区 Jumper 跳转进行访问，并在算力平台上进行开发调试，可以提高开发效率。（推荐使用黄区 Jumper 跳转蓝区的方式进行访问，比较丝滑）

为了提高开发效率，减少重复工作，同时为了解决算力平台时常出现的崩溃问题，规划了如下的脚本和 SKILL，可以快速完成基础环境的配置。

### 基础环境配置

| 名称 | 类型 | 功能 | 地址 |
|---|---|---|---|
| node.js 配置安装 | shell 脚本 | 在算力平台机器上一键安装 node.js | scripts/install_node_js.sh |
| opencode 安装 | shell 命令 | 安装 openCode | `npm install -g opencode-ai` |
| API KEY 配置 | shell 脚本 | opencode 火山 GLM API KEY 配置 | scripts/opencode_apikey_config.sh |

如果需要更详细步骤，可查看 guide/opencode_installation_guide.md
opencode 基础能力，可以参考 https://opencode.ai/docs/zh-cn

### 其他配置

| 名称 | 类型 | 功能 | 地址 |
|---|---|---|---|
| 算力平台 home 目录持久化 | shell 脚本 | 在算力平台机器上持久化 home 目录 | [操作指导](guide/home_path_persistence.md) | 

## 开发

### 挂载 tilelang-agent

后续开发中用到的 SKILL 建议都归档到 tilelang-agent 中，在开发前直接挂载一下即可运用 tilelang-agent 进行开发。
详细指导和提示词可以参考[此文档](guide/tile_agent_ln.md)。

### 基础 SKILL 配置

| 名称 | 功能 | 地址 | 用处 |
|---|---|---|---|
| skill-creator | 创建 SKILL | https://github.com/anthropics/skills/tree/main/skills/skill-creator | 可以把常用的、总结好的提示词转换成 SKILL |
| requesting-code-review | 创建代码 review | https://github.com/obra/superpowers | 提交代码前，建议先用代码审查一编 |
| tilelang-install-skill | 拉取 tielang 代码仓并编译 | .agents/skills/tilelang-install-skill | 可在算力平台环境上一键安装 tilelang |

更多 SKILL 能力可以参考 https://skills.sh/

### 调测 SKILL 配置

| 名称 | 功能 | 地址 | 用处 |
|---|---|---|---|
| tilelang-debug-helper | 调试 SKILL | .agens/skills/tilelang-debug-helper | 对给出Example代码进行调试 |
| 欢迎大家持续补充。。 |  |  |  |


## 测试

鉴于 AI 的不确定性，后续可尝试补充单元测试UT SKILL ，通过单元测试来约束 AI, 避免引入新的错误，或者不确定性的错误。提高代码生成的准确率。