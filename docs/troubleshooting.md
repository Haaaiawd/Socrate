# TeacherKit Troubleshooting Guide

> **Common errors, debugging steps, and platform-specific tips**

This guide helps you resolve issues when using TeacherKit with AI coding assistants (GitHub Copilot, Cursor, Claude Code).

---

## 🚨 Common Errors

### 1. File Attachment Not Working

**Symptoms**:
- `/teacherkit.outline` says "No file detected"
- AI doesn't analyze your attached PDF/Markdown

**Possible Causes & Solutions**:

#### ✅ Check File Format
**Problem**: Unsupported file type  
**Solution**: TeacherKit supports:
- Markdown (`.md`)
- Plain text (`.txt`)
- PDF (`.pdf`)

If you have a Word doc (`.docx`), PowerPoint (`.pptx`), or other format:
```bash
# Convert to PDF first (use online tools or)
# For Word/Excel/PowerPoint → Save As → PDF
```

#### ✅ Check File Size
**Problem**: File too large (>50MB)  
**Solution**: 
- **Split into chapters**: If you have a 200-page textbook, extract one chapter at a time
- **Use topic description instead**: Instead of attaching the whole book, describe the topic:
  ```
  /teacherkit.outline "Python file I/O operations from Chapter 8"
  ```

#### ✅ Verify File Content is Readable
**Problem**: PDF is scanned images (not text-based)  
**Solution**:
- Open the PDF → try to select and copy text
- If text selection doesn't work, the PDF is image-based → use OCR tools:
  - [Adobe Acrobat OCR](https://www.adobe.com/acrobat/online/ocr-pdf.html)
  - [Online OCR](https://www.onlineocr.net/)
- Or convert to plain text manually

#### ✅ Platform-Specific Attachment Methods
**Problem**: File not attached correctly for your AI platform  
**Solution**: See [Platform-Specific Tips](#-platform-specific-tips) below

---

### 2. Outline Generation Fails

**Symptoms**:
- `/teacherkit.outline` runs but produces no output
- AI says "I can't access this file" or "Permission denied"

**Possible Causes & Solutions**:

#### ✅ Check AI Platform Permissions
**Problem**: AI doesn't have read access to your workspace  
**Solution**:
- **GitHub Copilot**: Enable workspace file access in VS Code settings
  ```
  File → Preferences → Settings → search "Copilot workspace"
  ✅ Enable: GitHub Copilot: Enable Workspace Context
  ```
- **Cursor**: Check workspace trust settings
  ```
  File → Trust Workspace (if prompted)
  ```

#### ✅ Verify File Content is Valid
**Problem**: File is empty or corrupted  
**Solution**:
- Open the file manually → check if content displays correctly
- If corrupted, re-download or re-export the file

#### ✅ Try a Simpler File First
**Problem**: Complex file structure confuses AI  
**Solution**:
- Test with a simple Markdown file:
  ```markdown
  # Python Basics
  
  ## Variables
  Variables store data...
  
  ## Data Types
  Python has int, float, str...
  ```
- If this works, your original file may need simplification

---

### 3. Practice Exercises Not Offered

**Symptoms**:
- During `/teacherkit.lesson`, AI never suggests practice
- No `data/exercises/` files generated

**Possible Causes & Solutions**:

#### ✅ Verify Programming Topic
**Problem**: Non-coding topic (e.g., "history of Python")  
**Solution**: Practice exercises only appear for **programming concepts** that need hands-on coding:
- ✅ Will offer practice: "Python loops", "list comprehensions", "function definitions"
- ❌ Won't offer practice: "Python history", "why learn Python", "programming philosophy"

#### ✅ Check If Practice Command Was Run
**Problem**: Skipped `/teacherkit.practice` step  
**Solution**:
1. Verify `data/exercises/exercises-meta.md` exists:
   ```bash
   ls data/exercises/
   ```
2. If missing, run:
   ```
   /teacherkit.practice
   ```
3. Then resume lesson:
   ```
   /teacherkit.lesson
   ```

#### ✅ Wait for 2-3 Knowledge Points
**Problem**: Expecting practice too early  
**Solution**: Practice is offered **after 2-3 knowledge points**, not immediately:
```
KP-1.1.1: Variable basics
KP-1.1.2: Data types
KP-1.1.3: Type conversion
   ↓
🏋️ Practice time! (after 3 KPs)
```

---

### 4. Progress Not Saved

**Symptoms**:
- Return to lesson → AI doesn't remember previous session
- `data/progress.md` is empty or missing

**Possible Causes & Solutions**:

#### ✅ Check If data/progress.md Exists
**Problem**: File was never created  
**Solution**:
```bash
# Check if file exists
ls data/progress.md

# If missing, run lesson for at least 1 complete knowledge point
/teacherkit.lesson
# [Complete at least 1 KP, then check again]
```

#### ✅ Verify Write Permissions
**Problem**: AI can't write to workspace  
**Solution**:
- Check folder permissions:
  ```bash
  # On Windows
  icacls data\progress.md
  
  # On Mac/Linux
  ls -l data/progress.md
  ```
- Ensure your user has write access to the `data/` folder

#### ✅ Ensure Session Ended Properly
**Problem**: Forced exit without saving  
**Solution**: Always use the `pause` command to save:
```
[In lesson]
pause
```
**AI will respond**:
```
✅ Progress saved to data/progress.md
Great work today! Run /teacherkit.lesson to resume.
```

---

### 5. Command Not Recognized

**Symptoms**:
- Type `/teacherkit.outline` → AI says "I don't understand"
- Slash commands don't work

**Possible Causes & Solutions**:

#### ✅ Check If Prompts Are Installed
**Problem**: `.github/prompts/` folder missing  
**Solution**:
```bash
# Verify prompts exist
ls .github/prompts/

# If missing, re-run init
teacherkit init .
# (Use . to initialize in current directory)
```

#### ✅ Verify AI Platform Supports Slash Commands
**Problem**: Your AI platform doesn't recognize custom prompts  
**Solution**:
- **GitHub Copilot**: Slash commands work in VS Code Chat
- **Cursor**: Use `@` instead of `/`:
  ```
  @teacherkit.outline
  ```
- **Claude Code**: Use custom instructions or copy-paste prompt templates

#### ✅ Use Platform-Specific Syntax
**Problem**: Wrong command format for your platform  
**Solution**: See [Platform-Specific Tips](#-platform-specific-tips) below

---

## ⚡ Performance Issues

### Large Files (Slow Response)

**Problem**: Attached a 100+ page PDF → AI takes 5+ minutes to respond

**Solutions**:

1. **Split into chapters**:
   ```
   [Attach only Chapter 3]
   /teacherkit.outline
   ```

2. **Use topic description instead**:
   ```
   /teacherkit.outline "Python decorators from Advanced Python book, Chapter 7"
   ```

3. **Convert to Markdown first** (more efficient than PDF parsing):
   ```bash
   # Use pandoc to convert PDF to Markdown
   pandoc book.pdf -o book.md
   ```

### Slow Response Times

**Problem**: Every AI response takes 30+ seconds

**Solutions**:

1. **Check AI Platform Quota**:
   - GitHub Copilot: Free tier has rate limits → upgrade to Pro
   - Cursor: Check monthly token allowance
   - Claude: Verify API key has sufficient credits

2. **Reduce File Size**:
   ```bash
   # Check file size
   ls -lh data/outlines/*.md
   
   # If >1MB, consider splitting
   ```

3. **Simplify Topic Description**:
   - ❌ "I want to learn everything about Python from beginner to advanced, including all libraries and frameworks"
   - ✅ "Python basics: variables, loops, functions (beginner level)"

---

## 🖥️ Platform-Specific Tips

### GitHub Copilot (VS Code)

#### File Attachment
```
# Use @file in chat
@file python-basics.pdf
/teacherkit.outline
```

#### Custom Prompts
- Prompts are loaded from `.github/prompts/` automatically
- Use `/teacherkit.outline` directly (slash syntax)

#### Troubleshooting
- If slash commands don't work:
  1. Open VS Code Settings (`Ctrl+,` or `Cmd+,`)
  2. Search "GitHub Copilot Chat"
  3. Ensure "Enable Slash Commands" is checked

---

### Cursor

#### File Attachment
```
# Use @Files command
@Files python-basics.pdf
@teacherkit.outline
```

#### Custom Prompts
- Create prompts in `.cursorrules` or `.github/prompts/`
- Use `@` instead of `/`:
  ```
  @teacherkit.outline
  @teacherkit.lesson
  ```

#### Troubleshooting
- If `@teacherkit.outline` not found:
  1. Check `.github/prompts/teacherkit.outline.prompt.md` exists
  2. Restart Cursor to reload prompts

---

### Claude Code (API)

#### File Attachment
```
# Drag and drop file into chat, then:
/teacherkit.outline
```

#### Custom Prompts
- Copy-paste prompt templates from `.github/prompts/` into system instructions
- Or use custom instructions feature:
  1. Settings → Custom Instructions
  2. Paste contents of `.github/prompts/teacherkit.outline.prompt.md`

#### Troubleshooting
- If file attachment not supported:
  - Manually copy-paste file content into chat
  - Prefix with "Here's the file content:"

---

## 🔍 Debugging Steps

### 1. Check data/ Directory Structure

```bash
# Expected structure
data/
├── outlines/
│   └── [topic]-outline.md          # ✅ Should exist after /teacherkit.outline
├── chapters/
│   └── [topic]-prepared.md         # ✅ Should exist after /teacherkit.prepare
├── exercises/
│   ├── practice-[topic]-01.py      # ✅ Should exist after /teacherkit.practice
│   └── exercises-meta.md           # ✅ Should exist after /teacherkit.practice
└── progress.md                     # ✅ Should exist after completing 1 KP in lesson
```

**If any file missing**:
1. Re-run the corresponding command
2. Check terminal for error messages
3. Verify write permissions

---

### 2. Validate YAML Frontmatter

**Problem**: AI can't parse generated files

**Solution**: Check YAML syntax in generated files

```bash
# Example: Check outline file
cat data/outlines/python-basics-outline.md
```

**Expected format**:
```yaml
---
title: "Python Basics"
difficulty: "beginner"
total_topics: 3
total_kps: 12
estimated_hours: 4
---

[Markdown content follows]
```

**Common YAML errors**:
- ❌ Missing opening `---`
- ❌ Missing closing `---`
- ❌ Unquoted strings with special characters: `title: Python: The Basics` (should be `title: "Python: The Basics"`)

**Fix**: Manually edit the file to correct YAML syntax

---

### 3. Review Prompt Template Syntax

**Problem**: AI behaves unexpectedly during lessons

**Solution**: Check prompt templates for syntax errors

```bash
# Open lesson prompt
code .github/prompts/teacherkit.lesson.prompt.md
```

**Common issues**:
- Markdown formatting broken (missing headers, code blocks not closed)
- Conflicting instructions ("Always do X" vs. "Never do X")
- Missing sections (e.g., "Progress Tracking" section deleted)

**Fix**: Compare with original templates in repository

---

## 📞 Getting Help

### 1. Check README Examples
- See [README.md](../README.md) for usage scenarios
- Compare your workflow with documented examples

### 2. Review Spec for Expected Behavior
- See `specs/002-simplify-teaching-flow/spec.md` for detailed behavior definitions
- Check User Stories to understand how features should work

### 3. Review Contracts for Command Specs
- See `specs/002-simplify-teaching-flow/contracts/` for command-by-command specs
- Example: `outline-command-contract.md` explains exactly how `/teacherkit.outline` should behave

### 4. Search GitHub Issues
- [TeacherKit Issues](https://github.com/yourusername/teacherkit/issues)
- Search for similar problems or open a new issue

### 5. Community Support
- [GitHub Discussions](https://github.com/yourusername/teacherkit/discussions)
- Share your use case and get help from other users

---

## 🛠️ Debug Checklist

Before asking for help, try these steps:

- [ ] **Verify installation**: Run `teacherkit --version` (should show version number)
- [ ] **Check workspace structure**: Run `ls .github/prompts/` (should show 5 `.prompt.md` files)
- [ ] **Verify AI platform**: Confirm you're using GitHub Copilot, Cursor, or Claude Code
- [ ] **Test with simple file**: Try a 10-line Markdown file first
- [ ] **Check permissions**: Ensure AI can read/write in your workspace
- [ ] **Review logs**: Check terminal output for error messages
- [ ] **Compare with examples**: Follow README usage scenarios exactly

---

## 📝 Reporting Bugs

When opening a GitHub issue, please include:

1. **TeacherKit version**: `teacherkit --version`
2. **AI platform**: GitHub Copilot / Cursor / Claude Code (specify version)
3. **Operating system**: Windows / Mac / Linux (specify version)
4. **File type**: Markdown / PDF / Plain text
5. **File size**: e.g., "2MB PDF with 50 pages"
6. **Command that failed**: e.g., `/teacherkit.outline`
7. **Error message**: Copy-paste exact error output
8. **Expected behavior**: What you thought should happen
9. **Actual behavior**: What actually happened
10. **Steps to reproduce**:
    ```
    1. Run teacherkit init test-project
    2. Attach sample-file.pdf
    3. Run /teacherkit.outline
    4. Error appears: [error message]
    ```

---

**Still stuck? Open an issue on GitHub!**  
[https://github.com/yourusername/teacherkit/issues](https://github.com/yourusername/teacherkit/issues)

*We're here to help! 🙌*
