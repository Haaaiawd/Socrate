# 🏛️ Socrate# TeacherKit - AI-Powered Socratic Teaching Assistant



> **Learn Like Socrates Taught** – An AI-powered Socratic dialogue system for interactive learning> **Transform any programming resource into personalized, interactive lessons with the power of AI.**



Socrate is a CLI tool that transforms textbook content into interactive, question-driven learning experiences. Using the Socratic method, it guides students through concepts with thoughtful questions, real-time progress tracking, and hands-on practice exercises.TeacherKit is a **prompt-first** AI teaching assistant that uses Socratic dialogue to guide you through programming concepts at your own pace. Unlike traditional tutorials, it doesn't just explain—it **asks you questions** to help you discover answers yourself.



------



## ✨ Features## ✨ What Makes TeacherKit Special?



- 🎯 **Structured Learning Path**: Break down complex topics into digestible knowledge points (KPs)### 🧠 Socratic Teaching Method

- 💬 **Socratic Dialogue**: AI asks questions first, then provides explanations based on student responses- **Question-driven learning**: Instead of lectures, you'll answer carefully crafted questions that guide you to understanding

- 📚 **Automated Content Generation**: Parse textbooks into teaching-ready chapter files with questions and exercises- **3-layer questioning**: Conceptual understanding → Principle exploration → Real-world application

- 🧪 **Practice Notebooks**: Generate Jupyter notebook exercises with hints and solutions- **Adaptive dialogue**: The AI adjusts based on your responses

- 📊 **Progress Tracking**: Automatic session logs and completion tracking via PowerShell scripts

- 🤖 **VS Code Integration**: Five specialized GitHub Copilot prompts for each teaching phase### 📚 Flexible Learning Modes

- **File-based learning**: Attach a textbook, PDF, or Markdown file → instant structured lesson plan

---- **Topic-based learning**: Just describe what you want to learn → AI creates a custom outline

- **Progress tracking**: Pick up exactly where you left off, even days later

## 🚀 Quick Start

### 🏋️ Hands-On Practice

### Installation- **Auto-generated exercises**: Practice problems appear naturally after every 2-3 concepts

- **TODO-driven coding**: Fill in the blanks with guidance, not frustration

