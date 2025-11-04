# 🏛️ Socrate

> **AI-Powered Socratic Teaching System for Interactive Learning**

Socrate 是一个基于苏格拉底式对话法的 AI 教学助手 CLI 工具。通过提问引导学习，而非直接给出答案，帮助学生深入理解编程概念。

[![Python Version](https://img.shields.io/badge/python-3.11%2B-blue.svg)](https://www.python.org/downloads/)
[![License](https://img.shields.io/badge/license-Apache%202.0-green.svg)](LICENSE)

---

## 我们使用了什么（What we use）

- UbD Stage 1 作为唯一备课内容：只包含 EU（Enduring Understandings）/ EQ（Essential Questions）/ SWBAT（Students Will Be Able To）
- Markdown 文件存储：`outlines/`（大纲）与 `lessons/`（单元备课）
- 提示词作为事实来源（SoT）：`/.github/prompts`（Copilot），`/.claude/commands`（Claude）语义镜像
- 极简 CLI：初始化与模板分发；教学逻辑在提示词中

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

使用 [uv](https://github.com/astral-sh/uv) 从 Git 仓库安装（推荐）：

```bash
# 安装 uv（如果尚未安装）
curl -LsSf https://astral.sh/uv/install.sh | sh

# 从 GitHub 安装 Socrate
uv tool install socrate --from git+https://github.com/Haaaiawd/Socrate.git
```

或使用传统方式：

```bash
# 克隆仓库
git clone https://github.com/Haaaiawd/Socrate.git
cd Socrate

# 安装
pip install -e .
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
#   outlines/                 ← 生成的学习计划（含 UbD 字段）
#   lessons/                  ← 课前简短备课（仅 EU/EQ/SWBAT）
```

---

## 📖 使用方法

### AI 助手支持

Socrate 同时支持 **GitHub Copilot** 和 **Claude Code**：

#### GitHub Copilot
```bash
# 在 VS Code Copilot Chat 中使用
/socrate.outline          # 生成学习大纲
/socrate.lesson           # 先生成 UbD 备课文件；按需开始对话教学
/socrate.check            # 质量检查
```

#### Claude Code
```bash
# 在 Claude Code 中使用
/socrate.outline          # 生成学习大纲
/socrate.lesson           # 先生成 UbD 备课文件；按需开始对话教学
/socrate.check            # 质量检查
```

### 典型工作流

```bash
# 1. 初始化项目
socrate init my-learning

# 2. 在 AI 对话中附加教材文件，或直接描述主题
/socrate.outline          # 生成学习大纲

# 3. Lesson 阶段：先备课后上课
/socrate.lesson           # 生成 UbD 备课文件

# 5. 暂停/恢复
输入 "pause" 保存进度
下次运行 /socrate.lesson 自动恢复
```

### 三种学习方式

**方式 1**：从文件学习  
→ 附加 `.md`/`.pdf` 文件 → `/socrate.outline`

**方式 2**：从主题学习  
→ `/socrate.outline "Python 装饰器"` → AI 生成大纲


---

## 🏗️ 架构概览

### 提示词优先设计

Socrate **不是传统的 CLI 工具**。它是一组 **AI 提示词模板** 的集合，通过对话来教学：

```
CLI（一次性设置）          AI 提示词（真正的教师）
├── socrate init           ├── /socrate.outline
│   └── 设置文件夹          │   └── 分析文件/主题 → 创建课程计划
└── socrate config         ├── /socrate.lesson
    └── 管理设置            │   └── 先生成 UbD 备课（仅 EU/EQ/SWBAT），再按需在对话中开展教学
                          └── /socrate.check
                              └── 质量验证（可选）
```

### 数据存储

所有数据存储在 **Markdown 文件** 中，带 YAML frontmatter：

```
outlines/
└── [主题]-outline.md            # 学习计划与章节/KP 结构（含 UbD Stage 1）

lessons/
└── [kp-id]-plan.md             # 单节 UbD 备课
```

**无需数据库！** 所有文件都是人类可读可编辑的

---


## 🤝 贡献

欢迎贡献！请随时提交 issues 或 pull requests。

### 修改提示词模板

所有教学行为都在提示词文件中定义：

**GitHub Copilot** (`.github/prompts/`):
```
.github/prompts/
├── socrate.outline.prompt.md      # 课程计划生成（含 UbD Stage 1 字段）
├── socrate.lesson.prompt.md       # UbD 备课 + 苏格拉底式教学对话
└── socrate.check.prompt.md        # 质量验证
```

**Claude Code** (`.claude/commands/`):
```
.claude/commands/
├── socrate.outline.md      # 课程计划生成（含 UbD 字段）
├── socrate.lesson.md       # UbD 备课 + 苏格拉底式教学对话
└── socrate.check.md        # 质量验证
```

**自定义教学风格**：
1. 编辑相关的提示词文件
2. 重新运行 `socrate update` 更新到项目
3. 用新的学习会话测试


---

## 📚 项目结构

```
socrate/
├── .github/
│   └── prompts/           # GitHub Copilot 提示词模板
├── .claude/
│   └── commands/          # Claude Code 命令文件
├── src/
│   └── socrate_cli/       # CLI 命令实现
│       ├── __init__.py    # 主入口点
│       ├── commands/      # 命令模块
│       │   ├── init.py    # 项目初始化
│       │   ├── config.py  # 配置管理
│       │   └── update.py  # 更新提示词
│       └── utils/         # 工具函数
│           ├── git.py     # Git 操作
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
- OpenAI - 学习与研究提示词

目前适配的 AI 代码助手：
- GitHub Copilot
- Claude Code

---

**准备好转变你的学习方式了吗？**

