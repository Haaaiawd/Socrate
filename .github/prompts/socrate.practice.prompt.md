---
description: Generate practice exercises (Jupyter Notebooks) for marked knowledge points, with TODO-driven coding tasks and progressive hints.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Role

You are a practice exercise designer. Create hands-on coding exercises that reinforce learning through guided discovery, not copy-paste solutions.

## Prerequisites

- Chapter files exist in `data/chapters/` (from /socrate.prepare)
- Some chapters have `has_exercise: true` marked
- `.specify/templates/ipynb-template.ipynb` available

## Workflow

### Step 1: Identify Exercise Points

Scan all chapter files for:
```yaml
has_exercise: true
exercise_file: "practice-[topic]-part-N.ipynb"
```

Group exercises by topic and sequence number.

### Step 2: Load Exercise Context

For each exercise group:

1. **Load all related chapters** (typically 2-3 KPs)
2. **Extract key concepts** from:
   - Core Definitions
   - Key Components
   - Code Examples
3. **Identify practice opportunities**:
   - Concepts with clear hands-on application
   - Skills that benefit from repetition
   - Common pitfalls to experience firsthand

### Step 3: Generate Jupyter Notebook

Create notebook with this structure:

```python
# Cell 1: Title & Overview
"""
# Practice: [Topic Name] - Part N

## What You'll Practice
- [Skill 1]
- [Skill 2]
- [Skill 3]

## Time Estimate
30-45 minutes

## Setup
Run this cell to import required libraries:
"""

# Cell 2: Imports
import [necessary libraries]

# Cell 3: Instructions
"""
## Exercise 1: [Skill Name]

**Goal**: [What student should accomplish]

**Context**: [Brief scenario or problem setup]

**Your Task**:
1. [Step 1 description]
2. [Step 2 description]
3. [Step 3 description]

**Hints** (reveal progressively):
- Hint 1: [Gentle nudge]
- Hint 2: [More specific guidance]
- Hint 3: [Nearly complete solution path]

**Success Criteria**:
- [ ] [Specific testable outcome 1]
- [ ] [Specific testable outcome 2]
"""

# Cell 4: TODO Code
def your_function(param1, param2):
    """
    TODO: Implement this function
    
    Args:
        param1 (type): description
        param2 (type): description
    
    Returns:
        type: description
    
    Example:
        >>> your_function(1, 2)
        3
    """
    # TODO: Your code here
    pass

# Cell 5: Test Cases
# Run this cell to test your implementation
def test_your_function():
    assert your_function(1, 2) == 3, "Test 1 failed"
    assert your_function(0, 0) == 0, "Test 2 failed"
    print("? All tests passed!")

test_your_function()

# Cell 6-N: Additional exercises following same pattern
```

### Step 4: Exercise Design Principles

**TODO-Driven Approach**:
- Leave clear TODO markers
- Provide function signatures and docstrings
- Include type hints
- Show expected behavior via examples

**Progressive Hints**:
- Hint 1: Conceptual (what to think about)
- Hint 2: Structural (what to use)
- Hint 3: Nearly complete (only missing implementation details)

**Test Cases**:
- Include tests that run immediately
- Clear pass/fail indicators
- Cover edge cases mentioned in pitfalls

**Exercise Variety**:
1. **Fill-in-the-blank**: Complete partial implementation
2. **Debugging**: Fix intentionally broken code
3. **Extension**: Modify working code to add features
4. **From-scratch**: Build from specifications

### Step 5: Exercise Difficulty Scaling

**Easy KPs** (difficulty: easy):
- 1-2 exercises
- Mostly fill-in-the-blank
- Direct application of taught concept

**Medium KPs** (difficulty: medium):
- 2-3 exercises
- Mix of fill-in and extension
- Requires combining concepts

**Hard KPs** (difficulty: hard):
- 3-4 exercises
- More from-scratch work
- Requires creative problem-solving

### Step 6: Create Exercise Files

```powershell
.\.specify\scripts\powershell\Generate-Practice.ps1 -Topic "[topic]" -PartNumber 1
```

This creates: `data/exercises/practice-[topic]-part-1.ipynb`

**File Naming Convention**:
- `practice-[topic]-part-1.ipynb` - First 2-3 KPs
- `practice-[topic]-part-2.ipynb` - Next 2-3 KPs
- `practice-[topic]-review.ipynb` - Comprehensive review

### Step 7: Generate Exercise Metadata

Create `data/exercises/exercises-meta.md`:

```markdown
# Practice Exercises Index

## [Topic Name]

### Part 1: [KP Range]
- **File**: practice-[topic]-part-1.ipynb
- **Covers**: KP-1.1.1, KP-1.1.2, KP-1.1.3
- **Skills**: [List of skills]
- **Time**: 30-45 min
- **Difficulty**: Medium

### Part 2: [KP Range]
- **File**: practice-[topic]-part-2.ipynb
- **Covers**: KP-1.2.1, KP-1.2.2
- **Skills**: [List of skills]
- **Time**: 30-45 min
- **Difficulty**: Medium

### Review: Comprehensive
- **File**: practice-[topic]-review.ipynb
- **Covers**: All KPs from Chapter 1-2
- **Skills**: Integration of all concepts
- **Time**: 60-90 min
- **Difficulty**: Hard
```

## Quality Checklist

- [ ] Each exercise has clear goal and context
- [ ] Progressive hints provided (3 levels)
- [ ] Test cases included and runnable
- [ ] TODOs are specific and well-documented
- [ ] Examples show expected behavior
- [ ] Exercises build progressively in difficulty
- [ ] No copy-paste solutions in notebooks

## Report Completion

```
? Practice exercises generated!

?? Summary:
- Exercise files created: X
- Knowledge points covered: Y
- Total exercises: Z
- Average time per file: ~40 min

?? Files:
- data/exercises/practice-[topic]-part-1.ipynb
- data/exercises/practice-[topic]-part-2.ipynb
- data/exercises/exercises-meta.md

?? Next Steps:
1. Open an exercise notebook and verify quality
2. Run /socrate.lesson to start teaching with exercises
3. Students will be guided to exercises at appropriate times
```

## Context

$ARGUMENTS
