# Data Model: AI Teaching System

**Date**: 2025-10-21  
**Purpose**: Define Markdown file schemas and relationships for the teaching system

## Overview

All data is stored as Markdown files with YAML frontmatter. No database is used. Files are organized in `data/` directory with clear naming conventions.

---

## Entity: Textbook

**Purpose**: Original learning material uploaded by student

**Location**: `data/textbooks/[filename]`

**Format**: Markdown (.md) or Plain Text (.txt)

**Schema** (YAML frontmatter - optional, auto-generated if missing):
```yaml
---
title: "Introduction to Python Programming"
author: "Jane Doe"
edition: "3rd Edition"
language: "en"
uploaded: 2025-10-21
total_pages: 342
format: "markdown"  # or "text"
---

# Chapter 1: Getting Started
[Content...]
```

**Validation Rules**:
- File must be readable text (UTF-8 encoding)
- Size limit: 50MB (soft limit, warnings above 10MB)
- Must contain at least one heading for outline generation

**Relationships**:
- 1 Textbook ‚Ü?1 Outline
- 1 Textbook ‚Ü?N Chapters

---

## Entity: Outline

**Purpose**: Structured table of contents extracted from textbook

**Location**: `data/outlines/[textbook-name]-outline.md`

**Schema**:
```yaml
---
textbook_source: "data/textbooks/intro-python.md"
course_title: "Introduction to Python Programming"
generated: 2025-10-21T14:30:00
total_chapters: 10
total_sections: 45
estimated_study_hours: 40
outline_version: 1
---

# Course Outline: Introduction to Python Programming

## Study Plan Overview

**Total Chapters**: 10  
**Estimated Time**: 40 hours  
**Difficulty**: Beginner to Intermediate

---

## Chapter Structure

### Chapter 1: Getting Started (Est. 2 hours)
- **Section 1.1**: What is Python?
- **Section 1.2**: Installing Python
- **Section 1.3**: Your First Program
- **Knowledge Points**: 5
- **Prerequisites**: None

### Chapter 2: Variables and Data Types (Est. 3 hours)
- **Section 2.1**: Understanding Variables
- **Section 2.2**: Numbers and Strings
- **Section 2.3**: Type Conversion
- **Knowledge Points**: 8
- **Prerequisites**: Chapter 1

[... additional chapters ...]

---

## Learning Path

```
Chapter 1 (Basics)
    ‚Ü?
Chapter 2 (Variables) ‚Ü?Chapter 3 (Control Flow)
    ‚Ü?                         ‚Ü?
Chapter 4 (Functions)    Chapter 5 (Lists)
    ‚Ü?                         ‚Ü?
        Chapter 6 (Dictionaries)
                ‚Ü?
        Chapter 7 (File I/O)
                ‚Ü?
    Chapter 8 (Error Handling)
                ‚Ü?
Chapter 9 (Modules) ‚Ü?Chapter 10 (Projects)
```

---

## Progress Tracking

Use `teacher status` to track completion across chapters.
```

**Validation Rules**:
- Must reference valid textbook_source path
- Chapter numbers must be sequential
- Knowledge point counts must be > 0

**Relationships**:
- 1 Outline ‚Ü?1 Textbook (source)
- 1 Outline ‚Ü?N Chapters

---

## Entity: Chapter

**Purpose**: Prepared teaching material with knowledge points and Socratic questions

**Location**: `data/chapters/[textbook-name]/chapter-[NN].md`

**Schema**:
```yaml
---
textbook: "Introduction to Python Programming"
chapter_number: 3
chapter_title: "Control Flow"
outline_source: "data/outlines/intro-python-outline.md"
prepared: 2025-10-21T15:00:00
estimated_time: "3 hours"
difficulty: "Beginner"
prerequisites: ["Chapter 1", "Chapter 2"]
knowledge_point_count: 7
preparation_status: "complete"  # or "in_progress"
---

# Chapter 3: Control Flow

## Chapter Overview

This chapter covers decision-making and loops in Python programming.

**Learning Objectives**:
- Understand if-else statements
- Master for and while loops
- Learn about break and continue
- Apply control flow to real problems

---

## Knowledge Points

### KP-3.1: Conditional Statements (if-else)

**Description**: Learn how to make programs respond differently based on conditions.

**Difficulty**: Beginner  
**Prerequisites**: Variables (Chapter 2)

**Guiding Questions**:
1. "Can you think of a real-life situation where you make a decision based on a condition?"
2. "What do you think happens when the condition is false?"
3. "How would you explain the difference between `if` and `if-else` to a friend?"

**Keywords**: if, else, elif, condition, boolean

---

### KP-3.2: For Loops

**Description**: Understand how to repeat actions a specific number of times.

**Difficulty**: Beginner  
**Prerequisites**: Lists (Chapter 5) - *Note: May need reordering*

**Guiding Questions**:
1. "When might you need to do something multiple times in a program?"
2. "What's the difference between 'repeat 5 times' and 'repeat until done'?"
3. "Can you describe a situation where a for loop is better than writing code multiple times?"

**Keywords**: for, range, iteration, loop

---

[... additional knowledge points ...]

---

## Practice Examples

### Example 1: Age Checker
```
Ask user for age ‚Ü?Check if >= 18 ‚Ü?Display appropriate message
```
**Teaching Prompt**: Guide student to build this without giving direct code.

### Example 2: Number Guesser
```
Generate random number ‚Ü?Loop until guess correct ‚Ü?Give hints
```
**Teaching Prompt**: Socratic questions about loop exit conditions.

---

## Common Misconceptions

1. **"= vs =="**: Students often confuse assignment with comparison
2. **Infinite Loops**: Forgetting to update loop variable
3. **Indentation**: Python's whitespace sensitivity

**Teacher Notes**: Watch for these during lesson dialogue.
```

