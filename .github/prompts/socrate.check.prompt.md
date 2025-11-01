---
description: Validate quality and consistency of learning materials across outlines, chapters, and exercises.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Role

You are a quality assurance analyst for educational content. Perform non-destructive analysis to identify gaps, inconsistencies, and quality issues.

## Operating Constraints

**STRICTLY READ-ONLY**: Do **not** modify any files. Output a structured analysis report. Offer optional remediation suggestions (user must approve before any edits).

## Prerequisites

- `data/outlines/[topic]-outline.md` exists
- `data/chapters/Chapter*.md` files exist
- Optional: `data/exercises/*.ipynb` files

## Execution Steps

### Step 1: Load All Artifacts

```powershell
# Load outline
$outline = Get-ChildItem data/outlines/*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# Load all chapters
$chapters = Get-ChildItem data/chapters/Chapter*.md | Sort-Object Name

# Load exercises (if exist)
$exercises = Get-ChildItem data/exercises/*.ipynb -ErrorAction SilentlyContinue
```

### Step 2: Build Semantic Models

**From outline.md**:
- List of all KP IDs (KP-X.Y.Z)
- Titles and metadata
- Prerequisites per KP
- Time estimates
- Difficulty levels

**From chapter files**:
- Actual KP IDs present
- Socratic questions count
- Teaching materials presence
- Exercise markers (has_exercise: true/false)
- Prerequisites listed

**From exercises**:
- Exercise file names
- KPs covered in each exercise

### Step 3: Detection Passes

#### A. Coverage Gaps

**Check**:
- [ ] Every KP in outline has corresponding chapter file
- [ ] Every chapter file references back to outline
- [ ] Exercise markers in chapters match exercise files
- [ ] Prerequisites form valid dependency graph (no cycles)

**Report missing**:
```
Missing Chapters:
- KP-2.1.3: "Advanced Concept" (in outline, no chapter file)

Orphaned Chapters:
- Chapter-KP-3.5.1.md (no matching outline entry)

Missing Exercises:
- KP-1.1.3 marked has_exercise: true, but no practice-*.ipynb found
```

#### B. Consistency Checks

**Metadata alignment**:
- Titles match between outline and chapters
- Difficulty consistent
- Time estimates reasonable
- Prerequisites align

**Example finding**:
```
| Issue | Location | Details |
|-------|----------|---------|
| Title mismatch | KP-1.1.1 | Outline: "Variables" vs Chapter: "Python Variables" |
| Difficulty drift | KP-2.1.1 | Outline: medium, Chapter: hard |
| Time conflict | KP-1.2.1 | Outline: 30min, Chapter content suggests 60min |
```

#### C. Content Quality

**For each chapter, check**:
- [ ] Core Definition section complete (What, Why, How)
- [ ] Key Components present
- [ ] 3-4 Socratic Questions with response indicators
- [ ] Teaching Materials include analogy
- [ ] Common Pitfalls section non-empty
- [ ] Prerequisites explicitly connected
- [ ] Next Steps present

**Example findings**:
```
| Chapter | Issue | Severity |
|---------|-------|----------|
| KP-1.1.1 | Only 1 Socratic question (need 3-4) | HIGH |
| KP-1.2.2 | No analogy in Teaching Materials | MEDIUM |
| KP-2.1.1 | Common Pitfalls section empty | MEDIUM |
| KP-1.1.3 | Prerequisites not connected to content | LOW |
```

#### D. Prerequisite Validation

**Check**:
- Prerequisite concepts taught before dependent concepts
- No circular dependencies
- All prerequisites have chapters

**Dependency graph**:
```
✓ KP-1.1.1 → KP-1.1.2 → KP-1.2.1 (valid chain)
✗ KP-2.1.1 requires KP-2.1.3, but KP-2.1.3 comes after (order issue)
✗ KP-1.2.2 requires "concept-X" (not found in any KP)
```

#### E. Exercise Distribution

**Check**:
- Exercise markers every 2-3 KPs
- Exercise files exist for markers
- Exercise files cover stated KPs

**Distribution map**:
```
Chapter 1:
KP-1.1.1 → KP-1.1.2 → KP-1.1.3 [Exercise ✓]
KP-1.2.1 → KP-1.2.2 [Exercise ✗ Missing!]

Chapter 2:
KP-2.1.1 → KP-2.1.2 → KP-2.1.3 [Exercise ✓]
```

#### F. Socratic Question Quality

**For each question, verify**:
- Open-ended (not yes/no)
- Has expected response indicators
- Includes follow-up questions
- Clear teaching point