Install Socrate using [uv](https://github.com/astral-sh/uv):- **Socratic code review**: When you submit code, the AI asks diagnostic questions instead of giving corrections



```bash### 📊 Seamless Session Management

# Install uv (if not already installed)- **Automatic progress saving**: After every concept, every exercise, no manual saves needed

curl -LsSf https://astral.sh/uv/install.sh | sh- **Smart resumption**: Return after a break → choose to continue, get a recap, or start fresh

- **Proactive checkpoints**: Gentle reminders to take breaks after 1 hour of learning

# Install socrate

uv pip install socrate---

```

## � Quick Start

### Initialize a New Project

### Prerequisites

```bash

socrate init my-learning-project1. **Python 3.11+** installed ([download here](https://www.python.org/downloads/))

cd my-learning-project2. **An AI coding assistant** (one of):

```   - [GitHub Copilot](https://github.com/features/copilot) in VS Code

   - [Cursor](https://cursor.sh/)

This creates:   - [Claude Code](https://claude.ai/) (via API)

- `.github/prompts/` - Five core teaching prompts3. **File attachment support** in your AI platform (for file-based learning)

- `.specify/scripts/` - PowerShell progress tracking scripts

- `.vscode/settings.json` - Auto-approval settings for terminal commands### Installation

- `data/` directories for outlines, chapters, exercises

- `.gitignore` - Pre-configured for Socrate projects```bash

# Install TeacherKit CLI using uv (recommended)

---uv tool install teacherkit



## 📖 Usage# Or using pip

pip install teacherkit

### 1. Create an Outline```



Use the `socrate.outline` prompt in VS Code Copilot:### Initialize Your Learning Project



``````bash

@socrate.outline Create a learning outline for "Python Basics"# Create a new learning workspace

```teacherkit init my-python-journey



This generates `data/outlines/python-basics-outline.md` with structured knowledge points.# This creates:

# my-python-journey/

### 2. Prepare Chapter Files#   .github/prompts/          ← AI prompt templates

#   data/

Use the `socrate.prepare` prompt:#     outlines/               ← Generated lesson plans

#     chapters/               ← Prepared knowledge points

```#     exercises/              ← Practice code files

@socrate.prepare Convert the textbook in data/textbooks/sample-python-basics.md #     progress.md             ← Your learning journey

into chapter files following the outline```

```

---

This generates:

- `data/chapters/Chapter-1.1.md` (KP-1.1.1, KP-1.1.2, ...)## 📖 How to Use TeacherKit

- Each chapter includes: Core Definition, Principles, Teaching Materials, Socratic Questions

### Scenario 1: Learning from a File (Textbook, PDF, Markdown)

### 3. Generate Practice Exercises

**Step 1**: Attach your file to the AI chat

Use the `socrate.practice` prompt:```

[Attach: python-fundamentals.pdf]

``````

@socrate.practice Create practice exercises for Chapter 1.1

```**Step 2**: Generate an outline

```

This generates `data/exercises/practice-chapter-1.1.ipynb` with TODO exercises and hints./teacherkit.outline

```

### 4. Check Content Quality

**AI Response**:

Use the `socrate.check` prompt:```

📚 I've analyzed your textbook! Here's your learning plan:

```

@socrate.check Review Chapter-1.1.md for teaching qualityChapter 1: Python Basics (3-4 hours)

```├── 1.1 Variables and Data Types (30 min)

│   ├── KP-1.1.1: Variable assignment and naming

This validates:│   ├── KP-1.1.2: Numeric types (int, float)

- Socratic question quality│   └── KP-1.1.3: String operations

- Teaching material completeness└── 1.2 Control Flow (45 min)

- Exercise alignment with KPs    └── ... [more]



### 5. Start a Teaching SessionSaved to: data/outlines/python-fundamentals-outline.md

Ready to start? Run /teacherkit.prepare next!

Use the `socrate.lesson` prompt:```



```**Step 3**: Prepare knowledge points

@socrate.lesson Start teaching from the beginning```

```/teacherkit.prepare

```

This:

- Loads prepared chapters and progress**AI Response**:

- Guides students through KPs with Socratic questions```

- Tracks completion via `Update-Progress.ps1`✅ Prepared 18 knowledge points with:

- Adapts to student responses- Core definitions

- Code examples

---- Socratic questions (3 layers each)

- Analogies and comparison tables

## 🛠️ Commands

Saved to: data/chapters/python-fundamentals-prepared.md

### `socrate init <project-name>`Let's begin! Run /teacherkit.lesson

```

Initialize a new Socrate learning project with full structure.

**Step 4**: Start interactive learning

**Options:**```

- Creates `.github/prompts/`, `.specify/scripts/`, `.vscode/settings.json`/teacherkit.lesson

- Auto-generates `.gitignore` with Socrate-specific rules```

- Initializes Git repository

**AI Response** (Socratic dialogue begins):

### `socrate update````

🎓 Welcome to your Python journey!

Update an existing project with latest prompts and scripts.

Today we'll explore: Variables and Data Types (30 min)

**Options:**

- Backs up existing files to `.specify/backups/`Let's start with a question:

- Merges new settings into `.vscode/settings.json`

- Preserves user customizationsImagine you have a box where you can store things. In programming, 

we call this a "variable."

### `socrate config`

🤔 Question 1: If I told you I have a box labeled "age" and it 

Display current configuration and file paths.contains the number 25, what do you think happens if I later put 

the number 30 in the same box?

---

(Take a moment to think, then share your answer!)

## 📁 Project Structure```



```**Step 5**: Practice when offered

my-learning-project/```

├── .github/prompts/          # Five core teaching prompts[After 2-3 concepts, AI says:]

│   ├── socrate.outline.prompt.md

│   ├── socrate.prepare.prompt.mdGreat progress! Time for hands-on practice.

│   ├── socrate.check.prompt.md

│   ├── socrate.practice.prompt.mdI've created: data/exercises/practice-variables-01.ipynb

│   └── socrate.lesson.prompt.md

├── .specify/Open it in Jupyter/VS Code, fill in the TODOs, and run the cells!

│   ├── config.yaml           # AI model and teaching style settings```

│   └── scripts/powershell/

│       └── Update-Progress.ps1**Example Exercise File** (Jupyter Notebook):

├── .vscode/```python

│   ├── prompts/              # Symlinks to .github/prompts/# Cell 1 (Markdown)

│   └── settings.json         # Auto-approval for scripts# Practice: Variable Basics

├── data/# **Concepts**: Variables, Data Types, Reassignment

│   ├── outlines/             # Topic outlines# **Difficulty**: Level 1

│   ├── chapters/             # Teaching content (Chapter-*.md)# **Estimated**: 10 minutes

│   ├── exercises/            # Practice notebooks (*.ipynb)

│   ├── textbooks/            # Source materials# Cell 2 (Code)

│   └── progress.md           # Student progress log# TODO 1: Create a variable 'name' and assign your name as a string

└── logs/                     # Session logs

```### START CODE HERE ###

name = None  # Replace this

---### END CODE HERE ###



## 🎯 Teaching Philosophy# Cell 3 (Code)

# TODO 2: Create a variable 'age' and assign your age as an integer

Socrate implements the Socratic method through:

### START CODE HERE ###

1. **Ask Before Telling**: Lead with questions, explain after students respondage = None  # Replace this

2. **Build on Student's Words**: Echo their phrasing, validate attempts### END CODE HERE ###

3. **Layered Questions**: 

   - Layer 1: Basic understanding check# Cell 4 (Code)

   - Layer 2: Principle exploration (why/how)# Test cases (don't modify - run this cell to check your solution)

   - Layer 3: Real-world applicationassert isinstance(name, str), "name should be a string"

4. **Progressive Depth**: Start simple, build complexity based on responsesassert isinstance(age, int), "age should be an integer"

5. **Practice Integration**: Hands-on exercises after theoryprint(f"✅ All tests passed! {name} is {age} years old.")

```

---

---

## 🌟 Inspiration

### Scenario 2: Learning from a Topic Description

Socrate was inspired by [**spec-kit**](https://github.com/yisak/spec-kit) by [@yisak](https://github.com/yisak), which demonstrated the power of structured CLI tools for AI-assisted workflows. We adapted the project initialization pattern and prompt management system for educational use cases.

**Step 1**: Describe what you want to learn

Thank you to the spec-kit team for pioneering this approach! 🙏```

/teacherkit.outline "I want to understand Python list comprehensions"

---```



## 📜 License**AI Response**:

```

Apache License 2.0📚 Custom Lesson Plan: List Comprehensions



Copyright 2025 Socrate Team**Difficulty**: Intermediate  

**Estimated Time**: 20-30 minutes

Licensed under the Apache License, Version 2.0 (the "License");

you may not use this file except in compliance with the License.Topic 1: Foundations (10 min)

You may obtain a copy of the License at├── KP-1.1: Basic list operations review

├── KP-1.2: The concept of "comprehension"

    http://www.apache.org/licenses/LICENSE-2.0└── KP-1.3: Syntax breakdown: [expression for item in iterable]



Unless required by applicable law or agreed to in writing, softwareTopic 2: Practical Applications (15 min)

distributed under the License is distributed on an "AS IS" BASIS,├── KP-2.1: Filtering with conditions

WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.├── KP-2.2: Transforming data

See the License for the specific language governing permissions and└── KP-2.3: Nested comprehensions

limitations under the License.

[Rest of steps same as Scenario 1...]

---```



## 🤝 Contributing---



Contributions are welcome! Please feel free to submit issues or pull requests.### Scenario 3: Resuming After a Break



**Development Setup:**```

[Open chat, run:]

```bash/teacherkit.lesson

git clone https://github.com/socrate/socrate.git```

cd socrate

uv pip install -e ".[dev]"**AI Response**:

pytest```

```🎓 Welcome Back!



---**Last Session**: October 23, 2025 at 3:45 PM  

**Time Since Last Session**: 2 days

## 🔗 Links

**Completed So Far**: 8 knowledge points (44% progress)

- [GitHub Repository](https://github.com/socrate/socrate)- KP-1.1.1: Variable assignment

- [Issue Tracker](https://github.com/socrate/socrate/issues)- KP-1.1.2: Numeric types

- [spec-kit Inspiration](https://github.com/yisak/spec-kit)- ... [recent KPs]



---**Next Up**: KP-1.3.1: If/else statements



**Built with ❤️ for educators and learners who believe questions > answers**---


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
