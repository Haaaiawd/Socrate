# 品牌重命名建议：TeacherKit → TeachKit

**日期**: 2025-10-28  
**状态**: 提案讨论中

---

## 📊 名称对比

| 指标 | TeacherKit | TeachKit | 优胜者 |
|------|-----------|----------|-------|
| **音节数** | 5 (Tea-cher-Kit) | 3 (Teach-Kit) | **TeachKit** ✅ |
| **字符数** | 10 | 8 | **TeachKit** ✅ |
| **发音** | Teacher-Kit | Teach-Kit | **TeachKit** ✅ (更流畅) |
| **品牌感** | 强调"教师" | 强调"教学" | **TeachKit** ✅ (更现代) |
| **输入速度** | 慢 | 快 | **TeachKit** ✅ |
| **记忆性** | 一般 | 好 | **TeachKit** ✅ |
| **国际化** | Teacher 更口语化 | Teach 更专业 | **TeachKit** ✅ |

---

## 🎯 推荐方案：TeachKit

### 优势分析

1. **更简洁**
   - 8 字符 vs 10 字符
   - 命令输入更快：`teachkit init` vs `teacherkit init`

2. **更现代**
   - 类似成功品牌：DevKit, TestKit, ToolKit
   - "Kit" 暗示工具集，符合产品定位

3. **更专业**
   - "Teach" 动词形式，强调行动
   - "Teacher" 名词形式，过于具象

4. **更易推广**
   - 短域名更容易获取：teachkit.dev
   - Twitter/GitHub handle 更短

---

## 🚀 迁移计划

### Phase 1: 包名重命名（影响最大）

**需要修改的文件**:
```
pyproject.toml
├── name: "teacherkit" → "teachkit"
├── [project.scripts]
│   └── teacherkit → teachkit
└── packages: ["src/teacherkit_cli"] → ["src/teachkit_cli"]

目录重命名:
src/teacherkit_cli/ → src/teachkit_cli/
```

**影响**:
- ✅ 用户需要卸载旧包：`pip uninstall teacherkit`
- ✅ 重新安装新包：`pip install teachkit`
- ⚠️ 已有项目仍可使用旧命令（旧包存在）

---

### Phase 2: Prompt 文件重命名

**需要修改的文件**:
```
.github/prompts/
├── teacherkit.outline.prompt.md → teachkit.outline.prompt.md
├── teacherkit.prepare.prompt.md → teachkit.prepare.prompt.md
├── teacherkit.practice.prompt.md → teachkit.practice.prompt.md
├── teacherkit.lesson.prompt.md → teachkit.lesson.prompt.md
└── teacherkit.check.prompt.md → teachkit.check.prompt.md
```

**影响**:
- ✅ VS Code Copilot 会自动识别新文件名
- ✅ 用户输入：`/teachkit.outline` 代替 `/teacherkit.outline`
- ⚠️ 已有项目需要运行 `teachkit update` 更新

---

### Phase 3: 文档和配置更新

**需要修改的文件**:
```
README.md - 所有 teacherkit 引用
pyproject.toml - 描述文本
__init__.py - 包文档字符串
init.py - ASCII Logo
所有 .md 文档
```

---

## 📋 详细迁移步骤

### Step 1: 重命名 Python 包目录

```bash
# 重命名主包目录
mv src/teacherkit_cli src/teachkit_cli

# 更新所有导入语句
find src/teachkit_cli -type f -name "*.py" -exec sed -i 's/teacherkit_cli/teachkit_cli/g' {} +
```

---

### Step 2: 更新 pyproject.toml

```toml
[project]
name = "teachkit"  # 改名
version = "0.2.0"  # 版本号升级
description = "AI-powered Socratic teaching toolkit"  # 描述优化

[project.scripts]
teachkit = "teachkit_cli:cli_main"  # 命令名改为 teachkit

[tool.hatch.build.targets.wheel]
packages = ["src/teachkit_cli"]  # 包路径更新
```

---

### Step 3: 重命名 Prompt 文件

```bash
cd .github/prompts
mv teacherkit.outline.prompt.md teachkit.outline.prompt.md
mv teacherkit.prepare.prompt.md teachkit.prepare.prompt.md
mv teacherkit.practice.prompt.md teachkit.practice.prompt.md
mv teacherkit.lesson.prompt.md teachkit.lesson.prompt.md
mv teacherkit.check.prompt.md teachkit.check.prompt.md
```

---

### Step 4: 更新文档引用

**README.md**:
```bash
# 替换所有引用
sed -i 's/teacherkit/teachkit/g' README.md
sed -i 's/TeacherKit/TeachKit/g' README.md
```

**其他文档**:
```bash
find . -name "*.md" -exec sed -i 's/teacherkit/teachkit/g' {} +
find . -name "*.md" -exec sed -i 's/TeacherKit/TeachKit/g' {} +
```

---

### Step 5: 更新 ASCII Logo

**src/teachkit_cli/commands/init.py**:
```python
def _print_logo():
    """Print TeachKit ASCII logo"""
    logo = r"""
    ╔════════════════════════════════════════════════════╗
    ║                                                    ║
    ║   ████████╗███████╗ █████╗  ██████╗██╗  ██╗       ║
    ║   ╚══██╔══╝██╔════╝██╔══██╗██╔════╝██║  ██║       ║
    ║      ██║   █████╗  ███████║██║     ███████║       ║
    ║      ██║   ██╔══╝  ██╔══██║██║     ██╔══██║       ║
    ║      ██║   ███████╗██║  ██║╚██████╗██║  ██║       ║
    ║      ╚═╝   ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝       ║
    ║                                                    ║
    ║   ██╗  ██╗██╗████████╗                            ║
    ║   ██║ ██╔╝██║╚══██╔══╝                            ║
    ║   █████╔╝ ██║   ██║                               ║
    ║   ██╔═██╗ ██║   ██║                               ║
    ║   ██║  ██╗██║   ██║                               ║
    ║   ╚═╝  ╚═╝╚═╝   ╚═╝                               ║
    ║                                                    ║
    ║        AI-Powered Socratic Teaching Toolkit       ║
    ║                   Version 0.2.0                   ║
    ║                                                    ║
    ╚════════════════════════════════════════════════════╝
    """
    console.print(logo, style="bold cyan", highlight=False)
```

