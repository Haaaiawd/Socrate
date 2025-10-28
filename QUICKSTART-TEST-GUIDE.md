# TeacherKit 快速测试指南

**测试时间**: 预计 30-60 分钟  
**测试目标**: 验证完整工作流程  

---

## 第一步：安装 TeacherKit (5 分钟)

### 1.1 确认环境

```powershell
# 检查 Python 版本（需要 >= 3.11）
python --version

# 检查是否有 pip
pip --version
```

**预期输出**:
```
Python 3.11.x 或更高
pip 23.x.x
```

---

### 1.2 安装 TeacherKit

```powershell
# 进入项目目录
cd d:\PROJECTALL\Teacher

# 开发模式安装（会安装依赖：typer, rich, gitpython, pyyaml）
pip install -e .
```

**预期输出**:
```
Successfully installed teacherkit-0.1.0
Installing dependencies...
Successfully installed typer-0.9.0 rich-13.x.x gitpython-3.1.x pyyaml-6.0
```

---

### 1.3 验证安装

```powershell
# 测试命令
teacherkit --version
```

**预期输出**:
```
TeacherKit version 0.1.0
```

---

## 第二步：创建学习项目 (2 分钟)

### 2.1 初始化项目

```powershell
# 创建新的学习项目
cd d:\PROJECTALL
teacherkit init test-python-learning

# 进入项目
cd test-python-learning
```

**预期输出**:
```
Initializing TeacherKit project at: D:\PROJECTALL\test-python-learning

✓ Creating directories
✓ Copying templates
✓ Copying prompts
✓ Setting up data storage
✓ Creating configuration
✓ Initializing git repository
✓ Setup complete

Project initialized successfully!

Next steps:
1. Open this folder in VS Code
2. Start learning with: /teacherkit.outline
```

---

### 2.2 验证目录结构

```powershell
# 查看创建的目录
tree /F
```

**预期结构**:
```
test-python-learning/
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
└── .gitignore
```

---

## 第三步：在 VS Code 中打开项目 (1 分钟)

```powershell
# 用 VS Code 打开项目
code .
```

**重要**: 确保你的 VS Code 安装了 **GitHub Copilot** 扩展

---

## 第四步：开始学习工作流 (20 分钟)

### 4.1 生成学习大纲

**在 VS Code 中**:
1. 打开 **GitHub Copilot Chat** (Ctrl+Alt+I 或点击侧边栏图标)
2. 输入命令:

```
/teacherkit.outline "Python variables and data types: assignment, naming rules, basic types (int, str, bool)"
```

**AI 应该做什么**:
- 分析主题
- 生成结构化大纲
- 保存到 `data/outlines/python-variables-outline.md`

**验证**:
```powershell
# 检查生成的文件
cat data\outlines\python-variables-outline.md
```

**预期内容**:
- YAML frontmatter (title, difficulty, chapters)
- Chapter → Topic → KP 层次结构
- 每个 KP 有 id, difficulty, time, prerequisites

---

### 4.2 准备章节文件

**在 Copilot Chat 中输入**:

```
/teacherkit.prepare
```

**AI 应该做什么**:
1. 读取 outline 文件
2. 对每个 KP:
   - 调用 `Copy-Chapter-Template.ps1` (你会在终端看到输出)
   - 编辑生成的 `Chapter*.md` 文件
   - 填充：定义、原理、代码示例、苏格拉底问题

**观察终端输出**:
```
✅ Created: Chapter1.1-variable-assignment.md
✅ Created: Chapter1.2-naming-rules.md
✅ Created: Chapter1.3-integer-types.md
...
```

**验证**:
```powershell
# 查看生成的章节文件
ls data\chapters\
cat data\chapters\Chapter1.1-variable-assignment.md
```

**预期内容**:
- YAML frontmatter (kp_id, title, chapter, has_exercise)
- Core Definition 部分
- Principle Explanation 部分
- Code Examples 部分
- Socratic Questions (3 层)

---

### 4.3 生成练习文件

**在 Copilot Chat 中输入**:

