# Contract: `/teacherkit.practice` Command

**Command**: `/teacherkit.practice`  
**Phase**: 3 - Practice Exercise Generation  
**Status**: Required  
**Purpose**: Generate practice code files with TODO markers, test cases, and hints for hands-on learning

---

## 职责边界 (Responsibility Boundaries)

### 本命令负责 (This Command Handles)

1. **练习位置识别** (Exercise Position Identification)
   - 分析知识点序列,识别适合插入练习的位置
   - 规则: 每2-3个相关知识点后安排1个练习
   - 特殊处理: 复习阶段的综合练习(结合多个知识点)

2. **练习代码生成** (Practice Code Generation)
   - 创建Python文件(MVP语言)
   - 包含函数签名、TODO标记、测试用例、提示注释
   - 难度适配: 单一概念练习 vs 综合应用练习

3. **文件自动保存** (Automatic File Saving)
   - 使用AI平台的 `create_file` 工具
   - 保存到 `data/exercises/` 目录
   - 文件命名: `practice-[topic]-[number].py`

4. **练习元数据记录** (Exercise Metadata Recording)
   - 生成 `data/exercises/exercises-meta.md`
   - 记录每个练习的知识点关联、难度、预计时长

### 本命令不负责 (Out of Scope)

- ❌ 开始教学对话(交由 `/teacherkit.lesson`)
- ❌ 执行或测试学生代码(学生自行运行)
- ❌ 评估练习完成质量(交由 `/teacherkit.lesson` 的对话阶段)

---

## 输入约定 (Input Contract)

### 前置条件 (Prerequisites)

**必须**: 已执行 `/teacherkit.outline` 和 `/teacherkit.prepare`

**触发**: 用户输入 `/teacherkit.practice`

**自动读取**:
- `data/outlines/[latest]-outline.md` (获取复习阶段的综合练习需求)
- `data/chapters/[latest]-prepared.md` (获取知识点列表和代码示例)

### 输入验证 (Input Validation)

| 场景 | 验证规则 | 失败处理 |
|------|---------|---------|
| 无准备文件 | 检查 `data/chapters/` 是否有文件 | 提示: "请先执行 `/teacherkit.prepare`" |
| 非编程主题 | 检测知识点类型(代码示例数量) | 提示: "当前主题无需代码练习" |

---

## 处理流程 (Processing Flow)

### 阶段1: 练习需求分析 (Exercise Requirement Analysis)

**步骤**:

1. **知识点分组** (Knowledge Point Grouping)
   - 读取知识点列表
   - 按逻辑相关性分组(如"循环基础"组: for循环 + range函数)
   - 每组2-3个知识点

2. **练习位置规划** (Exercise Position Planning)
   - 每组知识点后插入1个练习
   - 复习阶段单独安排综合练习(2-3个)
   - 总练习数: 单一概念练习(n组) + 综合练习(2-3个)

**示例**:
```
知识点序列:
- KP1: for循环基础
- KP2: range函数
- KP3: 循环控制(break/continue)
- KP4: 嵌套循环
- KP5: 列表推导式

分组与练习位置:
[组1: KP1, KP2] → 练习1: 基础循环遍历
[组2: KP3] → 练习2: 循环控制应用
[组3: KP4] → 练习3: 二维数据处理(嵌套循环)
[组4: KP5] → 练习4: 列表推导式转换

复习阶段:
[KP1-KP5] → 综合练习1: 数据统计任务
[KP1-KP5] → 综合练习2: 文件处理任务(进阶)
```

**输出**: 练习位置列表(每个练习关联哪些知识点)

### 阶段2: 练习难度设计 (Exercise Difficulty Design)

**难度级别**:

- **Level 1: 概念验证** (Concept Verification)
  - 目标: 验证学生理解单一概念
  - 复杂度: 3-5行代码,1个函数
  - 提示: 详细(注释中说明思路)

- **Level 2: 概念组合** (Concept Combination)
  - 目标: 结合2-3个相关概念
  - 复杂度: 10-15行代码,2-3个函数
  - 提示: 中等(关键步骤提示)