---

### Step 6: 发布迁移指南

**MIGRATION.md**:
```markdown
# Migrating from TeacherKit to TeachKit

## For New Users
Just install the new package:
```bash
pip install teachkit
teachkit init my-project
```

## For Existing Users

### Option 1: Clean Install (Recommended)
```bash
# Uninstall old package
pip uninstall teacherkit

# Install new package
pip install teachkit

# Update existing projects
cd your-project
teachkit update
```

### Option 2: Side-by-Side (Transition Period)
```bash
# Keep old package for old projects
pip install teachkit

# New projects use: teachkit init
# Old projects can still use: teacherkit init
```

## Command Changes
| Old Command | New Command |
|------------|-------------|
| `teacherkit init` | `teachkit init` |
| `teacherkit update` | `teachkit update` |
| `/teacherkit.outline` | `/teachkit.outline` |
| `/teacherkit.prepare` | `/teachkit.prepare` |
| `/teacherkit.practice` | `/teachkit.practice` |
| `/teacherkit.lesson` | `/teachkit.lesson` |
```

---

## ⚠️ 风险评估

### 高风险
1. **已有用户需要迁移**
   - 影响：所有现有用户
   - 缓解：提供详细迁移指南 + 保留旧包 1-2 个版本

2. **文档链接失效**
   - 影响：外部引用
   - 缓解：GitHub 重定向 + 保留旧文档

### 中风险
3. **教程视频过时**
   - 影响：已发布内容
   - 缓解：添加迁移说明视频

4. **搜索引擎优化**
   - 影响：SEO 排名
   - 缓解：301 重定向 + 新域名优化

### 低风险
5. **代码引用**
   - 影响：开发者
   - 缓解：保持向后兼容 API

---

## 🎯 推荐执行策略

### 方案 A: 渐进式迁移（推荐）

**Timeline**:
- **Week 1-2**: 发布 teachkit 0.2.0（新包名）
- **Week 3-4**: 同时维护 teacherkit 0.1.x（旧包）
- **Week 5-8**: 标记 teacherkit 为 deprecated
- **Week 9+**: 停止更新 teacherkit，仅维护 teachkit

**优势**:
- ✅ 用户有时间迁移
- ✅ 不会破坏现有项目
- ✅ 风险可控

---

### 方案 B: 一次性迁移（激进）

**Timeline**:
- **Day 1**: 发布 teachkit 0.2.0，废弃 teacherkit
- **Day 2**: 删除旧包，仅保留新包

**优势**:
- ✅ 快速切换
- ✅ 避免维护两套代码

**劣势**:
- ❌ 用户体验差
- ❌ 可能流失用户

---

## 💡 最终建议

**推荐**: 采用 **方案 A - 渐进式迁移**

1. **立即执行**:
   - 创建 teachkit 新包（0.2.0）
   - 保留 teacherkit 旧包（标记 deprecated）
   - 更新文档和教程

2. **1 个月后**:
   - 停止更新 teacherkit
   - 所有新功能仅在 teachkit 发布

3. **3 个月后**:
   - 完全停止支持 teacherkit
   - 删除旧包（PyPI 仍可安装历史版本）

---

## 📊 用户沟通计划

### 发布公告
```markdown
# 🎉 TeacherKit → TeachKit: A Better Name for a Better Tool

We're excited to announce our rebranding to **TeachKit**!

**Why the change?**
- Shorter, faster, more memorable
- Better aligns with modern toolkit naming conventions
- Easier to type and share

**What you need to do:**
1. Uninstall old package: `pip uninstall teacherkit`
2. Install new package: `pip install teachkit`
3. Update your projects: `teachkit update`

**Timeline:**
- Now: Both packages available
- 1 month: teacherkit deprecated
- 3 months: teacherkit support ends

Questions? See our [Migration Guide](MIGRATION.md)
```

---

## ✅ 执行检查清单

- [ ] 重命名包目录：`src/teacherkit_cli` → `src/teachkit_cli`
- [ ] 更新 `pyproject.toml`
- [ ] 重命名所有 prompt 文件
- [ ] 更新 ASCII Logo
- [ ] 更新所有文档（README, guides, etc.）
- [ ] 创建 MIGRATION.md
- [ ] 发布 teachkit 0.2.0 到 PyPI
- [ ] 标记 teacherkit 为 deprecated
- [ ] 发布迁移公告
- [ ] 更新 GitHub repository 名称
- [ ] 设置重定向链接
- [ ] 通知现有用户

---

## 🤔 需要决定的问题

1. **是否立即执行？**
   - 建议：是，趁用户量还小时改名成本最低

2. **保留旧包多久？**
   - 建议：3 个月过渡期

3. **版本号策略？**
   - 建议：0.2.0（minor bump，表示重要变化）

4. **域名购买？**
   - 建议：注册 teachkit.dev 或 teachkit.io

---

**最终结论**: 建议采用 **TeachKit** 作为新品牌名，使用渐进式迁移策略，预计 3 个月完成过渡。
