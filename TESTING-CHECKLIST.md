# TeacherKit 测试清单

**测试前确认**: 所有高优先级问题已修复 ✅

**测试日期**: 2025-10-27  
**测试环境**: VS Code + GitHub Copilot / Cursor

---

## Phase 1: 环境准备 (5 分钟)

### ✅ 安装测试

```bash
# 1. 确认 Python 版本
python --version  # 应显示 >= 3.11

# 2. 安装 TeacherKit
cd d:\PROJECTALL\Teacher
pip install -e .  # 开发模式安装

# 3. 验证安装
teacherkit --version  # 应显示 0.1.0
```

**预期结果**: 
- ✅ `teacherkit` 命令可用
- ✅ 显示版本号

---

### ✅ 项目初始化测试

```bash
# 创建测试项目
cd d:\PROJECTALL
teacherkit init test-teacher-2025

cd test-teacher-2025
ls -Recurse
```

**预期结果**:
- ✅ 创建目录结构：
  ```
  test-teacher-2025/
  ├── .specify/
  │   ├── templates/
  │   │   ├── outline-template.md
  │   │   ├── chapter-template.md
  │   │   ├── progress-template.md
  │   │   └── ipynb-template.ipynb
  │   └── scripts/powershell/
  │       ├── Generate-Outline.ps1
  │       ├── Prepare-Chapters.ps1
  │       ├── Generate-Practice.ps1
  │       ├── Copy-Chapter-Template.ps1
  │       ├── Copy-Practice-Template.ps1
  │       └── Update-Progress.ps1
  ├── .github/prompts/
  │   ├── teacherkit.check.prompt.md
  │   ├── teacherkit.outline.prompt.md
  │   ├── teacherkit.prepare.prompt.md
  │   ├── teacherkit.practice.prompt.md
  │   └── teacherkit.lesson.prompt.md
  ├── data/
  │   ├── outlines/
  │   ├── chapters/
  │   ├── exercises/
  │   └── progress.md
  ```

**检查点**:
- [ ] .specify/templates/ 包含 4 个模板文件
- [ ] .specify/scripts/powershell/ 包含 6 个脚本
- [ ] .github/prompts/ 包含 5 个提示词文件
- [ ] data/ 目录结构完整

---

## Phase 2: 脚本单元测试 (10 分钟)

### ✅ Test 1: Generate-Outline.ps1

```powershell
cd test-teacher-2025

# 测试生成大纲模板
.\.specify\scripts\powershell\Generate-Outline.ps1 -Topic "Python Variables"
```

**预期结果**:
- ✅ 创建文件: `data/outlines/python-variables-outline.md`
- ✅ 文件包含 YAML frontmatter
- ✅ 文件包含 Chapter/Topic/KP 结构占位符

**检查点**:
- [ ] 文件存在
- [ ] YAML 格式正确
- [ ] 包含 title, difficulty, chapters 字段

---

### ✅ Test 2: Copy-Chapter-Template.ps1

```powershell
# 测试复制章节模板
.\.specify\scripts\powershell\Copy-Chapter-Template.ps1 -KpId "KP-1.1.1" -Title "Variable Assignment"
```

**预期结果**:
- ✅ 创建文件: `data/chapters/Chapter1.1-variable-assignment.md`
- ✅ 文件包含 YAML frontmatter
- ✅ 文件包含 3 层苏格拉底问题结构

**检查点**:
- [ ] 文件存在
- [ ] 文件名格式正确 (Chapter{X}.{Y}-{slug}.md)
- [ ] 包含 Core Definition, Principle Explanation, Socratic Questions 部分

---

### ✅ Test 3: Copy-Practice-Template.ps1

```powershell
# 测试复制练习模板
.\.specify\scripts\powershell\Copy-Practice-Template.ps1 -Slug "variables-basics"
```

**预期结果**:
- ✅ 创建文件: `data/exercises/practice-variables-basics.ipynb`
- ✅ 文件是有效的 Jupyter Notebook 格式
- ✅ 包含 10 个 cells (标题 → 导入 → TODO → 提示 → 测试 → 反思)

**检查点**:
- [ ] 文件存在
- [ ] 可以在 VS Code 中打开
- [ ] 包含 markdown 和 code cells
- [ ] 包含 START CODE HERE / END CODE HERE 标记

---

## Phase 3: 提示词集成测试 (30 分钟)

### ✅ Test 4: /teacherkit.outline

**步骤**:
1. 在 VS Code 中打开 test-teacher-2025 项目
2. 打开 Copilot Chat
3. 输入: `/teacherkit.outline "Python variables and data types"`

**预期结果**:
- ✅ AI 分析主题
- ✅ 生成结构化大纲
- ✅ 保存到 `data/outlines/python-variables-outline.md`
- ✅ 包含 Chapter → Topic → KP 层次结构
- ✅ 每个 KP 有 difficulty, time, prerequisites 字段

**检查点**:
- [ ] AI 响应速度 < 60 秒
- [ ] 生成的 outline 结构完整
- [ ] YAML frontmatter 正确
- [ ] KP ID 格式正确 (KP-X.Y.Z)

---

### ✅ Test 5: /teacherkit.prepare

**步骤**:
1. 确保 outline 文件存在
2. 输入: `/teacherkit.prepare`

**预期结果**:
- ✅ AI 读取 outline
- ✅ 对每个 KP:
  - 调用 `Copy-Chapter-Template.ps1` (终端输出显示)
  - 生成 `Chapter*.md` 文件
  - 填充内容：定义、原理、代码示例、苏格拉底问题
