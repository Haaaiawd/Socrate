# Data Model: Simplified Teaching Flow

**Feature**: 002-simplify-teaching-flow  
**Date**: 2025-10-22  
**Status**: Draft

## Overview

This feature **extends** the file-based storage from `001-ai-teaching-system` by adding a new `data/exercises/` directory for practice code files. All data continues to be stored as Markdown files in the `data/` directory hierarchy, maintaining the Markdown-First Storage principle from the constitution.

## Core Entities

### 1. Learning Session

**Description**: Represents the active teaching interaction within a single conversation thread.

**Attributes**:

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `session_id` | String | Auto-generated ID (timestamp-based) | `"session-2025-10-22-14-30"` | Unique per conversation start |
| `attached_files` | Array[FileReference] | List of files student attached | `[{name: "python-basics.md", size: "1.2MB"}]` | Max 3 files |
| `topic_description` | String | User-provided topic (if no files) | `"Python loops and iterations"` | 10-500 characters |
| `source_type` | Enum | How learning content was provided | `file_attachment \| topic_request` | Required |
| `current_phase` | Enum | Where student is in learning flow | `planning \| teaching \| practicing \| completed` | State machine |
| `current_knowledge_point` | String | Currently active KP ID | `"KP-1.3"` | Format: KP-[chapter].[number] |
| `completed_kps` | Array[String] | KP IDs finished | `["KP-1.1", "KP-1.2"]` | Ordered chronologically |
| `practice_attempts` | Integer | Number of exercises attempted | `3` | 0+ |
| `session_start` | DateTime | When learning began | `2025-10-22T14:30:00Z` | ISO 8601 |
| `total_duration` | Duration | Estimated time elapsed | `45 minutes` | Human-readable |

**Relationships**:
- One session per conversation thread
- Contains one LearningPlan
- Has multiple ProgressCheckpoints (auto-saved)

**State Transitions**:
```
planning → teaching → practicing → teaching (cycle) → completed
         ↓                        ↓
         → teaching (skip practice if non-code topic)
```

**Validation Rules**:
- Must have either `attached_files` OR `topic_description` (not both empty)
- `current_phase` cannot skip states (must progress linearly)
- `current_knowledge_point` must exist in LearningPlan

**Storage**: Conversation context (ephemeral) + optional JSON export (future)

---

### 2. LearningPlan

**Description**: Structured outline of what will be taught, generated from file analysis or topic knowledge.

**Attributes**:

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `title` | String | Learning topic/course name | `"Introduction to Python Programming"` | 5-100 characters |
| `source` | Enum | How plan was created | `file_parsed \| ai_generated` | Required |
| `main_concepts` | Array[Concept] | Top-level learning areas | `[{title: "Variables", ...}, {title: "Loops", ...}]` | 3-10 concepts |
| `estimated_duration` | Duration | Total expected study time | `6 hours` | Human-readable |
| `difficulty_level` | Enum | Overall complexity | `beginner \| intermediate \| advanced` | Required |
| `generated_at` | DateTime | When plan was created | `2025-10-22T14:31:00Z` | ISO 8601 |

**Nested Structure**:

```yaml
LearningPlan:
  - Concept (Main Topic):
      - SubTopic:
          - KnowledgePoint (discrete skill)
              - Socratic questions
              - Practice exercises (optional)
```

**Example**:
```yaml
title: "Python Loops and Iterations"
source: ai_generated
difficulty_level: beginner
main_concepts:
  - title: "For Loops"
    sub_topics:
      - title: "Basic Range Iteration"
        knowledge_points:
          - id: "KP-1.1"
            title: "Understanding range()"
            questions: ["When do you use range()?", ...]
      - title: "Iterating Over Lists"
        knowledge_points:
          - id: "KP-1.2"
            title: "List iteration patterns"
            practice_available: true
  - title: "While Loops"
    sub_topics: [...]
```

**Relationships**:
- One plan per Learning Session
- Contains multiple KnowledgePoints (flat list, hierarchically organized)

**Validation Rules**:
- Must have at least 1 main concept
- Each concept must have at least 1 sub-topic
- Each sub-topic must have 1-5 knowledge points
- Total KPs should be 5-20 for manageable sessions