```
/teacherkit.practice
```

**AI 应该做什么**:
1. 读取所有 Chapter 文件
2. 找到 `has_exercise: true` 的 KP
3. 对每个练习:
   - 调用 `Copy-Practice-Template.ps1` (终端输出)
   - 编辑生成的 `.ipynb` 文件
   - 填充：TODO、提示、测试用例

**观察终端输出**:
```
✅ Created: practice-variable-assignment.ipynb
✅ Created: practice-data-types.ipynb
```

**验证**:
```powershell
# 查看生成的练习文件
ls data\exercises\

# 在 VS Code 中打开 ipynb 文件
code data\exercises\practice-variable-assignment.ipynb
```

**预期内容**:
- Cell 1: Markdown 标题（概念、难度、时间）
- Cell 2: 导入库
- Cell 3-4: TODO + 函数骨架
- Cell 5: 提示（折叠）
- Cell 6-7: 测试用例
- Cell 8: 反思问题

---

### 4.4 开始互动学习

**在 Copilot Chat 中输入**:

```
/teacherkit.lesson
```

**AI 应该做什么**:
1. 显示欢迎消息
2. 读取第一个 Chapter 文件
3. 提出第 1 层苏格拉底问题
4. 等待你回答
5. 根据你的回答提出第 2、3 层问题
6. 完成 KP 后调用 `Update-Progress.ps1` (终端输出)

**互动示例**:

```
AI: 🎓 Welcome to Interactive Learning: Python Variables

Let's start with: Variable Assignment

🤔 Question: Imagine you need to remember a number for later use 
in your program. How would you do that in real life?

(Think about it, then type your answer!)
```

**你回答**: "我会把它写在纸上，给它起个名字"

```
AI: Great analogy! So in programming, we do something similar.

🤔 Follow-up: If you wrote multiple numbers on paper, how would 
you tell them apart?
```

**继续对话** 直到完成第一个 KP

**验证进度保存**:
```powershell
# 检查进度文件
cat data\progress.md
```

**预期内容**:
- YAML frontmatter 更新
- completed_kps 列表包含 "KP-1.1.1"
- sessions 记录

---

### 4.5 完成练习

**当 AI 提示练习时**:

```
AI: Great progress! Time for hands-on practice.

I've created: data/exercises/practice-variable-assignment.ipynb

Open it in VS Code, complete the TODOs, and run the cells!
```

**你的操作**:
1. 在 VS Code 中打开 `.ipynb` 文件
2. 找到 `### START CODE HERE ###` 标记
3. 填写代码
4. 运行 test cell 验证

**示例**:
```python
# Cell 3
# TODO 1: Create a variable 'age' and assign your age

### START CODE HERE ###
age = 25  # 填写你的代码
### END CODE HERE ###

# Cell 6 (运行测试)
assert isinstance(age, int), "age should be an integer"
print(f"✅ Test passed! age = {age}")
```

---

### 4.6 暂停和恢复学习

**暂停**:
- 直接关闭 Copilot Chat 窗口
- 进度已自动保存到 `data/progress.md`

**恢复**:
1. 重新打开 Copilot Chat
2. 输入: `/teacherkit.lesson`

**AI 应该显示**:
```
👋 Welcome back!

📊 Your Progress:
- Completed: 1 KPs (33%)
- Last session: 2025-10-27
- Next up: KP-1.1.2 - Naming Rules

Continue from where you left off? (yes/no)
```

---

## 第五步：验证所有文件 (5 分钟)

### 5.1 检查生成的文件

```powershell
# 查看 outline
cat data\outlines\python-variables-outline.md

# 查看 chapters（应该有多个文件）
ls data\chapters\
cat data\chapters\Chapter1.1-variable-assignment.md

# 查看 exercises（.ipynb 文件）
ls data\exercises\

# 查看 progress
cat data\progress.md
```

---

### 5.2 在 Jupyter 中测试练习文件

