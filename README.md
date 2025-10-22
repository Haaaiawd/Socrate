# TeacherKit 🎓

> AI-powered Socratic teaching system for interactive learning

[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![PowerShell 7+](https://img.shields.io/badge/powershell-7.0+-blue.svg)](https://github.com/PowerShell/PowerShell)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

TeacherKit helps students learn by uploading textbooks and engaging in AI-guided Socratic dialogue. The system generates structured learning plans, extracts knowledge points, and asks guiding questions—never giving direct answers.

## Features

- 📚 **Textbook Parsing**: Upload textbooks and get structured outlines
- 📖 **Chapter Preparation**: Auto-extract knowledge points and generate questions
- 💬 **Socratic Dialogue**: AI guides learning with questions, not answers
- 📊 **Progress Tracking**: Monitor learning progress across chapters
- 📝 **Note Taking**: Mark and save text highlights during lessons

## 核心原则

本项目遵循严格的开发原则,详见 [项目宪章](.specify/memory/constitution.md):

- **Markdown-First Storage**: 所有数据以 `.md` 文件存储,简单、可移植、版本友好
- **CLI-First Interface**: 纯命令行交互,无 GUI 开销,专注核心功能
- **Test-Driven Development**: 严格 TDD 流程,测试先行,80% 代码覆盖率要求
- **AI-Aware Code Quality**: 代码结构适配 AI 协作,小函数、类型提示、完整文档
- **Incremental MVP Approach**: 优先级驱动,P1 功能构成 MVP,避免功能蔓延
- **Educational Flow Integrity**: 尊重教学法,维护学习上下文,支持渐进式学习
- **Observability & Debuggability**: 结构化日志,可调试的 CLI,错误信息可操作

## 快速开始

### 安装

```bash
# 克隆仓库
git clone https://github.com/yourusername/teacher-ai-agent.git
cd teacher-ai-agent

# 安装依赖 (待实现)
pip install -r requirements.txt
```

### 基本使用

```bash
# 创建学习计划
teacher create-outline --textbook path/to/textbook.md

# 开始教学
teacher start-lesson --chapter 1

# 查看进度
teacher status

# 查看笔记
teacher notes
```

## 项目结构

```
Teacher/
├── .specify/                 # 项目规范和模板
│   ├── memory/
│   │   └── constitution.md  # 项目宪章
│   └── templates/           # 功能规范模板
├── src/                     # 源代码 (待创建)
│   ├── models/             # 数据模型
│   ├── services/           # 业务逻辑
│   ├── cli/                # 命令行接口
│   └── lib/                # 工具库
├── tests/                   # 测试 (待创建)
│   ├── contract/           # 契约测试
│   ├── integration/        # 集成测试
│   └── unit/               # 单元测试
├── data/                    # 数据存储 (待创建)
│   ├── outlines/           # 教学大纲
│   ├── chapters/           # 章节内容
│   └── notes/              # 学习笔记
└── logs/                    # 日志文件 (待创建)
```

## 开发指南

### 开发流程

1. **规范化**: 使用 `.specify/templates/` 中的模板创建功能规范
2. **测试先行**: 编写测试 → 验证失败 → 用户审批 → 实现功能
3. **代码质量**: 遵循 AI-Aware 原则,保持代码清晰、类型安全
4. **宪章检查**: 每个功能必须通过宪章合规性检查

### 命令参考

功能规范相关命令(通过 `.github/prompts/` 中的 prompt 文件):

- `speckit.constitution.prompt.md`: 更新项目宪章
- `speckit.specify.prompt.md`: 创建功能规范
- `speckit.plan.prompt.md`: 生成实现计划
- `speckit.tasks.prompt.md`: 分解任务列表
- `speckit.implement.prompt.md`: 执行实现

### 贡献指南

1. 所有 PR 必须通过自动化测试(单元测试 + 集成测试)
2. 代码覆盖率不得低于 80%
3. 核心逻辑变更需要至少一名同行评审
4. 必须验证宪章合规性(参考 PR 模板检查清单)

## 技术栈

- **语言**: Python 3.11+
- **CLI 框架**: Click / Typer (待定)
- **AI 集成**: OpenAI API / Claude API
- **存储**: Markdown 文件 + YAML 元数据
- **测试**: pytest
- **日志**: Python logging 模块

## 路线图

### MVP (v0.1.0) - P1 功能
- [ ] 教材解析(Markdown/纯文本)
- [ ] 教学大纲生成
- [ ] 基础对话式教学
- [ ] 进度跟踪

### v0.2.0 - P2 功能
- [ ] 自动搜索补充材料
- [ ] 图片引用支持
- [ ] 文本标记和笔记管理

### v0.3.0 - P3 功能
- [ ] 自定义教学节奏
- [ ] 多种教学模式
- [ ] 学习分析和报告

## 许可证

(待定)

## 联系方式

(待定)

---

**项目宪章版本**: 1.0.0 | **最后更新**: 2025-10-21

查看完整的项目原则和治理规则,请参考 [.specify/memory/constitution.md](.specify/memory/constitution.md)
