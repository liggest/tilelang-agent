# 挂载 tilelang-agent 到开发目录

## 概述

本指南说明如何将 tilelang-agent 的 .agents 目录软链接到 tilelang-ascend 项目，使 AI agent 能够访问自定义技能。

## 前提条件

- 已克隆 tilelang-agent 项目
- 已克隆或拥有 tilelang-ascend 项目
- 具有目标目录的写权限

## 步骤 1: 克隆 tilelang-agent 代码

```bash
git clone git@github.com:hedi515/tilelang-agent.git
```

## 步骤 2: 获取目录路径

从用户处获取以下信息：
- **开发目录路径**: 通常是 tilelang-ascend 项目的根目录
- **tilelang-agent 路径**: 已克隆的 tilelang-agent 项目根目录

示例路径：
- 开发目录: `/mnt/workspace/ai-test/tilelang-ascend/`
- tilelang-agent: `/mnt/workspace/ai-test/tilelang-agent/`

## 步骤 3: 创建软链接

将 tilelang-agent 下的 `.agents` 目录软链接到 tilelang-ascend 项目。

```bash
# 语法: ln -s <源路径> <目标路径>
ln -s /mnt/workspace/ai-test/tilelang-agent/.agents /mnt/workspace/ai-test/tilelang-ascend/.agents
```

**参数说明**:
- `-s`: 创建符号链接（软链接）
- 第一个参数: 源路径（tilelang-agent/.agents 的绝对路径）
- 第二个参数: 目标路径（tilelang-ascend/.agents 的绝对路径）

## 步骤 4: 验证软链接

执行以下命令验证软链接是否创建成功：

```bash
ls -la /mnt/workspace/ai-test/tilelang-ascend/ | grep .agents
```

**预期输出**:
```
lrwxrwxrwx  1 developer developer    45 Feb 28 16:22 .agents -> /mnt/workspace/ai-test/tilelang-agent/.agents
```

**验证要点**:
- 输出中应包含 `.agents` 条目
- 第一个字符应为 `l`（表示符号链接）
- 箭头 `->` 后应指向正确的源路径

## 步骤 5: 确认成功

如果验证命令显示正确的软链接信息，则说明配置成功。AI agent 现在可以通过 tilelang-ascend 项目访问 tilelang-agent 中定义的自定义技能。

## 故障排除

### 问题: 权限不足
**症状**: `ln: failed to create symbolic link: Permission denied`
**解决**: 确保对目标目录有写权限，或使用 sudo

### 问题: 文件已存在
**症状**: `ln: failed to create symbolic link: File exists`
**解决**: 先删除现有的 .agents 目录或软链接
```bash
rm -rf /mnt/workspace/ai-test/tilelang-ascend/.agents
```

### 问题: 路径错误
**症状**: 验证时找不到 .agents 或链接指向错误位置
**解决**: 检查源路径和目标路径是否正确，使用绝对路径