- **Level 3: 实战应用** (Practical Application)
  - 目标: 真实场景问题(复习阶段)
  - 复杂度: 20-30行代码,完整小程序
  - 提示: 少(仅大方向提示)

**映射**:
- 单一概念练习 → Level 1 或 Level 2
- 综合练习(复习阶段) → Level 3

**输出**: 每个练习的难度级别

### 阶段3: 练习代码生成 (Code Generation)

**代码结构模板**:

```python
"""
练习: [练习名称]
难度: ⭐⭐☆☆☆ (Level 2)
预计时长: 15分钟

知识点:
- [知识点1]
- [知识点2]

任务描述:
[清晰描述要完成的任务]

示例:
输入: [示例输入]
输出: [示例输出]
"""

# ========== 提示与思路 ==========
# TODO: 请完成以下函数
# 提示1: [概念性提示]
# 提示2: [具体步骤提示]
# ========== 提示结束 ==========


# ========== START CODE ==========
def function_name(param1, param2):
    """
    函数说明: [简短描述]
    
    参数:
        param1: [参数说明]
        param2: [参数说明]
    
    返回:
        [返回值说明]
    """
    # TODO: 在这里编写你的代码
    pass  # 删除这行,开始编写代码
# ========== END CODE ==========


# ========== 测试用例 ==========
# 不要修改测试用例,完成函数后运行此文件即可测试

def test_function_name():
    """测试用例"""
    # 测试1: [测试场景描述]
    assert function_name(input1, input2) == expected_output1, "测试1失败"
    
    # 测试2: [测试场景描述]
    assert function_name(input3, input4) == expected_output2, "测试2失败"
    
    # 测试3: [边界情况]
    assert function_name(edge_case) == edge_output, "测试3失败"
    
    print("✅ 所有测试通过!做得好!")


if __name__ == "__main__":
    test_function_name()
# ========== 测试结束 ==========
```

**生成策略**:

1. **任务描述** (Task Description)
   - 清晰说明要完成什么
   - 提供输入输出示例
   - 说明成功标准

2. **函数签名** (Function Signature)
   - 函数名清晰反映任务(如 `calculate_average`, `filter_even_numbers`)
   - 参数名自解释(如 `numbers_list`, `threshold`)
   - 包含docstring(参数和返回值说明)

3. **TODO标记** (TODO Markers)
   - `# TODO:` 标记需要填充的部分
   - `pass` 占位(学生需删除)
   - `START CODE` / `END CODE` 明确边界

4. **提示系统** (Hint System)
   - 提示1: 概念性(如"考虑使用for循环遍历列表")
   - 提示2: 具体步骤(如"步骤1: 初始化计数器; 步骤2: 遍历...")
   - 提示3(可选): 伪代码(如"for each item: if condition: ...")

5. **测试用例** (Test Cases)
   - 至少3个测试(基础场景、复杂场景、边界情况)
   - 使用 `assert` 语句(简单清晰)
   - 测试失败时有明确提示信息

**输出**: 完整的Python练习文件内容

### 阶段4: 综合练习生成 (Integrated Exercise Generation)

**复习阶段的综合练习特点**:

1. **真实场景模拟** (Real-World Scenarios)
   - 不是单纯的算法题
   - 接近实际应用(数据处理、文件操作、小工具开发)

2. **多知识点整合** (Multi-Concept Integration)
   - 结合3-5个已学知识点
   - 自然整合(而非强行拼凑)

3. **开放式设计** (Open-Ended Design)
   - 不提供详细步骤
   - 鼓励学生自行设计解决方案
   - 可有多种正确实现方式

4. **扩展挑战** (Extension Challenges)
   - 基础任务 + 可选扩展
   - 扩展部分更具挑战性

