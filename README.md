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
#   data/
#     outlines/               ← 生成的学习计划
#     chapters/               ← 准备好的知识点
#     exercises/              ← 练习代码文件
#     progress.md             ← 学习进度记录
```

---

## 📖 使用方法

### 典型工作流

```bash
# 1. 初始化项目
socrate init my-learning

# 2. 在 AI 对话中附加教材文件，或直接描述主题
/teacherkit.outline          # 生成学习大纲

# 3. 准备知识点内容
/teacherkit.prepare          # 添加问题、示例、练习

# 4. 开始学习
/teacherkit.lesson           # 苏格拉底式对话教学

# 5. 暂停/恢复
输入 "pause" 保存进度
下次运行 /teacherkit.lesson 自动恢复
```

### 三种学习方式

**方式 1**：从文件学习  
→ 附加 `.md`/`.pdf` 文件 → `/teacherkit.outline`

**方式 2**：从主题学习  
→ `/teacherkit.outline "Python 装饰器"` → AI 生成大纲

**方式 3**：恢复学习  
→ `/teacherkit.lesson` → 选择继续/回顾/重新开始

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
- OpenAI - 学习与研究提示词

目前适配的 AI 代码助手：
- GitHub Copilot


---

**准备好转变你的学习方式了吗？**

