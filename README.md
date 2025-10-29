# 🏛️ Socrate

> **AI-Powered Socratic Teaching System for Interactive Learning**

Socrate 是一个基于苏格拉底式对话法的 AI 教学助手 CLI 工具。通过提问引导学习，而非直接给出答案，帮助学生深入理解编程概念。

[![Python Version](https://img.shields.io/badge/python-3.11%2B-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)

---

## ✨ 核心特性

### 🧠 苏格拉底式教学法
- **问题驱动学习**：先提问，再根据学生回答提供解释
- **三层问题设计**：概念理解 → 原理探索 → 实际应用
- **自适应对话**：根据学生回答调整对话深度

### 📚 灵活的学习模式
- **文件式学习**：上传教材/PDF/Markdown → 自动生成结构化学习计划
- **主题式学习**：描述想学的内容 → AI 创建定制大纲
- **进度追踪**：自动保存学习进度，随时恢复

### 🏋️ 实践练习
- **自动生成练习**：每 2-3 个知识点后出现练习题
- **TODO 驱动编码**：填空式练习，渐进式提示
- **苏格拉底式代码审查**：提交代码后 AI 通过提问帮你发现问题

### 📊 无缝会话管理
- **自动保存进度**：每完成一个概念自动保存
- **智能恢复**：回到学习时选择继续/回顾/重新开始
- **主动检查点**：学习 1 小时后温馨提醒休息

---

## 🚀 快速开始

### 安装

使用 [uv](https://github.com/astral-sh/uv) 安装（推荐）：

```bash
# 安装 uv（如果尚未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 安装 Socrate
uv tool install socrate
```

或使用 pip：

```bash
pip install socrate
```

### 初始化学习项目

```bash
# 创建新的学习工作区
socrate init my-python-journey

# 进入目录
cd my-python-journey

# 项目结构：
# my-python-journey/
#   .github/prompts/          ← AI 提示词模板
#   data/
#     outlines/               ← 生成的学习计划
#     chapters/               ← 准备好的知识点
#     exercises/              ← 练习代码文件
#     progress.md             ← 学习进度记录
```

---

## 📖 使用方法

### 场景 1：从文件学习（教材/PDF/Markdown）

**步骤 1**：将文件附加到 AI 对话

```
[附加: python-fundamentals.pdf]
```

**步骤 2**：生成大纲

```
/teacherkit.outline
```

**AI 回应**：
```
📚 我已分析你的教材！学习计划如下：

第 1 章：Python 基础（3-4 小时）
├── 1.1 变量与数据类型（30 分钟）
│   ├── KP-1.1.1：变量赋值与命名
│   ├── KP-1.1.2：数值类型（int, float）
│   └── KP-1.1.3：字符串操作
└── 1.2 控制流（45 分钟）
    └── ... [更多内容]

保存至: data/outlines/python-fundamentals-outline.md
准备开始？运行 /teacherkit.prepare 继续！
```

**步骤 3**：准备知识点

```
/teacherkit.prepare
```

**AI 回应**：
```
✅ 准备了 18 个知识点：
- 核心定义
- 代码示例
- 苏格拉底式问题（每个 3 层）
- 类比与对比表格

保存至: data/chapters/python-fundamentals-prepared.md
开始学习！运行 /teacherkit.lesson
```

**步骤 4**：开始交互式学习

```
/teacherkit.lesson
```

**AI 回应**（苏格拉底式对话开始）：
```
🎓 欢迎来到你的 Python 学习之旅！

今天我们将探索：变量与数据类型（30 分钟）

让我们从一个问题开始：

想象你有一个盒子可以存放东西。在编程中，
我们称之为"变量"。

🤔 问题 1：如果我告诉你有一个标签为 "age" 的盒子，
里面装着数字 25，那么如果我后来把数字 30 放进同一个
盒子，你认为会发生什么？

（思考一下，然后分享你的答案！）
```

**步骤 5**：练习（在 AI 提示时）

```
[完成 2-3 个概念后，AI 说：]

进展不错！来点实践吧。

我已创建：data/exercises/practice-variables-01.py
用 VS Code 打开，填写 TODO 部分并运行代码！
```

---

### 场景 2：从主题描述学习

**步骤 1**：描述想学的内容

```
/teacherkit.outline "我想了解 Python 列表推导式"
```

**AI 回应**：
```
📚 自定义课程：列表推导式

难度：中级  
预计时间：20-30 分钟

主题 1：基础（10 分钟）
├── KP-1.1：基本列表操作回顾
├── KP-1.2："推导式"的概念
└── KP-1.3：语法拆解：[expression for item in iterable]

主题 2：实际应用（15 分钟）
├── KP-2.1：使用条件过滤
├── KP-2.2：数据转换
└── KP-2.3：嵌套推导式

[后续步骤与场景 1 相同...]
```

---

### 场景 3：暂停后恢复

```
[打开对话，运行：]
/teacherkit.lesson
```

**AI 回应**：
```
🎓 欢迎回来！

上次学习：2025 年 10 月 23 日 15:45
距离上次学习：2 天

目前进度：8 个知识点（44% 完成）
- KP-1.1.1：变量赋值
- KP-1.1.2：数值类型
- ... [最近的知识点]

下一个：KP-1.3.1：If/else 语句

---

你想如何继续？
选项 A：从上次位置继续（直接开始）
选项 B：快速回顾，然后继续（5 分钟复习）
选项 C：从新主题开始

（只需说 "A"、"B" 或 "C"！）
```

---

## 🏗️ 架构概览

### 提示词优先设计

Socrate **不是传统的 CLI 工具**。它是一组 **AI 提示词模板** 的集合，通过对话来教学：

```
CLI（一次性设置）          AI 提示词（真正的教师）
├── socrate init           ├── /teacherkit.outline
│   └── 设置文件夹          │   └── 分析文件/主题 → 创建课程计划
└── socrate config         ├── /teacherkit.prepare
    └── 管理设置            │   └── 细化概念 → 添加苏格拉底式问题
                          ├── /teacherkit.practice
                          │   └── 生成 Jupyter Notebook 练习
                          ├── /teacherkit.lesson
                          │   └── 交互式教学对话
                          └── /teacherkit.check
                              └── 质量验证（可选）
```

### 数据存储

所有数据存储在 **Markdown 文件** 中，带 YAML frontmatter：

```
data/
├── outlines/
│   └── [主题]-outline.md            # 学习计划与章节结构
├── chapters/
│   └── Chapter*.md                  # 单个知识点文件
├── exercises/
│   ├── practice-[主题].py           # 练习文件
│   └── exercises-meta.md            # 练习目录
└── progress.md                      # 学习进度（自动保存）
```

**无需数据库！** 所有文件都是人类可读可编辑的。

---

## 🛠️ 开发

### 从源码安装

```bash
git clone https://github.com/socrate/socrate.git
cd socrate
uv pip install -e ".[dev]"
```

### 运行测试

```bash
pytest
```

### 代码检查

```bash
# 格式检查
ruff check .

# 类型检查
mypy src/socrate_cli
```

---

## 🤝 贡献

欢迎贡献！请随时提交 issues 或 pull requests。

### 修改提示词模板

所有教学行为都在 `.github/prompts/` 中定义：

```
.github/prompts/
├── teacherkit.outline.prompt.md      # 课程计划生成
├── teacherkit.prepare.prompt.md      # 知识点细化
├── teacherkit.lesson.prompt.md       # 苏格拉底式教学对话（850+ 行！）
├── teacherkit.practice.prompt.md     # 练习生成
└── teacherkit.check.prompt.md        # 质量验证
```

**自定义教学风格**：
1. 编辑相关的 `.prompt.md` 文件
2. 重新运行 `socrate init` 复制更新的提示词
3. 用新的学习会话测试

**无需编程！** 只需修改 Markdown 模板。

---

## 📚 项目结构

```
socrate/
├── .github/
│   └── prompts/           # AI 提示词模板（核心功能）
├── src/
│   └── socrate_cli/       # CLI 命令实现
│       ├── __init__.py    # 主入口点
│       ├── commands/      # 命令模块
│       │   ├── init.py    # 项目初始化
│       │   ├── config.py  # 配置管理
│       │   └── update.py  # 更新提示词
│       └── utils/         # 工具函数
│           ├── git.py     # Git 操作
│           ├── progress.py # 进度追踪
│           └── template.py # 模板处理
├── pyproject.toml         # 项目配置
└── README.md              # 本文件
```

---

## 📜 许可证

Apache License 2.0 - 详见 [LICENSE](LICENSE) 文件

---

## 🙏 致谢

灵感来源：
- [spec-kit](https://github.com/yisak/spec-kit) - 结构化 AI 工作流的先驱
- OpenAI - 苏格拉底式教学原则

技术支持：
- [Typer](https://typer.tiangolo.com/) - 优雅的 CLI 框架
- [Rich](https://rich.readthedocs.io/) - 终端格式化
- [GitPython](https://gitpython.readthedocs.io/) - Git 操作

适配的 AI 代码助手：
- GitHub Copilot
- Cursor
- Claude Code

---

**准备好转变你的学习方式了吗？**

```bash
socrate init my-learning-journey
# 然后附加文件或描述主题 + /teacherkit.outline
```

*快乐学习！ 🎓✨*