**示例: 综合练习**:
```python
"""
综合练习: 学生成绩管理系统
难度: ⭐⭐⭐⭐☆ (Level 3 - 综合应用)
预计时长: 45分钟

知识点:
- for循环遍历
- 条件判断
- 列表操作
- 字典使用
- 函数定义

任务描述:
开发一个简单的学生成绩管理系统,实现以下功能:
1. 计算班级平均分
2. 找出最高分和最低分
3. 统计各分数段人数(优秀>=90, 良好80-89, 及格60-79, 不及格<60)
4. 生成成绩报告

数据格式:
students = [
    {"name": "Alice", "score": 85},
    {"name": "Bob", "score": 92},
    {"name": "Charlie", "score": 78},
    # ... 更多学生
]

示例输出:
班级平均分: 85.3
最高分: 92 (Bob)
最低分: 78 (Charlie)
优秀: 1人
良好: 1人
及格: 1人
不及格: 0人
"""

# ========== 提示 ==========
# 这是一个综合任务,请自行设计解决方案
# 建议步骤:
# 1. 先实现计算平均分的函数
# 2. 再实现查找最高/最低分的函数
# 3. 最后实现统计分数段的函数
# 4. 用一个主函数整合所有功能

# 提示: 可以创建多个辅助函数,不必全写在一个函数里
# ========== 提示结束 ==========


# ========== START CODE ==========
def calculate_class_average(students):
    """计算班级平均分"""
    # TODO: 实现平均分计算
    pass


def find_top_student(students):
    """找出最高分学生"""
    # TODO: 实现最高分查找
    pass


def find_lowest_student(students):
    """找出最低分学生"""
    # TODO: 实现最低分查找
    pass


def count_score_ranges(students):
    """统计各分数段人数"""
    # TODO: 实现分数段统计
    # 返回字典: {"优秀": x, "良好": y, "及格": z, "不及格": w}
    pass


def generate_report(students):
    """生成完整成绩报告"""
    # TODO: 整合所有功能,打印报告
    pass
# ========== END CODE ==========


# ========== 测试数据 ==========
test_students = [
    {"name": "Alice", "score": 85},
    {"name": "Bob", "score": 92},
    {"name": "Charlie", "score": 78},
    {"name": "David", "score": 95},
    {"name": "Eve", "score": 88},
]

# 运行报告生成
if __name__ == "__main__":
    generate_report(test_students)
    
    # 期望输出类似:
    # 班级平均分: 87.6
    # 最高分: 95 (David)
    # 最低分: 78 (Charlie)
    # 优秀: 2人
    # 良好: 2人
    # 及格: 1人
    # 不及格: 0人
# ========== 测试结束 ==========


# ========== 扩展挑战(可选) ==========
# 如果你完成了基础任务,可以尝试:
# 1. 增加"按成绩排序"功能
# 2. 增加"查找特定学生"功能
# 3. 增加"数据可视化"(打印简单柱状图)
# ========== 扩展结束 ==========
```

**输出**: 综合练习文件内容

### 阶段5: 文件保存与元数据记录 (File Saving & Metadata)

**步骤**:

1. **创建练习文件** (Create Exercise Files)
   - 使用AI平台的 `create_file` 工具
   - 文件命名: `data/exercises/practice-[topic]-[number].py`
   - 确保 `data/exercises/` 目录存在

2. **生成元数据文件** (Generate Metadata File)
   - 创建 `data/exercises/exercises-meta.md`
   - 记录所有练习的信息

