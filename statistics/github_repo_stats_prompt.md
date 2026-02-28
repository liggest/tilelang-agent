# GitHub 仓库统计分析提示词

## 使用说明

将以下提示词复制并发送给 AI，即可自动生成任意 GitHub 仓库的统计分析报告

---

## 提示词内容

```
请帮我分析 GitHub 仓库 [仓库地址] 的统计数据，并生成完整的分析报告。

### 统计要求

1. **时间范围**: 按月统计，统计过去 3 个月的数据
2. **输出格式**: 
   - Excel 文件 (包含多个工作表)
   - Markdown 报告
3. **分析维度**:
   - 团队成员贡献统计
   - 项目代码统计
   - PR 统计
   - Issue 统计
   - 活跃度统计
   - 其他指标

### 需要收集的数据

#### 1. 仓库基本信息
使用命令:
```bash
gh repo view [仓库] --json name,description,stargazerCount,forkCount,watchers,createdAt,updatedAt,defaultBranchRef,primaryLanguage,diskUsage
```

#### 2. 代码语言统计
使用命令:
```bash
gh api repos/[owner]/[repo]/languages
```

#### 3. Issue 统计
使用命令:
```bash
gh api repos/[owner]/[repo]/issues --jq '. | length'
gh api repos/[owner]/[repo]/issues?state=open --jq '. | length'
gh api repos/[owner]/[repo]/issues?state=closed --jq '. | length'
```

#### 4. PR 统计
使用命令:
```bash
gh api repos/[owner]/[repo]/pulls?state=open --jq '. | length'
gh api repos/[owner]/[repo]/pulls?state=closed --jq '. | length'
gh api repos/[owner]/[repo]/pulls --paginate --jq '[.[] | {number, title, state, created_at, merged_at, closed_at, user: .user.login, additions: .additions, deletions: .deletions}]'
```

#### 5. 提交记录
使用命令:
```bash
gh api repos/[owner]/[repo]/commits --paginate --jq '[.[] | {.author.login, .commit.author.date}]'
```

#### 6. 贡献者统计
使用命令:
```bash
gh api repos/[owner]/[repo]/stats/contributors --jq '[.[] | {author: .author.login, total: .total, additions: .additions, deletions: .deletions}]'
```

#### 7. 每周活跃度
使用命令:
```bash
gh api repos/[owner]/[repo]/stats/commit_activity
```

### 报告结构要求

报表生成时建议搭配 xlsx Skill 进行使用

#### Excel 文件工作表:

1. **仓库基本信息**
   - 列: 指标, 数值, 说明
   - 内容: 仓库名称、描述、创建时间、更新时间、Stars、Forks、Watchers、磁盘使用、默认分支、主要语言、Issue/PR 数量等

2. **代码语言统计**
   - 列: 编程语言, 代码行数, 占比 (%)
   - 内容: 按语言分类的代码行数统计

3. **贡献者排名（Top 20）**
   - 列: 排名, 贡献者, 提交次数, 占比 (%)
   - 内容: 按提交次数排序的贡献者列表

4. **最近3个月活跃度统计**
   - 列: 月份, 周数, 总提交数, 平均每周提交, 活跃贡献者数
   - 内容: 按月统计的活跃度数据

5. **PR 统计分析**
   - 列: 指标, 数值, 说明
   - 内容: 总 PR 数、开放 PR、已关闭 PR、已合并 PR、合并率等

6. **Issue 统计分析**
   - 列: 指标, 数值, 说明
   - 内容: 总 Issue 数、开放 Issue、已关闭 Issue、关闭率等

7. **项目活跃度趋势**
   - 列: 时间周期, 提交次数, 活跃贡献者, 新增 PR, 新增 Issue, 活跃度评分
   - 内容: 按月统计的趋势数据

8. **整体变化趋势分析**
   - 列: 维度, 当前状态, 趋势, 评估
   - 内容: 各项指标的趋势评估

9. **关键发现与建议**
   - 列: 类别, 发现, 建议
   - 内容: 基于数据分析的关键发现和改进建议

#### Markdown 报告结构:

1. 标题和基本信息
2. 仓库基本信息表格
3. 代码语言统计表格
4. 贡献者排名表格 (Top 10)
5. 最近3个月活跃度统计表格
6. PR 统计分析表格
7. Issue 统计分析表格
8. 项目活跃度趋势表格
9. 整体变化趋势分析表格
10. 关键发现与建议
11. 数据文件说明

### 数据处理逻辑

1. **时间过滤**: 只统计最近 3 个月的数据（从当前日期往前推）
2. **百分比计算**: 所有占比需要计算百分比（保留 1 位小数）
3. **趋势判断**: 
   - 上升: 当前值 > 前期值
   - 稳定: 当前值 ≈ 前期值（±10%）
   - 下降: 当前值 < 前期值
4. **活跃度评分**:
   - 高: 每周提交 > 30
   - 中: 每周提交 15-30
   - 低: 每周提交 < 15
5. **贡献者占比**: 按提交次数计算占总提交数的百分比

### Excel 格式要求

1. **样式**:
   - 表头: 蓝色背景 (#4472C4)，白色粗体文字
   - 边框: 所有单元格添加细边框
   - 对齐: 表头居中，内容左对齐
   - 列宽: 自动调整为 18

2. **数值格式**:
   - 百分比: 保留 1 位小数
   - 整数: 不使用千位分隔符
   - 日期: YYYY-MM-DD 格式

### 输出文件

1. Excel 文件: `[仓库名]_stats.xlsx`
2. Markdown 文件: `[仓库名]_stats.md`

### 示例

如果要分析 `tile-ai/tilelang-ascend` 仓库，请将 `[仓库地址]` 替换为 `tile-ai/tilelang-ascend`，将 `[owner]/[repo]` 替换为 `tile-ai/tilelang-ascend`。

---

## 快速使用模板

### 方式 1: 直接复制提示词

复制上方提示词内容，将 `[仓库地址]` 替换为实际仓库地址，发送给 AI。

### 方式 2: 使用变量

```
请帮我分析 GitHub 仓库 {owner}/{repo} 的统计数据。