**Storage**: Conversation context (ephemeral)

---

### 3. KnowledgePoint (KP)

**Description**: A discrete concept or skill to be learned, the atomic unit of teaching.

**Attributes**:

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `id` | String | Unique identifier | `"KP-2.3"` | Format: KP-[concept].[sequence] |
| `title` | String | Concept name | `"List Comprehensions"` | 5-50 characters |
| `description` | String | What student will learn | `"Transform lists concisely using comprehension syntax"` | 20-200 characters |
| `type` | Enum | Teaching approach | `theory \| practice \| mixed` | Required |
| `difficulty` | Enum | Complexity level | `beginner \| intermediate \| advanced` | Required |
| `prerequisites` | Array[String] | KP IDs that must come before | `["KP-1.1", "KP-1.2"]` | Can be empty |
| `socratic_questions` | Array[String] | Guiding questions | `["When would you use this?", ...]` | 2-5 questions |
| `mastery_status` | Enum | Student progress | `not_started \| learning \| practiced \| mastered` | Default: not_started |

**Relationships**:
- Multiple KPs per LearningPlan
- Can have 0-3 PracticeExercises (if type includes practice)

**Validation Rules**:
- Prerequisites must reference existing KP IDs in same plan
- `socratic_questions` required if type is `theory` or `mixed`
- `mastery_status` progresses: not_started → learning → practiced (optional) → mastered

**Storage**: Conversation context (ephemeral)

---

### 4. PracticeExercise

**Description**: Hands-on coding task for skill application.

**Attributes**:

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `exercise_id` | String | Unique identifier | `"exercise-loops-01"` | kebab-case |
| `related_kp` | String | Associated knowledge point | `"KP-2.3"` | Must reference existing KP |
| `language` | Enum | Programming language | `python \| javascript \| java` | MVP: python only |
| `difficulty` | Enum | Exercise complexity | `easy \| medium \| hard` | Default: matches KP difficulty |
| `skeleton_code` | String | Code template with TODOs | `"def solve(n):\n    ### START CODE ###\n    ..."` | Must include TODO markers |
| `test_cases` | Array[TestCase] | Example inputs/outputs | `[{input: "5", output: "15"}, ...]` | 2-5 cases |
| `hints` | Array[String] | Graduated hints | `["Think about...", "Try using...", "Here's partial code..."]` | 3-tier system |
| `student_solution` | String | Student's submitted code | `"def solve(n):\n    return n * 3"` | Set when submitted |
| `feedback_given` | Array[String] | AI feedback messages | `["Great use of...", "Consider..."]` | Socratic-style |
| `completion_status` | Enum | Attempt state | `not_started \| in_progress \| needs_help \| completed` | Default: not_started |

**Nested Structures**:

**TestCase**:
```yaml
- input: "5"        # String representation
  output: "15"      # Expected result
  description: "Basic case: 5 * 3"
```

**Hint Levels**:
```yaml
hints:
  - "Conceptual hint (what to think about)"
  - "Specific hint (which function/pattern to use)"
  - "Partial code hint (fill in the blank)"
```

**Relationships**:
- Multiple exercises可 per KnowledgePoint (optional)
- One per practice session typically

**Validation Rules**:
- `skeleton_code` must include at least one TODO marker (e.g., `### START CODE ###`)
- `test_cases` must have at least 1 case
- `hints` must be ordered (conceptual → specific → partial)
- `student_solution` is required before `completion_status` = `completed`

**Storage**: Conversation context (ephemeral) + generated code file (temporary, not version-controlled)

---

### 5. ProgressCheckpoint

**Description**: Auto-saved snapshot of learning state, created periodically.

**Attributes**:

| Field | Type | Description | Example | Constraints |
|-------|------|-------------|---------|-------------|
| `checkpoint_id` | String | Timestamp-based ID | `"cp-2025-10-22-15-00"` | Auto-generated |
| `timestamp` | DateTime | When saved | `2025-10-22T15:00:00Z` | ISO 8601 |
| `completed_kps` | Array[String] | KP IDs finished | `["KP-1.1", "KP-1.2", "KP-1.3"]` | Snapshot |
| `current_kp` | String | Active KP at save time | `"KP-1.4"` | Current position |
| `exercises_completed` | Integer | Practice count | `2` | 0+ |
| `conversation_length` | Integer | Estimated tokens used | `15000` | Proxy for context usage |