**元数据格式**:
```markdown
---
topic: "[主题名称]"
created: "2025-10-22"
total_exercises: 6
difficulty_distribution:
  level1: 2
  level2: 2
  level3: 2
---

# 练习清单: [主题名称]

## 单一概念练习 (Single-Concept Exercises)

### 练习1: 基础循环遍历
- **文件**: `practice-loops-1.py`
- **知识点**: for循环基础, range函数
- **难度**: ⭐⭐☆☆☆ (Level 2)
- **预计时长**: 15分钟
- **任务**: 遍历数字列表并计算总和
- **提示数量**: 2个

---

### 练习2: 循环控制应用
- **文件**: `practice-loops-2.py`
- **知识点**: break, continue
- **难度**: ⭐⭐☆☆☆ (Level 2)
- **预计时长**: 20分钟
- **任务**: 查找列表中第一个满足条件的元素
- **提示数量**: 3个

---

[更多练习...]

---

## 综合练习 (Integrated Exercises)

### 综合练习1: 数据统计任务
- **文件**: `practice-review-1.py`
- **知识点**: for循环, 条件判断, 列表操作, 函数定义
- **难度**: ⭐⭐⭐⭐☆ (Level 3)
- **预计时长**: 45分钟
- **任务**: 学生成绩管理系统
- **提示数量**: 1个(大方向提示)
- **扩展挑战**: 有(排序、查找、可视化)

---

### 综合练习2: 文件处理任务(进阶)
- **文件**: `practice-review-2.py`
- **知识点**: for循环, 字符串操作, 文件读取, 列表推导式
- **难度**: ⭐⭐⭐⭐⭐ (Level 3+)
- **预计时长**: 60分钟
- **任务**: 日志文件分析工具
- **提示数量**: 1个
- **扩展挑战**: 有(正则表达式、异常处理)

---

## 学习建议 (Study Tips)

1. **按顺序完成**: 先完成单一概念练习,再挑战综合练习
2. **先思考再编码**: 理解任务后,先在纸上规划步骤
3. **善用提示**: 卡住时先看提示1(概念性),再看提示2(步骤)
4. **测试驱动**: 每完成一部分就运行测试,及时发现问题
5. **对比示例**: 完成后对比"知识点准备"中的示例,学习更优写法
6. **扩展挑战**: 基础任务完成后,尝试扩展挑战提升能力

---

## 下一步 (Next Steps)

完成练习生成后:
1. **开始教学对话**: `/teacherkit.lesson` - AI将引导你逐个学习知识点
2. **在对话中**: AI会在适当时机提醒你完成对应练习
3. **提交练习**: 完成后附加代码文件,AI会提供反馈
```

**输出**: 元数据文件内容

---

## 输出约定 (Output Contract)

### 用户交互输出

**AI输出**(控制台):
```
✅ 练习文件生成完成!

📁 练习目录: `data/exercises/`

📊 练习概览:
- 总练习数: 6个
- 单一概念练习: 4个(Level 1-2)
- 综合练习: 2个(Level 3)
- 预计总时长: ~3小时

📚 练习清单:
1. practice-loops-1.py - 基础循环遍历 (15分钟)
   知识点: for循环, range函数
   
2. practice-loops-2.py - 循环控制应用 (20分钟)
   知识点: break, continue
   
3. practice-loops-3.py - 二维数据处理 (25分钟)
   知识点: 嵌套循环
   
4. practice-loops-4.py - 列表推导式转换 (20分钟)
   知识点: 列表推导式

📌 复习阶段综合练习:
5. practice-review-1.py - 学生成绩管理系统 (45分钟)
   整合: for循环 + 条件判断 + 列表/字典操作
   挑战: ⭐⭐⭐⭐☆
   
6. practice-review-2.py - 日志文件分析工具 (60分钟)
   整合: 循环 + 字符串 + 文件操作 + 推导式
   挑战: ⭐⭐⭐⭐⭐

📄 详细信息: 查看 `data/exercises/exercises-meta.md`

🚀 下一步:
执行 `/teacherkit.lesson` 开始教学对话
AI会在适当时机提醒你完成对应练习
```

---

## 异常场景处理 (Exception Handling)

### 场景1: 无准备文件
```
❌ 未找到知识点准备文件

请先执行:
1. `/teacherkit.outline` - 生成学习大纲
2. `/teacherkit.prepare` - 准备知识点内容
3. `/teacherkit.practice` - 生成练习(当前步骤)

需要帮助吗?
```

### 场景2: 非编程主题
```
ℹ️ 当前主题无需代码练习

检测到学习主题为"[非编程主题]",无法生成代码练习。

建议:
- 直接执行 `/teacherkit.lesson` 开始理论学习
- 或在对话中完成思考题/讨论题(非代码练习)
```

### 场景3: 文件创建失败
```
❌ 练习文件创建失败

原因: AI平台文件创建权限不足或目录不存在

解决方案:
1. 确保 `data/exercises/` 目录存在
2. 检查AI平台文件操作权限
3. 或手动创建目录后重试
```

---

## 质量标准 (Quality Standards)

### 练习任务质量

- **任务清晰**: 任务描述明确,学生知道要完成什么
- **示例充分**: 提供输入输出示例,学生理解期望结果
- **难度适中**: Level 1-2适合初学者,Level 3有挑战但可完成