**Validation Rules**:
- chapter_number must match filename
- All KP-* sections must have guiding questions (minimum 2)
- Keywords must not be empty

**Relationships**:
- 1 Chapter ‚Ü?1 Outline (source)
- 1 Chapter ‚Ü?N Knowledge Points (embedded)

---

## Entity: Progress Record

**Purpose**: Track student's learning advancement across textbooks

**Location**: `data/progress.md` (single file for MVP; future: per-student files)

**Schema**:
```yaml
---
student: "default"
current_textbook: "Introduction to Python Programming"
current_chapter: 3
current_knowledge_point: "KP-3.2"
started: 2025-10-20
last_session: 2025-10-21T16:45:00
total_study_time_hours: 5.5
completion_percentage: 25
session_count: 8
---

# Learning Progress

## Current Status

üìñ **Studying**: Introduction to Python Programming  
üìç **Current Chapter**: Chapter 3 - Control Flow  
üéØ **Current Topic**: KP-3.2 - For Loops  
‚è±Ô∏è **Total Time**: 5.5 hours  
üìä **Overall Progress**: 25% (3/10 chapters)

---

## Chapter Progress

| Ch# | Title | Status | KP Complete | Last Studied | Time Spent |
|-----|-------|--------|-------------|--------------|------------|
| 1 | Getting Started | ‚ú?Complete | 5/5 | 2025-10-20 | 2.0h |
| 2 | Variables | ‚ú?Complete | 8/8 | 2025-10-20 | 2.5h |
| 3 | Control Flow | ~ In Progress | 1/7 | 2025-10-21 | 1.0h |
| 4 | Functions | - Not Started | 0/10 | - | - |
| 5 | Lists | - Not Started | 0/12 | - | - |
| 6 | Dictionaries | - Not Started | 0/9 | - | - |
| 7 | File I/O | - Not Started | 0/6 | - | - |
| 8 | Error Handling | - Not Started | 0/7 | - | - |
| 9 | Modules | - Not Started | 0/8 | - | - |
| 10 | Projects | - Not Started | 0/5 | - | - |

**Legend**: ‚ú?Complete | ~ In Progress | - Not Started

---

## Knowledge Points Mastery

### Chapter 3: Control Flow (Current)

- [x] KP-3.1: Conditional Statements (if-else) - Mastered on 2025-10-21
- [ ] KP-3.2: For Loops - In Progress
- [ ] KP-3.3: While Loops
- [ ] KP-3.4: Break and Continue
- [ ] KP-3.5: Nested Loops
- [ ] KP-3.6: Loop Patterns
- [ ] KP-3.7: Practical Applications

---

## Session History

### Session #8 - 2025-10-21 16:45
- **Duration**: 45 minutes
- **Topic**: Started KP-3.2 (For Loops)
- **Activities**: Socratic dialogue, practice problem
- **Next**: Continue for loop exercises

### Session #7 - 2025-10-21 14:00
- **Duration**: 30 minutes
- **Topic**: Completed KP-3.1 (Conditional Statements)
- **Activities**: Review quiz, troubleshooting
- **Next**: Move to for loops

[... previous sessions ...]

---

## Recommendations

**Next Study Session**:
1. Complete KP-3.2 (For Loops) - estimated 20 minutes
2. Practice exercises for loops
3. Move to KP-3.3 (While Loops)

**Review Needed**:
- None at this time (recent chapters still fresh)

**Streak**: 2 days üî•
```

**Validation Rules**:
- current_chapter must be valid chapter number from outline
- current_knowledge_point must be valid KP-* format
- completion_percentage calculated as (completed_chapters / total_chapters) * 100

**Relationships**:
- 1 Progress Record ‚Ü?1 Current Textbook
- 1 Progress Record ‚Ü?N Session History entries

---

## Entity: Note/Highlight

**Purpose**: Student-captured snippets and highlights from lessons

**Location**: `data/notes/[textbook-name]-notes.md`