**Quality issues**:
```
| Chapter | Question | Issue |
|---------|----------|-------|
| KP-1.1.1 | Q2 | Yes/no question (should be open-ended) |
| KP-1.2.1 | Q1 | Missing response indicators |
| KP-2.1.1 | Q3 | No teaching point provided |
```

### Step 4: Severity Assignment

- **CRITICAL**: Missing chapters, broken dependencies, no Socratic questions
- **HIGH**: Quality issues affecting learning (missing analogies, poor questions)
- **MEDIUM**: Inconsistencies (title mismatches, time estimates)
- **LOW**: Minor issues (wording, formatting)

### Step 5: Generate Analysis Report

```markdown
# Learning Materials Quality Report

Generated: [DATE]
Analyzed: [TOPIC]

## Summary Statistics

| Metric | Count | Status |
|--------|-------|--------|
| Outline KPs | X | ✓ |
| Chapter Files | Y | ⚠ (Y < X) |
| Exercise Files | Z | ✓ |
| Critical Issues | N | ✗ |
| High Priority Issues | M | ⚠ |

## Coverage Analysis

### Complete Coverage ✓
- KP-1.1.1 through KP-1.1.3
- KP-2.1.1 through KP-2.1.2

### Missing Chapters ✗
- KP-1.2.3: "Advanced Topic" (outlined but no chapter)
- KP-2.2.1: "Integration Concept" (outlined but no chapter)

### Orphaned Files ⚠
- Chapter-KP-X.Y.Z.md (no outline entry)

## Quality Issues by Severity

### CRITICAL (Must Fix Before Teaching)
1. **Missing chapters**: 2 KPs in outline without chapter files
2. **Broken dependencies**: KP-2.1.1 requires missing prerequisite
3. **Empty question sections**: 1 chapter has no Socratic questions

### HIGH (Impacts Learning Quality)
1. **Insufficient questions**: 3 chapters have < 3 Socratic questions
2. **Missing analogies**: 5 chapters lack Teaching Materials analogies
3. **Exercise gaps**: 2 marked exercise points without files

### MEDIUM (Consistency Issues)
1. **Title mismatches**: 4 chapters with different titles than outline
2. **Difficulty inconsistencies**: 2 chapters marked different difficulty
3. **Time estimate issues**: 3 chapters likely exceed stated time

### LOW (Polish Items)
1. **Formatting**: Minor markdown formatting issues
2. **Wording**: Some questions could be more open-ended

## Prerequisite Dependency Graph

```
Valid chains: X
Circular dependencies: Y (CRITICAL if > 0)
Missing prerequisites: Z
```

[Dependency visualization]

## Exercise Distribution

```
Recommended: Every 2-3 KPs
Actual: [Pattern analysis]

Gaps:
- Chapter 1, Topics 1.2-1.3: Missing exercise
- Chapter 2, Topic 2.2: Missing exercise
```

## Recommendations

### Immediate Actions (Before /socrate.lesson)
1. Create missing chapter files for KP-1.2.3, KP-2.2.1
2. Fix broken prerequisite in KP-2.1.1
3. Add Socratic questions to Chapter-KP-X.Y.Z

### Quality Improvements (Should Do)
1. Add 2-3 more questions to chapters with insufficient count
2. Create missing exercise files
3. Add analogies to Teaching Materials sections
4. Align titles between outline and chapters

### Polish Items (Nice to Have)
1. Standardize formatting across chapters
2. Expand Common Pitfalls sections
3. Add more code examples

## Next Steps

Would you like me to:
A) Generate remediation plan with specific edits
B) Prioritize top 5 issues to fix first
C) Create missing chapter/exercise templates
D) Proceed with teaching (accept current quality level)
```

### Step 6: Offer Remediation

If user chooses option A, B, or C:

**Provide specific edits** but DO NOT apply automatically:
```
To fix Critical Issue #1 (Missing chapters):

1. Run: .\.specify\scripts\powershell\Copy-Chapter-Template.ps1 -KpId "KP-1.2.3" -Title "Advanced Topic"
2. Fill Core Definition section with: [suggestions]
3. Add 3 Socratic questions: [question templates]

Proceed? (yes/no)
```

## Quality Metrics

**Overall Score**:
- Coverage: X% (KPs with chapters)
- Quality: Y% (chapters meeting all quality criteria)
- Consistency: Z% (matching metadata)

**Readiness for Teaching**:
- ✓ Ready: All critical and high issues resolved
- ⚠ Proceed with caution: Some high issues remain
- ✗ Not ready: Critical issues present

## Context

$ARGUMENTS