- ✅ 所有 Chapter 文件保存到 `data/chapters/`

**检查点**:
- [ ] AI 显示脚本调用输出 "✅ Created: Chapter*.md"
- [ ] 生成多个 Chapter 文件（每个 KP 一个）
- [ ] 每个文件有 3 层苏格拉底问题
- [ ] 文件名格式正确
- [ ] has_exercise 字段正确标记（每 2-3 个 KP 中有 1 个）

---

### ✅ Test 6: /teacherkit.practice

**步骤**:
1. 确保 Chapter 文件存在
2. 输入: `/teacherkit.practice`

**预期结果**:
- ✅ AI 读取所有 Chapter 文件
- ✅ 找到 `has_exercise: true` 的 KP
- ✅ 对每个练习:
  - 调用 `Copy-Practice-Template.ps1` (终端输出显示)
  - 生成 `practice-*.ipynb` 文件
  - 填充内容：TODO、提示、测试用例
- ✅ 所有 ipynb 文件保存到 `data/exercises/`

**检查点**:
- [ ] AI 显示脚本调用输出 "✅ Created: practice-*.ipynb"
- [ ] 生成的 .ipynb 文件数量正确
- [ ] 每个文件包含 TODO 标记
- [ ] 包含 3 层提示（概念、具体、部分解决方案）
- [ ] 包含测试用例
- [ ] 可以在 Jupyter/VS Code 中打开

---

### ✅ Test 7: /teacherkit.lesson

**步骤**:
1. 确保 Chapter 和 exercise 文件都存在
2. 输入: `/teacherkit.lesson`

**预期结果**:
- ✅ AI 显示欢迎消息
- ✅ 按顺序读取 Chapter 文件
- ✅ 提出第 1 层苏格拉底问题
- ✅ 等待学生回答
- ✅ 根据回答深入第 2、3 层问题
- ✅ 完成 KP 后:
  - 调用 `Update-Progress.ps1` (终端输出显示)
  - 更新 `data/progress.md`
- ✅ 遇到 `has_exercise: true` 时提示打开 .ipynb 文件

**检查点**:
- [ ] AI 使用苏格拉底提问（不直接给答案）
- [ ] 问题有层次递进
- [ ] 根据学生回答调整后续问题
- [ ] 自动保存进度（看到 Update-Progress.ps1 调用）
- [ ] progress.md 更新正确
- [ ] 练习提示及时出现

---

## Phase 4: 端到端测试 (45 分钟)

### ✅ 完整学习流程

**场景**: 学习 "Python Variables" 主题

```
Step 1: 生成大纲
/teacherkit.outline "Python variables: assignment, types, naming rules"

Step 2: 准备章节
/teacherkit.prepare

Step 3: 生成练习
/teacherkit.practice

Step 4: 开始学习
/teacherkit.lesson

Step 5: 完成第一个 KP
- 回答 AI 的 3 层问题
- 观察进度自动保存

Step 6: 遇到练习
- AI 提示打开 .ipynb 文件
- 打开 data/exercises/practice-*.ipynb
- 完成 TODO
- 运行测试 cell

Step 7: 暂停学习
- 关闭 Copilot Chat

Step 8: 恢复学习
- 重新打开 Copilot Chat
- 输入: /teacherkit.lesson
- 验证 AI 显示 "Welcome back!" 和进度信息
```

**检查点**:
- [ ] 完整流程无错误
- [ ] 每个步骤过渡自然
- [ ] 文件生成正确
- [ ] 进度保存/恢复正常
- [ ] 练习文件可编辑可运行

---

## Phase 5: 边界情况测试 (15 分钟)

### ✅ Test 8: 缺少前置条件

```
# 场景 1: 没有 outline 就运行 prepare
/teacherkit.prepare

预期: AI 提示 "请先运行 /teacherkit.outline"
```

```
# 场景 2: 没有 chapters 就运行 practice
/teacherkit.practice

预期: AI 提示 "请先运行 /teacherkit.prepare"
```

```
# 场景 3: 没有 chapters 就运行 lesson
/teacherkit.lesson

预期: AI 提示 "请先运行 /teacherkit.prepare"
```

**检查点**:
- [ ] 错误提示清晰
- [ ] 告知下一步操作

---

### ✅ Test 9: 模板文件缺失

```powershell
# 故意删除模板
Remove-Item .specify\templates\ipynb-template.ipynb

# 尝试复制
.\.specify\scripts\powershell\Copy-Practice-Template.ps1 -Slug "test"

预期: 错误消息 "❌ Template not found: ..."
```

**检查点**:
- [ ] 脚本检测到缺失
- [ ] 错误消息清晰

---

## 测试总结

### 通过标准

- [ ] 所有 Phase 1-3 测试通过
- [ ] Phase 4 端到端测试无阻塞错误
- [ ] Phase 5 边界情况处理正确

### 遇到问题记录

| 问题 | 严重程度 | 复现步骤 | 解决方案 |
|------|----------|----------|----------|
|      |          |          |          |

---

## 测试后行动

### 如果全部通过
1. ✅ 更新 WORKFLOW-CHECK-REPORT.md 状态为 "测试通过"
2. ✅ 提交所有修改到 git
3. ✅ 准备用户文档（quickstart guide）

### 如果发现问题
1. 记录到"遇到问题记录"表格
2. 根据严重程度决定是否阻塞发布
3. 修复后重新运行失败的测试

---

**测试完成时间**: ______ (预计 2 小时)  
**测试人员**: ______  
**测试结果**: ⬜ 通过 / ⬜ 有问题需修复