**Schema**:
```yaml
---
textbook: "Introduction to Python Programming"
student: "default"
note_count: 15
created: 2025-10-20
last_updated: 2025-10-21T16:50:00
---

# My Notes: Introduction to Python Programming

## Chapter 1: Getting Started

### Note #1 - 2025-10-20 14:30
**Source**: Chapter 1, KP-1.2 (Installing Python)  
**Marked Text**: "Python 3.11 is recommended for beginners because..."  
**My Comment**: Remember to check version before installing packages  
**Tags**: #installation #version

---

### Note #2 - 2025-10-20 15:00
**Source**: Chapter 1, KP-1.3 (First Program)  
**Marked Text**: "print() function displays text to the console"  
**My Comment**: Parentheses are required!  
**Tags**: #basics #syntax

---

## Chapter 2: Variables

### Note #3 - 2025-10-20 16:00
**Source**: Chapter 2, KP-2.1 (Understanding Variables)  
**Marked Text**: "Variables are containers for storing data values"  
**My Comment**: Like labeled boxes in memory  
**Tags**: #variables #analogy

[... additional notes ...]

---

## Quick Reference (Auto-Generated)

**Key Concepts Highlighted** (Top 5):
1. Python 3.11 installation
2. print() function syntax
3. Variable assignment with =
4. String vs. Number types
5. if-else decision making

**Topics to Review**:
- Type conversion (3 notes)
- Loop syntax (2 notes)
```

**Validation Rules**:
- Source must reference valid chapter and KP
- Note numbers must be unique within file

**Relationships**:
- 1 Note Collection ‚Ü?1 Textbook
- 1 Note ‚Ü?1 Knowledge Point (source)

---

## Entity: Lesson Session (Ephemeral)

**Purpose**: Track active learning session state (in-memory during `/teacherkit.lesson`)

**Location**: Not persisted to disk; state maintained by Copilot conversation context

**State Variables**:
```yaml
session_id: "session-2025-10-21-16-45"
textbook: "Introduction to Python Programming"
chapter: 3
knowledge_point: "KP-3.2"
student_responses: [
  { question: "What is a for loop?", answer: "It repeats code", timestamp: "16:46" },
  { question: "When would you use it?", answer: "When I know how many times", timestamp: "16:47" }
]
hints_given: 1
direct_answer_redirects: 2
mastery_level: "progressing"  # not_started | progressing | needs_review | mastered
session_duration: "15 minutes"
```

**Lifecycle**:
1. Created when `/teacherkit.lesson` invoked
2. Updated with each dialogue turn
3. Saved to progress.md on `exit` or `pause`
4. Discarded after session ends

---

## File Naming Conventions

| Entity | Pattern | Example |
|--------|---------|---------|
| Textbook | `[descriptive-name].md` | `intro-python.md` |
| Outline | `[textbook-name]-outline.md` | `intro-python-outline.md` |
| Chapter | `chapter-[NN].md` | `chapter-03.md` |
| Notes | `[textbook-name]-notes.md` | `intro-python-notes.md` |
| Progress | `progress.md` | `progress.md` (singleton) |

**NN**: Zero-padded chapter number (01, 02, ..., 10)

---

## Data Flow

```
[Student Upload] ‚Ü?Textbook.md
                      ‚Ü?
    [/teacherkit.parse] ‚Ü?Outline.md
                                    ‚Ü?
        [/teacherkit.prepare] ‚Ü?Chapter.md (with KPs + Questions)
                                        ‚Ü?
            [/teacherkit.lesson] ‚Ü?(Session State in Memory)
                                        ‚Ü?
                            Progress.md (updated on exit)
                                +
                            Notes.md (if student marks text)
```

---

## Storage Estimates (MVP)

| Entity | Average Size | Max Count (MVP) | Total Storage |
|--------|--------------|-----------------|---------------|
| Textbook | 2-5 MB | 5 | ~25 MB |
| Outline | 50 KB | 5 | ~250 KB |
| Chapter | 20 KB | 50 (10 chapters * 5 books) | ~1 MB |
| Notes | 100 KB | 5 | ~500 KB |
| Progress | 20 KB | 1 | ~20 KB |
| **Total** | | | **~27 MB** |

No database overhead, no indexing needed. Git-friendly.

---

## Future Considerations (Post-MVP)

1. **Multi-User Support**: 
   - Add `student_id` to frontmatter
   - Change `progress.md` to `progress-[student-id].md`

2. **Binary Attachments**:
   - Support image references in chapters (e.g., diagrams)
   - Store in `data/assets/[textbook-name]/images/`

3. **Backup Strategy**:
   - Markdown files are plain text ‚Ü?easy to backup
   - Consider automatic git commits after each session

4. **Search Index**:
   - If note count grows large, add search functionality
   - Could use PowerShell `Select-String` or external tool like ripgrep