{owner}: 仓库所有者
{repo}: 仓库名称

[其余提示词内容...]
```

---

## 注意事项

1. **GitHub CLI 要求**: 需要 `gh` 命令行工具已安装并认证
2. **API 限制**: GitHub API 有速率限制，大量数据可能需要分页获取
3. **时间计算**: 当前日期为执行日期，需要动态计算 3 个月前的日期
4. **数据验证**: 确保所有数值计算正确，百分比总和应为 100%
5. **错误处理**: 如果某个 API 调用失败，需要优雅降级并标注数据缺失

---

## 扩展功能（可选）

如果需要更详细的分析，可以添加以下数据：

1. **提交热力图**: 按小时/星期统计提交分布
2. **文件类型分布**: 按文件扩展名统计
3. **代码变更趋势**: 按月统计新增/删除代码行数
4. **PR 审查时间**: 统计 PR 从创建到合并的平均时间
5. **Issue 响应时间**: 统计 Issue从创建到关闭的平均时间
6. **标签分析**: 统计 Issue/PR 的标签分布
7. **参与度分析**: 统计评论、点赞等互动数据

---

## 报告质量检查清单

生成报告后，请检查：

- [ ] 所有表格数据完整，无空值
- [ ] 百分比计算正确，总和为 100%
- [ ] 日期格式统一 (YYYY-MM-DD)
- [ ] 数值格式正确（整数/小数）
- [ ] 趋势判断合理
- [ ] 建议具有可操作性
- [ ] Excel 文件可以正常打开
- [ ] Markdown 格式正确，表格渲染正常
- [ ] 文件命名规范

---

*提示词版本: 1.0*
*最后更新: 2026-02-28*