### 代码结构质量

- **函数签名清晰**: 函数名和参数名自解释
- **TODO明确**: 清楚标记需要填充的部分
- **提示有效**: 提示能引导学生,但不直接给答案

### 测试用例质量

- **覆盖完整**: 基础场景、复杂场景、边界情况
- **失败提示清晰**: 测试失败时,学生知道哪里出错
- **易于运行**: 直接运行文件即可测试

---

## 技术实现细节 (Technical Implementation)

### 练习位置算法

```python
def plan_exercise_positions(knowledge_points):
    groups = []
    current_group = []
    
    for kp in knowledge_points:
        current_group.append(kp)
        if len(current_group) == 2 or kp.is_milestone:
            groups.append(current_group)
            current_group = []
    
    # 每组后插入练习
    exercises = []
    for i, group in enumerate(groups):
        ex = {
            "id": f"practice-{i+1}",
            "knowledge_points": [kp.id for kp in group],
            "difficulty": determine_difficulty(group)
        }
        exercises.append(ex)
    
    return exercises
```

### 文件生成

**工具**: AI平台的 `create_file` API

```python
for exercise in exercises:
    file_path = f"data/exercises/{exercise['id']}.py"
    content = generate_exercise_code(exercise)
    create_file(file_path, content)
```

---

## 与其他命令的协作 (Command Integration)

### 输入 ← `/teacherkit.outline` 的输出

**读取内容**:
- 复习阶段的综合练习需求
- 知识点总数(评估练习数量)

### 输入 ← `/teacherkit.prepare` 的输出

**读取内容**:
- 知识点列表和代码示例(作为练习模板参考)
- 知识点分组(逻辑相关性)

### 输出 → `/teacherkit.lesson` 的输入

**传递内容**:
- 练习文件路径列表
- 练习与知识点的映射(何时触发练习提醒)

---

## 测试验收场景 (Acceptance Tests)

### 测试1: 基础练习生成

**Given**: 准备文件包含5个知识点  
**When**: 执行 `/teacherkit.practice`  
**Then**:
- ✅ 生成4个单一概念练习文件
- ✅ 生成2个综合练习文件(复习阶段)
- ✅ 每个文件包含: 任务描述、函数签名、TODO标记、测试用例
- ✅ 生成 `exercises-meta.md` 元数据文件

### 测试2: 代码可运行性

**Given**: 生成的练习文件  
**When**: 不填充TODO,直接运行  
**Then**:
- ✅ 无语法错误
- ✅ 测试失败(因为未实现功能)
- ✅ 失败提示清晰

### 测试3: 提示有效性

**Given**: 练习文件中的提示  
**When**: 学生阅读提示  
**Then**:
- ✅ 提示1: 概念性,学生理解要用什么知识点
- ✅ 提示2: 步骤性,学生知道大致流程
- ✅ 提示不直接给出代码

### 测试4: 非编程主题处理

**Given**: 主题为"历史"(无代码示例)  
**When**: 执行 `/teacherkit.practice`  
**Then**:
- ✅ 提示: "当前主题无需代码练习"
- ✅ 建议直接进入 `/teacherkit.lesson`

---

## 边界案例处理 (Edge Cases)

### 案例1: 知识点过少

**场景**: 仅2个知识点  
**处理**:
- 生成1个单一概念练习 + 1个综合练习
- 综合练习难度降低(Level 2)

### 案例2: 知识点过多

**场景**: 30个知识点  
**处理**:
- 分批生成(每次10个知识点的练习)
- 或生成10-12个练习(每个练习覆盖2-3个KP)

### 案例3: 纯理论知识点

**场景**: 某些知识点无代码示例(如"算法思想")  
**处理**:
- 跳过该知识点的单独练习
- 在综合练习中以"设计题"形式出现

---

## 性能要求 (Performance Requirements)

- **需求分析**: < 10秒
- **代码生成**: < 30秒(6个练习)
- **文件写入**: < 10秒
- **总耗时**: < 60秒(典型场景)

---

## 版本历史 (Version History)

- **v1.0** (2025-10-22): 初版,支持单一概念练习和综合练习生成,Python语言,MVP功能
