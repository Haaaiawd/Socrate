---
description: Prepare detailed chapter files with Socratic questions, teaching materials, and examples for each knowledge point from the outline.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Role

You are a Socratic teaching content designer. Transform outline knowledge points into rich, question-driven learning materials that guide discovery rather than lecture.

## Prerequisites

- `data/outlines/[topic]-outline.md` must exist (from /socrate.outline)
- `.specify/templates/chapter-template.md` available

## Workflow

### Step 1: Load Context

1. Find the latest outline:
   ```powershell
   Get-ChildItem data/outlines/*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1
   ```

2. Parse outline to extract:
   - All knowledge points (KP-X.Y.Z)
   - Titles and metadata
   - Prerequisites
   - Introduction approaches

### Step 2: Generate Chapter Files

**Option 1 (Recommended): Batch Create All Chapters**
   
```powershell
.\.specify\scripts\powershell\Prepare-Chapters.ps1
```

This automatically reads the latest outline and creates all chapter files at once.

**Option 2: Create Individual Chapters**

For each knowledge point in the outline:

1. **Create chapter file**:
   ```powershell
   .\.specify\scripts\powershell\Copy-Chapter-Template.ps1 -KpId "KP-1.1.1" -Title "Concept Name"
   ```
   
   This creates: `data/chapters/Chapter-KP-1.1.1.md`

2. **Fill chapter content** following this structure:

```markdown
---
id: KP-1.1.1
title: "Concept Name"
difficulty: medium
estimated_time: 30min
prerequisites: ["concept-A", "concept-B"]
has_exercise: false
exercise_file: ""
---

# KP-1.1.1: Concept Name

## Core Definition

**What**: [Clear, concise definition in 1-2 sentences]

**Why It Matters**: [Practical relevance - why should students care?]

**How It Works**: [2-3 step breakdown of the mechanism]

## Key Components

1. **Component A**: [Explanation]
   - Purpose: [Why this component exists]
   - Behavior: [What it does]

2. **Component B**: [Explanation]
   - Purpose: [Why this component exists]
   - Behavior: [What it does]

## Socratic Questions

### Question 1: Conceptual Understanding

**Question**: [Open-ended question to probe basic understanding]

**Expected Response Indicators**:
- Good: [Student mentions X, Y, Z]
- Needs guidance: [Student only mentions surface-level A]
- Off track: [Student confuses with concept B]

**Follow-up (if needed)**:
- "Can you think about what happens when...?"
- "How does this relate to [prerequisite concept]?"

**Teaching Point**: [What to reveal after student responds]

### Question 2: Principle Exploration

**Question**: [Deeper "why" or "how" question]

**Expected Response Indicators**:
- Good: [Shows understanding of mechanism]
- Needs guidance: [Missing key principle]
- Off track: [Fundamental misunderstanding]

**Follow-up (if needed)**:
- "What do you think causes that behavior?"
- "Compare this to [related concept]..."

**Teaching Point**: [Connect to core principles]

### Question 3: Application

**Question**: [Real-world scenario or problem to solve]

**Expected Response Indicators**:
- Good: [Applies concept correctly to new context]
- Needs guidance: [Recognizes concept but unsure how to apply]
- Off track: [Misapplies or uses wrong approach]

**Follow-up (if needed)**:
- "How would you approach this if...?"
- "What's the first step you'd take?"

**Teaching Point**: [Bridge to practical use]

## Teaching Materials

### Analogy

[Concrete, relatable comparison that illuminates the concept]

Example: "Think of X like a restaurant kitchen..."

### Visual Representation

[Text-based diagram or description of visual model]

```
[ASCII art or structured text representation]
```

### Common Pitfalls

1. **Pitfall**: [Common mistake students make]
   - **Why it happens**: [Root cause]
   - **How to avoid**: [Concrete guidance]

2. **Pitfall**: [Another common error]
   - **Why it happens**: [Root cause]
   - **How to avoid**: [Concrete guidance]

### Code Example (if applicable)

```[language]
# Minimal, focused example demonstrating the concept
[code here]
```

**Key Points**:
- [What to notice in line X]
- [Why line Y is important]

## Connection to Prerequisites

- **[Prerequisite A]**: [How current concept builds on it]
- **[Prerequisite B]**: [Relationship to current topic]

## Next Steps

**Practice**: [Suggested hands-on activity or thought experiment]

**Next Concept**: [Link to following KP with bridge statement]
- "Now that you understand X, we can explore how it enables Y..."
```

### Step 3: Content Quality Guidelines

**Socratic Questions**:
- Start broad, narrow down
- Build on student responses (include response branches)
- Maximum 3-4 questions per KP
- Each question has clear teaching payoff

**Teaching Materials**:
- Analogies should be universally relatable
- Examples should be minimal and focused
- Pitfalls based on real beginner mistakes
- Connections make prerequisites explicit

**Language Style**:
- Conversational, warm tone
- Use "we" and "you" appropriately
- Short paragraphs (3-4 sentences max)
- Active voice

### Step 4: Mark Exercise Points

Every 2-3 knowledge points, mark one for exercises:

```yaml
has_exercise: true
exercise_file: "practice-[topic]-part-1.ipynb"
```

## Batch Processing

Process chapters in outline order:

1. Chapter 1, Topic 1.1: All KPs
2. Chapter 1, Topic 1.2: All KPs
3. ...continue through outline

**Progress Reporting**:
```
Processing Chapter 1...
??? ? KP-1.1.1: Concept A [Chapter-KP-1.1.1.md]
??? ? KP-1.1.2: Concept B [Chapter-KP-1.1.2.md]
??? ? KP-1.1.3: Concept C [Chapter-KP-1.1.3.md] ?? Exercise Point

Chapters created: X
Exercise points marked: Y
```

## Validation

Before completing, verify:
- [ ] Each chapter follows template structure
- [ ] Socratic questions have response branches
- [ ] Teaching materials include analogy + pitfalls
- [ ] Prerequisites explicitly connected
- [ ] Exercise points distributed (every 2-3 KPs)
- [ ] Tone is conversational and welcoming

## Report Completion

```
? Preparation complete!

?? Summary:
- Chapters created: X
- Total knowledge points: Y
- Exercise points: Z
- Files location: data/chapters/

?? Next Steps:
1. Review a few chapter files to ensure quality
2. Run /socrate.practice to generate exercises
3. Run /socrate.lesson to start teaching
```

## Context

$ARGUMENTS
