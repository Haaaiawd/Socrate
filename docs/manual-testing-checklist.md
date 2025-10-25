# TeacherKit - Manual Acceptance Testing Checklist

> **Test Plan for Feature 002: Simplified Teaching Flow**

This document guides manual testing of TeacherKit's core features. Since the system is AI-driven, these tests require a real AI platform (GitHub Copilot, Cursor, or Claude Code).

---

## 📋 Test Environment Setup

### Prerequisites
- [ ] Python 3.11+ installed
- [ ] TeacherKit CLI installed (`uv tool install teacherkit` or from source)
- [ ] AI coding assistant active (GitHub Copilot / Cursor / Claude Code)
- [ ] Test project initialized:
  ```bash
  teacherkit init test-teacherkit-acceptance
  cd test-teacherkit-acceptance
  ```

### Test Data Preparation
- [ ] Sample Python textbook file ready (Markdown or PDF, <10MB)
  - Suggested: `data/textbooks/sample-python-basics.md` (provided in repository)
- [ ] Alternative file formats ready:
  - Plain text file (`.txt`)
  - PDF file (`.pdf`)
  - Unsupported format (`.docx` or `.pptx`) for error testing

---

## 🧪 Test Suite

### User Story 1: Direct File Attachment Learning (P1 - MVP)

**Purpose**: Verify students can attach files and generate learning plans without CLI commands.

#### Scenario 1.1: Single File Attachment → Outline Generation

**Steps**:
1. Open AI chat (GitHub Copilot Chat / Cursor / Claude Code)
2. Attach test file: `sample-python-basics.md`
3. Run command: `/teacherkit.outline`

**Expected Results**:
- [ ] AI reads file content directly (no "file not found" errors)
- [ ] AI generates a structured outline with:
  - [ ] Chapter titles (e.g., "Chapter 1: Python Basics")
  - [ ] Topics under each chapter (e.g., "1.1 Variables and Data Types")
  - [ ] Knowledge points (KP-IDs) under each topic (e.g., "KP-1.1.1: Variable assignment")
  - [ ] Estimated study times (e.g., "30 minutes per topic")
- [ ] Outline saved to `data/outlines/[filename]-outline.md`
- [ ] YAML frontmatter present with:
  ```yaml
  title: "[Topic Title]"
  difficulty: "[beginner/intermediate/advanced]"
  total_topics: [X]
  total_kps: [Y]
  estimated_hours: [Z]
  ```

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 1.2: Verify Teaching Plan Includes Estimated Times

**Steps**:
1. Continue from Scenario 1.1 (outline already generated)
2. Review the generated outline file in `data/outlines/`

**Expected Results**:
- [ ] Each chapter has estimated study time (e.g., "3-4 hours")
- [ ] Each topic has granular time estimates (e.g., "30 min", "45 min")
- [ ] Total estimated hours displayed in YAML frontmatter

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 1.3: Multiple File Attachment → Unified Plan

**Steps**:
1. Start new AI chat session
2. Attach TWO files:
   - `sample-python-basics.md` (Chapter 1-2)
   - `sample-python-advanced.md` (Chapter 3-4)
3. Run command: `/teacherkit.outline`

**Expected Results**:
- [ ] AI analyzes both files
- [ ] Generated outline covers content from BOTH files
- [ ] Chapter numbers sequential across both files (Chapter 1, 2, 3, 4)
- [ ] Single unified outline file saved (not two separate files)

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 1.4: Unsupported Format → Polite Error

**Steps**:
1. Attach unsupported file (e.g., `sample-file.docx` or `.pptx`)
2. Run command: `/teacherkit.outline`

**Expected Results**:
- [ ] AI detects unsupported format
- [ ] AI responds politely with error message:
  - "I'm sorry, I can only process Markdown (`.md`), plain text (`.txt`), or PDF (`.pdf`) files."
- [ ] AI suggests solutions:
  - "Please convert your file to one of these formats, or describe the topic in text."
- [ ] NO crash or confusing error messages

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

### User Story 2: Topic-Based Learning Without Files (P1 - MVP)

**Purpose**: Verify students can learn topics without providing textbook files.

#### Scenario 2.1: Topic String → Outline Generation

**Steps**:
1. Start new AI chat session (no file attachments)
2. Run command: `/teacherkit.outline "Python loops"`

**Expected Results**:
- [ ] AI generates structured outline WITHOUT requiring a file
- [ ] Outline includes:
  - [ ] 3-5 main topics (e.g., "For loops", "While loops", "Loop control")
  - [ ] Knowledge points under each topic (e.g., "KP-1.1: For loop syntax")
  - [ ] Estimated study time (e.g., "1-2 hours total")
- [ ] Outline saved to `data/outlines/python-loops-outline.md`

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 2.2: Verify Socratic Questions Present

**Steps**:
1. Continue from Scenario 2.1 (outline generated)
2. Run command: `/teacherkit.prepare`
3. Review generated file in `data/chapters/python-loops-prepared.md`

