# TeacherKit - AI-Powered Socratic Teaching Assistant

> **Transform any programming resource into personalized, interactive lessons with the power of AI.**

TeacherKit is a **prompt-first** AI teaching assistant that uses Socratic dialogue to guide you through programming concepts at your own pace. Unlike traditional tutorials, it doesn't just explain—it **asks you questions** to help you discover answers yourself.

---

## ✨ What Makes TeacherKit Special?

### 🧠 Socratic Teaching Method
- **Question-driven learning**: Instead of lectures, you'll answer carefully crafted questions that guide you to understanding
- **3-layer questioning**: Conceptual understanding → Principle exploration → Real-world application
- **Adaptive dialogue**: The AI adjusts based on your responses

### 📚 Flexible Learning Modes
- **File-based learning**: Attach a textbook, PDF, or Markdown file → instant structured lesson plan
- **Topic-based learning**: Just describe what you want to learn → AI creates a custom outline
- **Progress tracking**: Pick up exactly where you left off, even days later

### 🏋️ Hands-On Practice
- **Auto-generated exercises**: Practice problems appear naturally after every 2-3 concepts
- **TODO-driven coding**: Fill in the blanks with guidance, not frustration
- **Socratic code review**: When you submit code, the AI asks diagnostic questions instead of giving corrections

### 📊 Seamless Session Management
- **Automatic progress saving**: After every concept, every exercise, no manual saves needed
- **Smart resumption**: Return after a break → choose to continue, get a recap, or start fresh
- **Proactive checkpoints**: Gentle reminders to take breaks after 1 hour of learning

---

## � Quick Start

### Prerequisites