**Relationships**:
- Multiple checkpoints per Learning Session
- Created automatically every 10 minutes or after major events (KP completion, exercise submission)

**Validation Rules**:
- `completed_kps` is cumulative (monotonically increasing)
- `conversation_length` triggers warnings at 80% estimated context limit

**Storage**: Conversation context (most recent 3-5 checkpoints retained)

---

## Data Flow

### Flow 1: File Attachment → Learning

```
Student attaches "python-basics.md"
  ↓
AI reads file content (via platform API)
  ↓
Generates LearningPlan:
  - Parses headings → Concepts
  - Parses sections → SubTopics
  - Extracts paragraphs → KnowledgePoints
  ↓
Creates LearningSession (session_id, attached_files, ...)
  ↓
Displays plan, asks confirmation
  ↓
Student confirms → Teaching begins (KP-1.1)
```

### Flow 2: Topic Request → Learning

```
Student: "Teach me Python loops"
  ↓
AI clarifies if needed: "Beginner or advanced? Specific loop types?"
  ↓
Generates LearningPlan (ai_generated):
  - Uses internal knowledge to create structure
  - Generates KPs with Socratic questions
  ↓
Creates LearningSession (topic_description, ...)
  ↓
Starts teaching immediately (KP-1.1)
```

### Flow 3: Teaching → Practice → Feedback

```
Complete theoretical KPs (KP-1.1, KP-1.2)
  ↓
AI detects practice moment: "Ready to code this yourself?"
  ↓
Generates PracticeExercise:
  - Creates skeleton_code with TODOs
  - Generates test_cases
  - Prepares hints
  ↓
Student receives code file, completes it
  ↓
Student submits solution (paste code or attach file)
  ↓
AI reviews using Socratic method:
  - "What were you trying to do here?"
  - Provides graduated hints if needed
  - Celebrates success or guides to fix
  ↓
Updates completion_status, moves to next KP
```

### Flow 4: Context Management

```
Every 5 KPs completed:
  ↓
Create ProgressCheckpoint
  ↓
Check conversation_length
  ↓
If > 80% estimated limit:
  - Summarize progress
  - Suggest pausing: "Great work! Good time to take a break?"
```

---

## Persistence Strategy

### MVP (Ephemeral Storage)

**Primary Storage**: Conversation context (AI platform memory)

**Advantages**:
- Zero file system dependency
- Automatic synchronization (conversation history)
- Simple architecture (no file I/O logic)

**Limitations**:
- Lost if conversation deleted
- No cross-session persistence (beyond conversation thread)
- Platform-dependent retention

**Mitigation**: 
- Proactive warnings before context limits
- Future: Manual export/import commands

### Future (Hybrid Storage)

**Optional Persistent Layer**:

```
data/
├── sessions/
│   └── session-2025-10-22-14-30.json     # Exported session state
├── plans/
│   └── python-loops-plan.md              # Saved learning plans
└── progress/
    └── student-progress.json             # Cross-session tracking
```

**Export Trigger**: `/teacherkit.export-progress` command (future)

**Import Trigger**: `/teacherkit.resume [session-id]` command (future)

---

## Schema Evolution

### Version 1.0.0 (MVP)

Entities defined above. Ephemeral storage only.

### Planned Changes (v0.3.0+)

- Add `Student` entity for multi-user support
- Add `CourseLibrary` entity for reusable learning plans
- Persistent storage option (JSON files)
- Multi-language support in `PracticeExercise` (JavaScript, Java)

---

## Validation Rules Summary

| Entity | Critical Rules |
|--------|----------------|
| LearningSession | Must have file OR topic; phase transitions are linear |
| LearningPlan | 3-10 concepts, 5-20 total KPs |
| KnowledgePoint | 2-5 Socratic questions if theory; prerequisites must exist |
| PracticeExercise | TODO markers required; 3-tier hints; test cases ≥ 1 |
| ProgressCheckpoint | Completed KPs monotonic; token warning at 80% |

---

## Status

**Phase 1 Data Model**: ✅ Complete

**Next Artifact**: Contracts (command specifications)