```powershell
# 安装 Jupyter（如果还没有）
pip install jupyter

# 打开练习文件
jupyter notebook data\exercises\practice-variable-assignment.ipynb
```

**验证**:
- [ ] 文件可以打开
- [ ] Cells 可以运行
- [ ] 测试 cell 可以通过

---

## 常见问题排查

### ❌ 问题 1: `teacherkit` 命令找不到

**解决方案**:
```powershell
# 重新安装
cd d:\PROJECTALL\Teacher
pip uninstall teacherkit
pip install -e .

# 验证 Python Scripts 目录在 PATH 中
echo $env:PATH
```

---

### ❌ 问题 2: Copilot Chat 不识别提示词

**解决方案**:
1. 确认 `.github/prompts/` 目录存在
2. 重启 VS Code
3. 检查 Copilot 扩展是否启用

---

### ❌ 问题 3: PowerShell 脚本无法执行

**解决方案**:
```powershell
# 设置执行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 验证
Get-ExecutionPolicy
```

---

### ❌ 问题 4: 脚本调用失败

**解决方案**:
```powershell
# 手动测试脚本
cd test-python-learning
.\.specify\scripts\powershell\Copy-Chapter-Template.ps1 -KpId "KP-1.1.1" -Title "Test"

# 检查输出是否正常
```

---

### ❌ 问题 5: `.ipynb` 文件无法打开

**解决方案**:
```powershell
# 安装 VS Code Jupyter 扩展
# 在 VS Code Extensions 中搜索 "Jupyter" 并安装

# 或安装 Jupyter Lab
pip install jupyterlab
jupyter lab
```

---

## 测试成功标准

### ✅ 全部通过则系统可用

- [ ] `teacherkit` 命令可用
- [ ] `teacherkit init` 创建完整目录结构
- [ ] `/teacherkit.outline` 生成 outline 文件
- [ ] `/teacherkit.prepare` 生成多个 Chapter*.md 文件
- [ ] `/teacherkit.practice` 生成 .ipynb 文件
- [ ] `/teacherkit.lesson` 提出苏格拉底问题
- [ ] 进度自动保存到 progress.md
- [ ] 练习文件可在 Jupyter/VS Code 中打开和运行
- [ ] 暂停/恢复功能正常

---

## 快速命令速查表

```powershell
# === 安装 ===
pip install -e .

# === 初始化项目 ===
teacherkit init my-project
cd my-project
code .

# === 在 Copilot Chat 中使用 ===
# 1. 生成大纲
/teacherkit.outline "主题描述"

# 2. 准备章节
/teacherkit.prepare

# 3. 生成练习
/teacherkit.practice

# 4. 开始学习
/teacherkit.lesson

# 5. 恢复学习
/teacherkit.lesson

# === 手动脚本（可选）===
# 快速创建大纲模板
.\.specify\scripts\powershell\Generate-Outline.ps1 -Topic "Python"

# 检查前置条件
.\.specify\scripts\powershell\Prepare-Chapters.ps1
.\.specify\scripts\powershell\Generate-Practice.ps1
```

---

## 预计时间分配

| 步骤 | 时间 | 累计 |
|------|------|------|
| 安装 TeacherKit | 5 min | 5 min |
| 创建学习项目 | 2 min | 7 min |
| 打开 VS Code | 1 min | 8 min |
| 生成 outline | 3 min | 11 min |
| 准备 chapters | 5 min | 16 min |
| 生成练习 | 3 min | 19 min |
| 互动学习 | 10 min | 29 min |
| 验证文件 | 5 min | 34 min |

**总计**: ~35 分钟（首次测试）

---

## 测试完成后

### 📝 记录结果

在 [TESTING-CHECKLIST.md](./TESTING-CHECKLIST.md) 中勾选完成的项目。

### 🐛 如果发现问题

1. 记录问题描述
2. 记录复现步骤
3. 截图或复制错误消息
4. 在项目中创建 issue

### ✅ 测试通过

恭喜！TeacherKit 系统正常工作，可以开始真正的学习了！

---

**祝测试顺利！有问题随时提问。** 🎓
