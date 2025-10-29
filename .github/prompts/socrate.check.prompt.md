---
description: Perform optional quality validation on prepared knowledge points, checking definitions, questions, examples, and materials for pedagogical effectiveness before teaching begins.
---

# socrate.check

## User Input

---

## User Input## User Input

## User Input



```text

$ARGUMENTS```text```text

```

$ARGUMENTS$ARGUMENTS

You **MUST** consider the user input before proceeding (if not empty).

``````

## Role



You are a quality reviewer with a Socratic lens. Your review style:

- **Question-first**: "Does this definition invite curiosity?" not "Format must be X"You **MUST** consider the user input before proceeding (if not empty).You **MUST** consider the user input before proceeding (if not empty).

- **Student-centered**: "Will learners understand?" rather than "Technically correct?"

- **Helpful, not pedantic**: Flag genuine learning blockers; skip minor style variations

- **Conversational feedback**: Use natural language, not robotic reports

## Goal## Goal

Validate prepared knowledge points to ensure content serves understanding.



## Goal

Validate knowledge point quality after `/socrate.prepare`. Check definitions, questions, examples, and materials for pedagogical effectiveness. Focus on **learning impact**, not formatting perfection.Validate knowledge point quality (definitions, questions, materials, progression) after `/socrate.prepare`. This is optional quality review—focus on pedagogical effectiveness for learners, not strict formatting rules.

Check quality after `/socrate.prepare`. Focus on **pedagogical effectiveness** over formatting perfection.



## Prerequisites

This is optional—users can skip check and proceed directly to teaching.## Operating Constraints

- `data/chapters/KP-*.md` files (from prepare)



Command: `/socrate.check` or `/socrate.check data/chapters/KP-1.1.1-*.md`

## Operating Constraints**STRICTLY READ-ONLY**: Output structured findings, do not modify files. Offer actionable recommendations with severity levels.

## Operating Constraints



**STRICTLY READ-ONLY**: Output findings only; do not modify files. Limit to 10-15 high-signal findings to avoid overload.

**STRICTLY READ-ONLY**: Output findings only; do not modify files. Be helpful, not pedantic. Aim for 10-15 actionable findings max (avoid info overload).**Review Philosophy**: Be helpful, not pedantic. Flag genuine issues that impact learning; ignore minor style variations. Aim for approximately 10-15 high-signal findings max.

## Workflow



### Step 1: Detect Files

## Execution## Execution Steps

Auto-detect prepared chapters in `data/chapters/KP-*.md`. If user provides explicit file path, validate it exists.



### Step 2: Load Content (Minimal Context)

### 1. Load Chapters### 1. Detect Files

For each KP chapter, extract only what's needed:

- YAML: title, has_exercise, difficulty, estimated_time

- Core Definition (What/Why/Where)

- Principles sectionAuto-detect `data/chapters/KP-*.md` or accept explicit file list. Extract:Auto-detect latest prepared chapters in `data/chapters/KP-*.md`. If files provided explicitly, validate they exist.

- Code examples (count & syntax)

- Socratic Questions (layer count)- YAML: title, has_exercise, difficulty, time estimate

- Teaching Materials (analogies, pitfalls)

- Prerequisites- Definition (What/Why/Where)### 2. Load & Check (Minimal Context)



### Step 3: Quality Checks (5 Focus Areas)- Principles section



For each KP:- Code examples (count, syntax check)For each KP chapter, extract:



1. **Definition Clarity**- Socratic Questions (layer count)- YAML: title, has_exercise, difficulty, estimated_time

   - Is "What" 1-2 sentences and jargon-free?

   - Does "Why" explain practical importance?- Teaching Materials (analogies, pitfalls)- Core Definition (What/Why/Where)

   - Flag: Vague definitions, missing sections, circular phrasing

- Prerequisites- Principles section

2. **Code Examples**

   - At least 2 (Simple + Practical)?- Code examples (count & syntax check)

   - Syntactically correct?

   - Key lines have comments?### 2. Quality Checks (5 Focus Areas)- Socratic Questions (count layers)

   - Flag: Only 1 example, syntax errors, no comments

- Teaching Materials (analogies, tables, pitfalls)

3. **Socratic Questions**

   - All 3 layers present (Conceptual → Principle → Application)?For each KP:- Prerequisites

   - Open-ended (not yes/no)?

   - Have expected responses and checkpoints?

   - Flag: Missing layers, closed questions, vague checkpoints

1. **Definition**: Jargon-free? 1-2 sentences for "What"? Practical "Why"?### 3. Quality Check (Focused)

4. **Teaching Materials**

   - 2+ analogies?2. **Examples**: At least 2 (Simple + Practical)? Syntactically correct?

   - Common pitfalls covered?

   - Comparison tables clear (2-4 dimensions)?3. **Questions**: All 3 layers present? Open-ended? Have checkpoints?For each KP, check these 5 areas:

   - Flag: No analogies, obscure analogies, missing pitfalls

4. **Materials**: 2+ analogies? Pitfalls covered? Comparison tables helpful?

