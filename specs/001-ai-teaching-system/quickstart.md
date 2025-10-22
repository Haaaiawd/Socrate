# Quick Start Guide: AI Teaching System

**Version**: 1.0.0  
**Last Updated**: 2025-10-21  
**Target User**: Students using GitHub Copilot for self-paced learning

---

## What is This?

The Teacher AI Agent is a Socratic teaching system built into GitHub Copilot. Instead of giving you direct answers, it guides you to discover knowledge through questions‚Äîjust like a real teacher would.

**Think of it as**: A personal tutor that lives in your code editor, helping you learn from textbooks using dialogue instead of lectures.

---

## Prerequisites

Before you start, make sure you have:

‚ú?**Python 3.11+** ([Download here](https://www.python.org/downloads/))  
‚ú?**uv** package manager ([Install instructions](https://github.com/astral-sh/uv#installation))  
‚ú?**VS Code** installed  
‚ú?**GitHub Copilot** extension enabled  
‚ú?**PowerShell 7+** ([Download here](https://github.com/PowerShell/PowerShell/releases))

**Check Versions**:
```powershell
python --version           # Should show 3.11 or higher
uv --version              # Should show uv 0.x.x
pwsh --version            # Should show 7.x or higher
```

If you have PowerShell 5.1 (default on Windows), install PowerShell 7 separately.

---

## Installation

### Option 1: Install via uv (Recommended)

```powershell
uv tool install teacherkit --from git+https://github.com/<org>/teacherkit
```

### Option 2: One-time Use with uvx

```powershell
uvx --from git+https://github.com/<org>/teacherkit teacherkit init my-learning
```

**Verify Installation**:
```powershell
teacherkit --version
```

---

## First-Time Setup

### Step 1: Initialize Your Learning Repository

Use the CLI to create your project structure:

```powershell
teacherkit init my-learning
cd my-learning
```

This creates:
- `data/` directory (textbooks, chapters, notes, progress)
- `.vscode/prompts/` (teaching commands)
- `logs/` directory
- `.gitignore` and `README.md`

### Step 2: Verify Environment

Check that all prerequisites are met:

```powershell
teacherkit config
```

You should see green checkmarks for:
- ‚ú?Python 3.11+
- ‚ú?PowerShell 7+
- ‚ú?Git configured
- ‚ö†Ô∏è VS Code (optional warning if not detected)
- ‚ö†Ô∏è GitHub Copilot (optional warning if not active)

### Step 3: Upload Your Textbook

Place your learning material in `data/textbooks/`:

```
data/textbooks/intro-python.md
```

**Supported Formats**:
- Markdown (.md) - **Recommended**
- Plain text (.txt)

**Tips**:
- Use clear headings (# Chapter, ## Section) for better parsing
- UTF-8 encoding works best
- Keep files under 50MB

---

## Your First Learning Session

### Step 1: Parse Your Textbook

In VS Code, open Copilot Chat and type:

```
/teacherkit.parse data/textbooks/intro-python.md
```

**What Happens**:
- The system extracts chapters and sections
- Generates a structured outline
- Estimates study time
- Saves to `data/outlines/intro-python-outline.md`

**Expected Output**:
```
‚ú?Textbook Parsed Successfully!

üìñ Source: intro-python.md
üìã Outline Generated: data/outlines/intro-python-outline.md

Course Structure:
- Chapters: 10
- Sections: 45
- Estimated Study Time: 40 hours
```

---

### Step 2: Prepare Your First Chapter

```
/teacherkit.prepare 1
```

**What Happens**:
- Breaks Chapter 1 into knowledge points (KPs)
- Generates Socratic guiding questions
- Identifies prerequisites
- Saves to `data/chapters/intro-python/chapter-01.md`

**Expected Output**:
```
‚ú?Chapter 1 Prepared!

üìñ Chapter: Getting Started
üéØ Knowledge Points: 5
‚è±Ô∏è Estimated Time: 2 hours

Knowledge Points Overview:
1. KP-1.1: What is Python? - 3 questions
2. KP-1.2: Installing Python - 4 questions
3. KP-1.3: Your First Program - 5 questions
...
```

---

### Step 3: Start Learning!

```
/teacherkit.lesson 1
```

**What Happens**:
- Begins Socratic dialogue for Chapter 1
- Asks guiding questions (no direct answers!)
- Tracks your progress automatically

**Expected Interaction**:
```
üéì Starting Lesson: Chapter 1 - Getting Started

Current Topic: KP-1.1 - What is Python?
Progress: 0/5 knowledge points completed

Let's Begin!

üí≠ "Have you heard of Python before? What do you think it's used for?"

[You respond...]

AI: "Interesting! So you mentioned websites. Can you think of other 
     types of programs that might use Python?"

[Continue dialogue...]
```

---

## During a Lesson

### Special Commands

While in a lesson, you can use these commands:

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `hint` | Provides a graduated hint | You're stuck on a question |
| `example` | Gives a real-world scenario | You need concrete context |
| `skip` | Moves to next question | Really stuck (not recommended) |
| `pause` | Saves progress and exits | Need a break |
| `mark [text]` | Saves a highlighted note | Found something important |

**Example**:
```
You: "I'm not sure what you mean by 'data type'..."

AI: [Type 'hint' if you'd like a nudge!]

You: hint

AI: "Think about how we categorize things in real life. 
     Are numbers different from words? How?"
```

---

### Pausing & Resuming

**To Pause**:
```
You: pause
```

Your progress is automatically saved to `data/progress.md`.

**To Resume**:
```
/teacherkit.lesson 1
```

The system remembers where you left off!

---

## Checking Your Progress

### Quick Status Check

```
/teacherkit.status
```

**Output**:
```
üìä Learning Progress Summary

üìñ Current Textbook: Introduction to Python Programming
üìç Current Chapter: Chapter 1 - Getting Started (KP-1.2)
‚è±Ô∏è Total Study Time: 1.5 hours
üìà Overall Progress: 10% (1/10 chapters completed)
üî• Study Streak: 1 day

Next Up: Complete KP-1.2 (Installing Python)
```

### Detailed Progress

```
/teacherkit.status chapters
```

Shows chapter-by-chapter breakdown with completion percentages.

---

## Managing Your Notes

### Add a Quick Note

During or after a lesson:

```
/teacherkit.notes add "Remember: print() requires parentheses!"
```

**Output**:
```
‚ú?Note Added!

üìù Text: "Remember: print() requires parentheses!"
üìç Source: Chapter 1, KP-1.3 (First Program)
üïí Time: 2025-10-21 14:30
```

### View All Notes

```
/teacherkit.notes view
```

Shows all your notes organized by chapter.

### Search Notes

```
/teacherkit.notes search "loop"
```

Finds notes containing "loop".

---

## Typical Learning Workflow

Here's a recommended routine:

```
Day 1:
  1. /teacherkit.parse data/textbooks/my-book.md
  2. /teacherkit.prepare 1
  3. /teacherkit.lesson 1
  4. [Learn for 30-60 minutes]
  5. Type 'pause' when done

Day 2:
  1. /teacherkit.status (check where you left off)
  2. /teacherkit.lesson 1 (continues from KP-1.3)
  3. [Complete Chapter 1]
  4. /teacherkit.prepare 2

Day 3:
  1. /teacherkit.lesson 2
  2. [Continue learning...]
```

---

## Troubleshooting

### Problem: "Command not found"

**Solution**: Make sure:
1. GitHub Copilot extension is installed
2. Prompt files are in `.github/prompts/` directory
3. You're typing `/teacherkit.` (with the slash)

---

### Problem: "PowerShell script failed"

**Solution**:
1. Check PowerShell version: `$PSVersionTable.PSVersion` (must be 7+)
2. Verify `powershell-yaml` module installed:
   ```powershell
   Get-Module -ListAvailable powershell-yaml
   ```
3. Check file paths are correct (use absolute paths)

---

### Problem: "Textbook parsing returned no chapters"

**Solution**:
- Make sure your textbook uses Markdown headings (`#`, `##`, `###`)
- If it's plain text, the system will generate a flat outline
- Manually edit `data/outlines/[name]-outline.md` if needed

---

### Problem: "Copilot is giving direct answers instead of asking questions"

**Solution**:
- This is a prompt engineering issue
- Check that `.github/prompts/teacherkit.lesson.prompt.md` is loaded
- Remind Copilot: "Please guide me with questions, not direct answers"

---

## Tips for Effective Learning

### 1. **Don't Skip Questions**
Even if you think you know the answer, articulating it helps solidify understanding.

### 2. **Use Your Own Words**
The AI wants to hear *your* thinking, not textbook definitions.

### 3. **Ask Follow-Up Questions**
If something is unclear, ask! The system adapts to your needs.

### 4. **Take Notes During "Aha" Moments**
Use `/teacherkit.notes add` to capture insights while they're fresh.

### 5. **Review Your Progress Regularly**
Check `/teacherkit.status` weekly to see how far you've come.

---

## What's Next?

After completing your first chapter:

1. ‚ú?**Prepare More Chapters**: `/teacherkit.prepare 2`, `/teacherkit.prepare 3`, etc.
2. ‚ú?**Explore Multiple Textbooks**: Parse different books for varied topics
3. ‚ú?**Review Notes**: Use `/teacherkit.notes view` to revisit key concepts
4. ‚ú?**Track Your Streak**: Keep learning daily for motivation!

---

## Getting Help

### In-App Help

```
/teacherkit.help
```

(Coming in future version)

### Documentation

- **Full Specification**: `specs/001-ai-teaching-system/spec.md`
- **Data Model**: `specs/001-ai-teaching-system/data-model.md`
- **Contracts**: `specs/001-ai-teaching-system/contracts/`

### Common Issues

If you encounter issues:
1. Check `.specify/logs/teacher-activity.log` for error details
2. Verify file paths are correct (Windows: `D:\path\`, not `D:/path/`)
3. Ensure PowerShell execution policy allows scripts:
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
   ```

---

## Happy Learning! üéì

Remember: **Learning is a dialogue, not a lecture.** The system is designed to help you discover knowledge through questions. Be patient with yourself, stay curious, and enjoy the journey!

**Questions or feedback?** Check the project README or open an issue in the repository.