**Expected Results**:
- [ ] Each knowledge point includes Socratic questions
- [ ] Questions organized in 3 layers:
  - [ ] Layer 1: Conceptual understanding ("What is the purpose of...?")
  - [ ] Layer 2: Principle exploration ("Why does Python use...?")
  - [ ] Layer 3: Application scenarios ("When would you choose...?")
- [ ] Each question includes:
  - [ ] Open-ended wording (not yes/no)
  - [ ] "Expected answer" checkpoint
  - [ ] "Check point" guidance for AI to assess understanding

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 2.3: Broad Topic → Clarifying Questions

**Steps**:
1. Start new AI chat session
2. Run command: `/teacherkit.outline "learn programming"`

**Expected Results**:
- [ ] AI detects topic is too broad
- [ ] AI asks clarifying questions:
  - "What programming language are you interested in?"
  - "What's your current experience level?"
  - "What do you want to build?"
- [ ] AI narrows scope based on answers
- [ ] AI generates focused outline after clarification

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 2.4: Specific Topic → Focused Lesson

**Steps**:
1. Start new AI chat session
2. Run command: `/teacherkit.outline "Python list comprehensions"`

**Expected Results**:
- [ ] AI generates focused outline (15-20 min lesson)
- [ ] Outline is concise:
  - 2-3 topics max
  - 6-8 knowledge points total
- [ ] AI does NOT ask clarifying questions (topic already specific)

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

### User Story 3: Integrated Practice Exercises (P1 - MVP)

**Purpose**: Verify students can practice programming through generated exercises.

#### Scenario 3.1: Practice Offered After 2-3 KPs

**Steps**:
1. Continue from prepared lesson (outline + prepare complete)
2. Run command: `/teacherkit.lesson`
3. Complete 2-3 knowledge points in the teaching dialogue

**Expected Results**:
- [ ] After 2-3 completed KPs, AI says:
  - "Great progress! Time for hands-on practice."
  - "I've created: `data/exercises/practice-[topic]-01.py`"
  - "Open it, fill in the TODOs, and submit when ready!"
- [ ] Practice is offered AUTOMATICALLY (not manually requested)

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 3.2: Exercise File Structure

**Steps**:
1. Continue from Scenario 3.1 (practice offered)
2. Open generated file: `data/exercises/practice-[topic]-01.py`

**Expected Results**:
- [ ] File includes:
  - [ ] Docstring with exercise description
  - [ ] TODO markers (e.g., `# TODO 1: Create a variable...`)
  - [ ] Code structure with placeholders:
    ```python
    # START CODE (Your solution)
    
    # END CODE
    ```
  - [ ] Test cases (e.g., `assert isinstance(name, str)`)
  - [ ] Graduated hints in comments (Hint 1, 2, 3)

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 3.3: Submit Exercise → Socratic Feedback

**Steps**:
1. Fill in the TODOs in the practice file
2. Submit completed code to AI chat (attach file or paste code)
3. Observe AI response

**Expected Results**:
- [ ] AI reviews code WITHOUT giving direct corrections
- [ ] AI asks diagnostic questions:
  - "Why did you choose this approach?"
  - "What do you think happens when...?"
  - "Can you think of an edge case where this might fail?"
- [ ] AI celebrates correct parts: "Great! Your variable naming is clear."
- [ ] AI guides improvements: "What if the input is empty? How would you handle that?"

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 3.4: Struggle → Graduated Hints

**Steps**:
1. Submit incorrect or incomplete code
2. Ask AI: "I'm stuck, can you help?"

**Expected Results**:
- [ ] AI provides hints in progression:
  - **Hint 1** (Conceptual): "Remember, variables in Python can be reassigned..."
  - **Hint 2** (Specific): "Try using the `+=` operator to increment the value."
  - **Hint 3** (Partial solution): "Here's the pattern: `age = age + 1` or `age += 1`"
- [ ] AI does NOT reveal full solution immediately
- [ ] AI encourages: "You're on the right track! Try again."

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 3.5: Correct Solution → Celebration + Extension

**Steps**:
1. Submit correct code with all TODOs completed
2. Code passes all test cases

**Expected Results**:
- [ ] AI celebrates: "🎉 Excellent work! Your solution is correct."
- [ ] AI summarizes what student did well
- [ ] AI suggests extension challenge:
  - "Want to try a harder version? Add input validation!"
  - "Challenge: Can you do this in one line using a list comprehension?"

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

### User Story 4: Seamless Learning Session Management (P2)

**Purpose**: Verify students can pause and resume lessons naturally.

#### Scenario 4.1: Pause → Save Progress

**Steps**:
1. During an active lesson, type: `pause`
2. Check `data/progress.md` file

**Expected Results**:
- [ ] AI responds with session summary:
  - "Completed Today: [KP IDs and titles]"
  - "Current Position: [KP-ID] - [KP Title] (in progress)"
  - "Total Progress: [X/Y] knowledge points ([percentage]%)"
  - "✅ Progress saved to `data/progress.md`"
- [ ] `data/progress.md` file exists
- [ ] YAML frontmatter includes:
  ```yaml
  topic: "[Topic Title]"
  completed_kps: [X]
  current_kp: "[KP-ID]"
  last_session: "[timestamp]"
  ```

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 4.2: Resume from Last KP