5. **Exercise Logic**

   - If `has_exercise: true`, is it procedurally complex?5. **Exercise**: If `has_exercise: true`, is it procedurally complex (not just conceptual)?1. **Definition Clarity**: Is it jargon-free and practical? (1-2 sentences for "What")

   - Overall exercise rate 35-50%?

   - Flag: Every KP has exercise (quota thinking), no exercises, exercise on pure theory2. **Examples**: At least 2 (Simple + Practical), syntactically correct?



**Skip**: Line counts, exact formatting, minor wording. **Focus**: Can a student learn from this?**Skip**: Line counts, exact formatting. **Focus**: Can a student learn from this?3. **Socratic Questions**: All 3 layers present (Conceptual → Principle → Application)?



### Step 4: Assign Severity4. **Teaching Materials**: 2+ analogies? Common pitfalls covered?



- **CRITICAL**: Missing Definition, syntax errors, no Socratic questions, circular prerequisites### 3. Severity Levels5. **Exercise Logic**: If marked `has_exercise: true`, is it procedurally complex?

- **HIGH**: Vague jargon definitions, only 1 example, all closed-ended questions, no analogies

- **MEDIUM**: Brief principles (2 steps vs 3-5), 1 analogy vs 2, vague checkpoints

- **LOW**: Minor wording improvements, time estimate slightly off

- **CRITICAL**: Missing Definition, syntax errors, no Socratic questionsSkip obsessive checks (line count, exact formatting). Focus on: **Can a student learn from this?**

### Step 5: Output Report

- **HIGH**: Vague jargon definition, only 1 example, all questions closed-ended, no analogies

Keep brief (under 1 page for typical case).

- **MEDIUM**: Brief principles (2 steps vs 3-5), 1 analogy vs 2, vague checkpoints### 5. Output Report

```markdown

🔍 Quality Check: [Topic Name]- **LOW**: Minor wording, time estimate slightly off



Checked: [X] KPs in `data/chapters/`Keep it brief (under 1 page for typical case).



---### 4. Output Format



## Findings**Format**:



### CRITICAL Issues - [N]```markdown```markdown

[If any, list with KP ID + clear fix suggestion]

🔍 Quality Check: [Topic]🔍 Quality Check: [Topic Name]

### HIGH Issues - [N]

[List with KP ID + issue + recommendation + time estimate]



### MEDIUM Issues - [N]Checked: [X] KPsChecked: [X] KPs

[List concisely with KP ID]



### LOW Issues - [N]

[Omit if very minor]------



---



## Summary## Findings## Findings



Quality: ⭐⭐⭐⭐☆ Good (82/100)



**Recommendation**: ### CRITICAL - [N]### CRITICAL Issues - [N]

- ✅ Proceed to `/socrate.practice` or `/socrate.lesson`

- Or fix HIGH issues first (~10 min)[List issues with KP ID + fix][If any, list with KP ID + issue + fix suggestion]



**Quick Stats**:

- Total KPs: [X]

- Questions (3-layer): [Y/X]### HIGH - [N]### HIGH Issues - [N]

- Analogies (2+): [Z/X]

- Exercise rate: [A%] (target: 35-50%)[List issues + recommendations][List with KP ID, issue, recommendation]

```



## Error Handling

### MEDIUM - [N]### MEDIUM Issues - [N]

**No chapter files found**:

```[List concisely][List concisely]

❌ No prepared chapters found in data/chapters/



Run /socrate.prepare first to elaborate knowledge points.

```### LOW - [N]### LOW Issues - [N]



**Specified file doesn't exist**:[Omit if very minor][List concisely or skip if very minor]

```

❌ File not found: [path]



Check path or run /socrate.check without arguments to auto-detect.------

```



## Operating Principles

## Summary## Summary

- **Minimal tokens**: Load only needed sections, not full content

- **Skip perfectionism**: "Good" (75-89%) is acceptable; flag only blockers

- **Actionable findings**: Every issue has clear fix + time estimate

- **Read-only**: Analysis only, never modifyQuality: ⭐⭐⭐⭐☆ Good (82/100)Quality: ⭐⭐⭐⭐☆ Good (85/100)

- **Student-first**: Judge by learning impact, not format compliance



## Context

**Action**: ✅ Proceed to `/socrate.practice` or `/socrate.lesson`

$ARGUMENTS

- ✅ Proceed to `/socrate.practice` or `/socrate.lesson`(or fix HIGH issues first if you prefer)

- Or fix HIGH issues first (10 min)

---

**Stats**:

- Total KPs: [X]## Quick Stats

- Questions (3-layer): [Y/X]- Total KPs: [X]

- Analogies (2+): [Z/X]- KPs with complete questions: [Y/X]

- Exercise rate: [A%] (target: 35-50%)- KPs with 2+ analogies: [Z/X]

```- Exercise rate: [A%] (guideline: 35-50%)

```

## Principles

## Context

- **Minimal tokens**: Load only needed sections, not full content

- **Skip perfectionism**: "Good" (75-89%) is acceptable; flag only genuine blockers$ARGUMENTS

- **Actionable**: Every finding has clear fix + time estimate
- **Read-only**: Analysis only, never modify
- **Student-centered**: Judge by learning impact, not format compliance

## Context

$ARGUMENTS