1. **Python 3.11+** installed ([download here](https://www.python.org/downloads/))
2. **An AI coding assistant** (one of):
   - [GitHub Copilot](https://github.com/features/copilot) in VS Code
   - [Cursor](https://cursor.sh/)
   - [Claude Code](https://claude.ai/) (via API)
3. **File attachment support** in your AI platform (for file-based learning)

### Installation

```bash
# Install TeacherKit CLI using uv (recommended)
uv tool install teacherkit

# Or using pip
pip install teacherkit
```

### Initialize Your Learning Project

```bash
# Create a new learning workspace
teacherkit init my-python-journey

# This creates:
# my-python-journey/
#   .github/prompts/          ← AI prompt templates
#   data/
#     outlines/               ← Generated lesson plans
#     chapters/               ← Prepared knowledge points
#     exercises/              ← Practice code files
#     progress.md             ← Your learning journey
```

---

## 📖 How to Use TeacherKit

### Scenario 1: Learning from a File (Textbook, PDF, Markdown)

**Step 1**: Attach your file to the AI chat
```
[Attach: python-fundamentals.pdf]
```

**Step 2**: Generate an outline
```
/teacherkit.outline
```

**AI Response**:
```
📚 I've analyzed your textbook! Here's your learning plan:

Chapter 1: Python Basics (3-4 hours)
├── 1.1 Variables and Data Types (30 min)
│   ├── KP-1.1.1: Variable assignment and naming
│   ├── KP-1.1.2: Numeric types (int, float)
│   └── KP-1.1.3: String operations
└── 1.2 Control Flow (45 min)
    └── ... [more]

Saved to: data/outlines/python-fundamentals-outline.md
Ready to start? Run /teacherkit.prepare next!
```

**Step 3**: Prepare knowledge points
```
/teacherkit.prepare
```

**AI Response**:
```
✅ Prepared 18 knowledge points with:
- Core definitions
- Code examples
- Socratic questions (3 layers each)
- Analogies and comparison tables

Saved to: data/chapters/python-fundamentals-prepared.md
Let's begin! Run /teacherkit.lesson
```

**Step 4**: Start interactive learning
```
/teacherkit.lesson
```

**AI Response** (Socratic dialogue begins):
```
🎓 Welcome to your Python journey!

Today we'll explore: Variables and Data Types (30 min)

Let's start with a question:

Imagine you have a box where you can store things. In programming, 
we call this a "variable."

🤔 Question 1: If I told you I have a box labeled "age" and it 
contains the number 25, what do you think happens if I later put 
the number 30 in the same box?

(Take a moment to think, then share your answer!)
```

**Step 5**: Practice when offered
```
[After 2-3 concepts, AI says:]

Great progress! Time for hands-on practice.

I've created: data/exercises/practice-variables-01.ipynb

Open it in Jupyter/VS Code, fill in the TODOs, and run the cells!
```

**Example Exercise File** (Jupyter Notebook):
```python
# Cell 1 (Markdown)
# Practice: Variable Basics
# **Concepts**: Variables, Data Types, Reassignment
# **Difficulty**: Level 1
# **Estimated**: 10 minutes

# Cell 2 (Code)
# TODO 1: Create a variable 'name' and assign your name as a string

### START CODE HERE ###
name = None  # Replace this
### END CODE HERE ###

# Cell 3 (Code)
# TODO 2: Create a variable 'age' and assign your age as an integer

### START CODE HERE ###
age = None  # Replace this
### END CODE HERE ###

# Cell 4 (Code)
# Test cases (don't modify - run this cell to check your solution)
assert isinstance(name, str), "name should be a string"
assert isinstance(age, int), "age should be an integer"
print(f"✅ All tests passed! {name} is {age} years old.")
```

---

### Scenario 2: Learning from a Topic Description

**Step 1**: Describe what you want to learn
```
/teacherkit.outline "I want to understand Python list comprehensions"
```

**AI Response**:
```
📚 Custom Lesson Plan: List Comprehensions

**Difficulty**: Intermediate  
**Estimated Time**: 20-30 minutes

Topic 1: Foundations (10 min)
├── KP-1.1: Basic list operations review
├── KP-1.2: The concept of "comprehension"
└── KP-1.3: Syntax breakdown: [expression for item in iterable]

Topic 2: Practical Applications (15 min)
├── KP-2.1: Filtering with conditions
├── KP-2.2: Transforming data
└── KP-2.3: Nested comprehensions

[Rest of steps same as Scenario 1...]
```

---

### Scenario 3: Resuming After a Break

```
[Open chat, run:]
/teacherkit.lesson
```

**AI Response**:
```
🎓 Welcome Back!

**Last Session**: October 23, 2025 at 3:45 PM  
**Time Since Last Session**: 2 days

**Completed So Far**: 8 knowledge points (44% progress)
- KP-1.1.1: Variable assignment
- KP-1.1.2: Numeric types
- ... [recent KPs]

**Next Up**: KP-1.3.1: If/else statements

---

How would you like to proceed?

**Option A**: Continue from last position (jump right in)
**Option B**: Quick recap, then continue (5-min review)
**Option C**: Start fresh with a new topic

(Just say "A", "B", or "C"!)
```

---

## 🏗️ Architecture Overview

### Prompt-First Design

TeacherKit is **not a traditional CLI tool**. It's a collection of **AI prompt templates** that teach you through conversation:

```
CLI (One-Time Setup)          AI Prompts (The Real Teachers)
├── teacherkit init           ├── /teacherkit.outline
│   └── Sets up folders       │   └── Analyzes file/topic → creates lesson plan
└── teacherkit config         ├── /teacherkit.prepare
    └── Manages settings      │   └── Elaborates concepts → adds Socratic questions
                              ├── /teacherkit.practice
                              │   └── Generates Jupyter Notebook exercises
                              ├── /teacherkit.lesson
                              │   └── Interactive teaching dialogue
                              └── /teacherkit.check
                                  └── Quality validation (optional)
```

### PowerShell Automation Scripts

TeacherKit includes helper scripts in `.specify/scripts/powershell/`:

```powershell
# Quick template creation
Generate-Outline.ps1 -Topic "Python Basics"
Prepare-Chapters.ps1           # Check prerequisites before /teacherkit.prepare
Generate-Practice.ps1          # Check prerequisites before /teacherkit.practice

# Template copying (called by AI automatically)
Copy-Chapter-Template.ps1 -KpId "KP-1.1.1" -Title "Variables"
Copy-Practice-Template.ps1 -Slug "variables-basics"

# Progress tracking
Update-Progress.ps1 -KpId "KP-1.1.1" -Status "completed"
```

**Note**: Most scripts are called by AI automatically. You typically only run `Generate-Outline.ps1` manually.

### Data Storage

Everything is stored in **Markdown files** with YAML frontmatter:

```
data/
├── outlines/
│   └── [topic]-outline.md            # Learning plan with chapter structure
├── chapters/
│   └── Chapter*.md                   # Individual KP files (one per concept)
├── exercises/
│   ├── practice-[topic].ipynb        # Jupyter Notebook practice files
│   └── exercises-meta.md             # Exercise catalog
└── progress.md                       # Your learning progress (auto-saved)
```

**No database required!** All files are human-readable and editable.

---

## 🎯 Feature Highlights

### 📂 File Attachment Learning
- **Supported formats**: Markdown (`.md`), Plain text (`.txt`), PDF (`.pdf`)
- **File size**: Up to 50MB (larger files → chunking suggestions)
- **Multiple files**: Attach multiple chapters → unified lesson plan

### 💬 Topic-Based Learning
- **Broad topics**: "learn Python" → AI asks clarifying questions
- **Specific topics**: "list comprehensions" → focused 15-20 min lesson
- **Adaptive outlining**: AI adjusts depth based on your description

### 🏋️ Practice Exercises
- **Auto-positioned**: After every 2-3 knowledge points
- **3 difficulty levels**:
  - Level 1: 3-5 lines (fill-in-the-blank)
  - Level 2: 10-15 lines (guided problem-solving)
  - Level 3: 20-30 lines (comprehensive application)
- **Graduated hints**: Struggle? Get conceptual hints first, then specific ones
- **Socratic code review**: AI asks "Why did you choose this approach?" instead of "This is wrong"

### 📊 Progress Tracking
- **Automatic saves**: After every concept, exercise, or pause
- **Session resumption**: Choose to continue, recap, or start fresh
- **Proactive checkpoints**: Every 5 concepts → progress summary
- **Long break support**: Return after days → quick review offered

---

## 🤝 Contributing

### Modifying Prompt Templates

All teaching behavior is defined in `.github/prompts/`:

```
.github/prompts/
├── teacherkit.outline.prompt.md      # Lesson plan generation
├── teacherkit.prepare.prompt.md      # Knowledge point elaboration
├── teacherkit.lesson.prompt.md       # Socratic teaching dialogue (850+ lines!)
├── teacherkit.practice.prompt.md     # Exercise generation
└── teacherkit.check.prompt.md        # Quality validation
```

**To customize teaching style**:
1. Edit the relevant `.prompt.md` file
2. Re-run `teacherkit init` to copy updated prompts
3. Test with a new learning session

**No coding required!** Just modify the Markdown templates.

### Manual Testing

Since TeacherKit is AI-driven, testing requires real AI platforms:

1. **Install from source**:
   ```bash
   git clone https://github.com/yourusername/teacherkit.git
   cd teacherkit
   uv pip install -e .
   ```

2. **Run acceptance scenarios** (see `specs/002-simplify-teaching-flow/tasks.md` → T016):
   - Test file attachment → outline generation
   - Test topic description → outline generation
   - Test practice exercise workflow
   - Test session pause/resume
   - Test edge cases (large files, syntax errors, off-topic submissions)

3. **Check outputs**:
   - `data/outlines/` - Verify lesson plans have chapters/topics/KPs
   - `data/chapters/` - Verify Socratic questions present (3 layers)
   - `data/exercises/` - Verify TODO markers, test cases, hints
   - `data/progress.md` - Verify auto-save after each concept

---

## 📚 Additional Resources

- **Detailed Spec**: See `specs/002-simplify-teaching-flow/spec.md` for full behavior definitions
- **Command Contracts**: See `specs/002-simplify-teaching-flow/contracts/` for detailed command specs
- **Troubleshooting**: See `docs/troubleshooting.md` for common errors and solutions

---

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

Built with:
- [Typer](https://typer.tiangolo.com/) - Beautiful CLI framework
- [Rich](https://rich.readthedocs.io/) - Terminal formatting
- [OpenAI Principles](https://openai.com/) - Socratic teaching inspiration

Powered by your favorite AI coding assistant:
- GitHub Copilot
- Cursor
- Claude Code

---

**Ready to transform your learning?**

```bash
teacherkit init my-learning-journey
# Then attach a file or describe a topic + /teacherkit.outline
```

*Happy learning! 🎓✨*