**Steps**:
1. Close AI chat after Scenario 4.1 (progress saved)
2. Reopen AI chat (new session)
3. Run command: `/teacherkit.lesson`

**Expected Results**:
- [ ] AI detects existing `data/progress.md`
- [ ] AI shows "Welcome Back!" message:
  - "Last Session: [timestamp]"
  - "Completed So Far: [X] knowledge points"
  - "Next Up: [KP-ID]: [KP Title]"
- [ ] AI offers resumption options:
  - A) Continue from last position
  - B) Quick recap, then continue
  - C) Start fresh with a new topic

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 4.3: Ask "What Have We Covered?" → Summary

**Steps**:
1. During an active lesson (with some progress), ask:
   - "What have we covered so far?"

**Expected Results**:
- [ ] AI provides progress summary:
  - List of completed KP IDs and titles
  - Current KP (in progress)
  - Progress percentage (e.g., "44% complete")
- [ ] AI optionally shows key takeaways from each KP

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Scenario 4.4: Long Break → Recap Offered

**Steps**:
1. Save progress with `pause`
2. Wait 24+ hours (or manually edit `data/progress.md` timestamp to 3 days ago)
3. Reopen AI chat and run: `/teacherkit.lesson`

**Expected Results**:
- [ ] AI detects long time gap (>24 hours)
- [ ] AI says: "It's been [X] days since we last studied!"
- [ ] AI offers options:
  - A) 5-minute recap before continuing
  - B) Mini-quiz to check retention
  - C) Continue where you left off
  - D) Quick skim of previous material
- [ ] If student chooses recap, AI shows summary table with key concepts

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

### Edge Cases & Error Handling

#### Edge Case 1: Very Large File (>100MB)

**Steps**:
1. Attach a large PDF file (>100MB)
2. Run: `/teacherkit.outline`

**Expected Results**:
- [ ] AI detects large file
- [ ] AI warns: "This file is quite large (>100MB). Processing may be slow."
- [ ] AI suggests: "Consider splitting into chapters or describing the topic instead."
- [ ] AI attempts to process OR gracefully declines with helpful alternative

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Edge Case 2: Corrupted File

**Steps**:
1. Attach a corrupted PDF (e.g., truncated file)
2. Run: `/teacherkit.outline`

**Expected Results**:
- [ ] AI detects unreadable content
- [ ] AI responds: "I'm having trouble reading this file. It might be corrupted."
- [ ] AI suggests: "Try re-downloading or converting to plain text."

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Edge Case 3: Practice Submission with Syntax Errors

**Steps**:
1. Submit practice code with Python syntax errors (e.g., missing `:` after `if`)
2. Observe AI response

**Expected Results**:
- [ ] AI detects syntax error
- [ ] AI guides with Socratic question:
  - "I notice there's a syntax issue. Can you spot what's missing in line 5?"
  - "What do Python if statements need at the end of the condition?"
- [ ] AI does NOT say "Your code is wrong" directly

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

#### Edge Case 4: Off-Topic Practice Submission

**Steps**:
1. During a "Python loops" exercise, submit code about "file I/O" instead
2. Observe AI response

**Expected Results**:
- [ ] AI detects off-topic submission
- [ ] AI gently redirects:
  - "I see you've written code for file handling! That's a great skill."
  - "But for this exercise, let's focus on loops. Can you try using a `for` loop?"

**Actual Results**: _______________________________________________

**Pass / Fail**: ⬜ PASS  ⬜ FAIL

**Notes**: _______________________________________________

---

## 📊 Test Summary

### Overall Results

| User Story | Scenarios Tested | Passed | Failed | Notes |
|------------|------------------|--------|--------|-------|
| US1: File Attachment | 4 | ___ | ___ | |
| US2: Topic-Based Learning | 4 | ___ | ___ | |
| US3: Practice Exercises | 5 | ___ | ___ | |
| US4: Session Management | 4 | ___ | ___ | |
| Edge Cases | 4 | ___ | ___ | |
| **Total** | **21** | ___ | ___ | |

### Pass Rate: ____ / 21 (___%）

---

### Critical Issues Found

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

### Minor Issues Found

1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

---

## ✅ Sign-Off

**Tester Name**: _______________________________________________  
**Test Date**: _______________________________________________  
**AI Platform Used**: ⬜ GitHub Copilot  ⬜ Cursor  ⬜ Claude Code  
**Platform Version**: _______________________________________________

**Test Environment**:
- Python Version: _______________________________________________
- Operating System: _______________________________________________
- TeacherKit Version: _______________________________________________

**Overall Assessment**:
- ⬜ **PASS** - All critical scenarios pass, minor issues acceptable
- ⬜ **FAIL** - Critical scenarios fail, requires fixes before release
- ⬜ **PARTIAL** - Most scenarios pass, some features need improvement

**Recommendations**:
_______________________________________________
_______________________________________________
_______________________________________________

---

**Next Steps**:
- [ ] Log all issues in GitHub Issues
- [ ] Prioritize fixes (critical vs. minor)
- [ ] Re-test failed scenarios after fixes
- [ ] Update documentation based on findings

---

*Testing completed on: _______________________________________________*
