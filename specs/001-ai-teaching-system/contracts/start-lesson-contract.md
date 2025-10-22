# Prompt Contract: Start Lesson

**Command Name**: `/teacherkit.lesson`  
**Priority**: P1 (MVP)  
**Phase**: Interactive Learning  
**User Story**: US3

---

## Command Interface

### Invocation
```
/teacherkit.lesson $CHAPTER_NUMBER [$KNOWLEDGE_POINT_ID]
```

### Parameters

| Name | Type | Required | Description | Example |
|------|------|----------|-------------|---------|
| `$CHAPTER_NUMBER` | Integer | Yes | Chapter to study | `3` |
| `$KNOWLEDGE_POINT_ID` | String | No | Specific KP to focus on (defaults to next incomplete) | `KP-3.2` |

### Example Usage
```
/teacherkit.lesson 3              # Start from last KP in Chapter 3
/teacherkit.lesson 3 KP-3.2       # Jump to specific KP
```

---

## Script Integration

**PowerShell Script Called**: `.specify/scripts/powershell/start-lesson.ps1`

**Script Parameters**:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [int]$ChapterNumber,
    
    [string]$KnowledgePointId = $null,  # Auto-detect if not provided
    
    [string]$ProgressPath = "data/progress.md"
)
```

**Script Responsibilities**:
1. Load chapter file to get KPs and questions
2. Read progress.md to find last studied KP
3. Determine starting KP (resume or specified)
4. Extract Socratic questions for selected KP
5. Return JSON with lesson context
6. (Later) Update progress.md on session exit

---

## Input Validation

**Pre-Conditions**:
- Chapter must be prepared (run `/teacherkit.prepare` first)
- Chapter file must exist in `data/chapters/[textbook]/chapter-[NN].md`
- Progress file exists (auto-created if first session)

**Validation Rules**:
```powershell
# Check chapter file exists
$chapterFile = "data/chapters/*/chapter-$($ChapterNumber.ToString('00')).md"
$found = Get-ChildItem -Path $chapterFile -ErrorAction SilentlyContinue

if (-not $found) {
    throw "Chapter $ChapterNumber not prepared. Run /teacherkit.prepare $ChapterNumber first."
}

# Validate KP exists in chapter
if ($KnowledgePointId) {
    $chapterContent = Get-Content $found.FullName -Raw
    if ($chapterContent -notmatch "### $KnowledgePointId:") {
        throw "Knowledge point $KnowledgePointId not found in Chapter $ChapterNumber"
    }
}
```

**Error Handling**:
- **Chapter Not Prepared** â†?Guide to run `/teacherkit.prepare`
- **Invalid KP ID** â†?List available KPs from chapter
- **Progress File Corrupt** â†?Backup old file, create fresh one

---

## Output Format

### Success Response (JSON)

```json
{
  "status": "success",
  "session_id": "session-2025-10-21-16-45",
  "lesson_context": {
    "textbook": "Introduction to Python Programming",
    "chapter_number": 3,
    "chapter_title": "Control Flow",
    "knowledge_point": {
      "id": "KP-3.2",
      "title": "For Loops",
      "description": "Understand how to repeat actions a specific number of times.",
      "difficulty": "Beginner",
      "prerequisites": ["Lists (Chapter 5)"],
      "keywords": ["for", "range", "iteration", "loop"]
    },
    "guiding_questions": [
      "When might you need to do something multiple times in a program?",
      "What's the difference between 'repeat 5 times' and 'repeat until done'?",
      "Can you describe a situation where a for loop is better than writing code multiple times?"
    ]
  },
  "progress": {
    "last_kp": "KP-3.1",
    "completed_kps": 1,
    "total_kps": 7,
    "chapter_progress": "14%"
  }
}
```

### Copilot Display Format

```
ðŸŽ“ Starting Lesson: Chapter 3 - Control Flow

---

**Current Topic**: KP-3.2 - For Loops  
**Difficulty**: Beginner  
**Progress**: 1/7 knowledge points completed (14%)

**Prerequisites**:
âš ï¸ This topic relates to Lists (Chapter 5). We'll cover what you need as we go.

---

## Let's Begin!

I'll guide you through understanding **for loops** using the Socratic method. Instead of giving you direct answers, I'll ask questions to help you discover the concepts yourself.

**Ready?** Let's start with the first question:

> ðŸ’­ "When might you need to do something multiple times in a program?"

Take your time to think. There's no wrong answerâ€”just share what comes to mind!

---

**Commands During Lesson**:
- Type `hint` if you're stuck
- Type `example` to see a related scenario
- Type `skip` to move to next question (not recommended)
- Type `pause` to save progress and exit
- Type `mark [text]` to highlight something important
```

### Error Response (JSON)

```json
{
  "status": "error",
  "error_type": "ChapterNotPrepared",
  "message": "Chapter 3 has not been prepared yet.",
  "suggestion": "Run: /teacherkit.prepare 3"
}
```

---

## Socratic Dialogue Flow

**Conversation State** (maintained in Copilot context, not persisted):

```yaml
session_state:
  current_question_index: 0
  student_responses: []
  hints_given: 0
  direct_answers_avoided: 0
  mastery_indicators: []
  session_start: "2025-10-21T16:45:00"
```

**Dialogue Loop** (managed by prompt):

1. **Ask Question**:
   - Display question from `guiding_questions` array
   - Use emoji (ðŸ’­) and friendly tone

2. **Receive Student Response**:
   - Analyze for understanding (keywords, confidence)
   - Avoid saying "correct" or "wrong"

3. **Respond Socratically**:
   - If answer shows understanding â†?Ask follow-up to deepen
   - If answer is vague â†?Ask clarifying question
   - If answer is off-track â†?Gently redirect with new angle

4. **Provide Hints (if requested)**:
   - First hint: Rephrase question differently
   - Second hint: Give analogous example
   - Third hint: Provide partial answer (last resort)

5. **Move to Next Question**:
   - When student demonstrates understanding (not just repeats)
   - Natural transition phrase

6. **Complete KP**:
   - After all questions answered
   - Summarize what student learned (in their words)
   - Update progress (internally)
   - Prompt next step (continue or pause)

**Mastery Detection**:
- Student uses correct terminology
- Student gives original examples
- Student connects to other concepts
- Student asks insightful questions

---

## Special Commands (In-Lesson)

| Command | Action | Script Call |
|---------|--------|-------------|
| `hint` | Provide graduated hint | None (prompt logic) |
| `example` | Show related scenario | None (prompt logic) |
| `skip` | Move to next question | None (discouraged) |
| `pause` | Save progress and exit | `update-progress.ps1` |
| `mark [text]` | Save highlighted snippet | `add-note.ps1 -Text $text` |

---

## Side Effects

1. **Updates Progress** (on `pause` or exit):
   - Increments session count
   - Updates current KP
   - Adds session history entry
   - Calculates time spent

2. **Creates Notes** (if `mark` used):
   - Appends to `data/notes/[textbook]-notes.md`
   - Includes timestamp and source KP

3. **Logs Session**:
   - Session start/end time
   - Questions asked/answered
   - Hints given
   - Mastery level

**No Side Effects On**:
- Chapter file (read-only during lesson)
- Outline file

---

## Success Criteria (from spec.md)

**Functional Requirements Met**:
- FR7: Initiate Socratic dialogue
- FR8: Use guiding questions from chapter
- FR9: Avoid direct answers (redirect to questions)
- FR10: Track in-session progress

**Success Metrics**:
- Student engagement (measured by response length/depth)
- Mastery indicators detected (keyword usage, examples)
- Zero direct answers given by AI

---

## Teaching Prompt Template

Embedded in `.github/prompts/teacherkit.lesson.prompt.md`:

```markdown
---
command: /teacherkit.lesson
description: Begin Socratic dialogue for a chapter
version: 1.0.0
requires_script: .specify/scripts/powershell/start-lesson.ps1
personality: socratic-teacher
---

# Start Lesson Command

You are a Socratic teaching assistant. Your role is to guide students to discover knowledge through questions, NOT to provide direct answers.

## Core Teaching Principles

1. **Ask, Don't Tell**: Always respond with a question or a prompt to think deeper
2. **Build on Student's Words**: Use their phrasing in follow-ups
3. **Encourage Exploration**: Celebrate attempts, even if incorrect
4. **Redirect Gently**: If off-track, ask a question that guides back
5. **Avoid "Correct/Incorrect"**: Instead say "Interesting! What if..." or "Let's explore that..."

## User Input Expected

```
/teacherkit.lesson [chapter] [optional: KP-ID]
```

## Execution Steps

1. **Load Lesson Context**:
   - Call PowerShell script to get chapter/KP details
   - Display welcoming message with progress

2. **Begin Dialogue**:
   - Ask first guiding question
   - Wait for student response

3. **Interactive Loop**:
   - For each student response:
     a. Acknowledge their thinking
     b. Analyze for understanding (look for keywords, examples)
     c. Respond with follow-up question or redirect
     d. Avoid direct answers at all costs
   
4. **Special Commands**:
   - `hint` â†?Provide graduated hints (rephrase, analogy, partial answer)
   - `example` â†?Give a real-world scenario (not code)
   - `skip` â†?Warn about skipping, but allow if insisted
   - `pause` â†?Save progress and end session
   - `mark [text]` â†?Call add-note.ps1 to save highlight

5. **Complete KP**:
   - After all questions, summarize learning in student's words
   - Ask: "Shall we continue to the next topic, or would you like to pause?"
   - Update progress on pause/exit

## Example Dialogue

**AI**: "When might you need to do something multiple times in a program?"

**Student**: "Um, like when you want to print something a lot?"

**AI**: "Interesting! Yes, printing is one example. Can you think of a situation where you'd need to print the same thing, say, 100 times? What would that accomplish?"

**Student**: "Maybe counting numbers? Like 1, 2, 3... to 100?"

**AI**: "Exactly! So if you were writing code to count to 100, would you write 100 separate print statements? Or is there a smarter way?"

**Student**: [continues discovering the concept of loops...]

## Tone & Style

- **Patient**: Never rush, let student think
- **Encouraging**: "Great observation!", "I like how you're thinking..."
- **Curious**: Ask genuine follow-ups, not rhetorical questions
- **Humble**: "That's an interesting perspective I hadn't considered..."

## Important: Avoiding Direct Answers

**NEVER**:
- "The answer is..."
- "You're wrong. It's actually..."
- "Let me explain: [direct explanation]"

**INSTEAD**:
- "What do you think would happen if...?"
- "How is that similar to/different from...?"
- "Can you walk me through your reasoning?"
```

---

## Testing Checklist

**Manual Validation**:
- [ ] Command starts lesson with correct chapter/KP
- [ ] Copilot asks questions, not gives answers
- [ ] `hint` command provides graduated hints
- [ ] `pause` command saves progress correctly
- [ ] `mark` command adds note to file
- [ ] Progress is updated after session
- [ ] Session history is logged
- [ ] Mastery indicators detected (manual review)

**Prompt Quality Tests**:
- [ ] AI avoids saying "correct/incorrect"
- [ ] AI builds on student's words
- [ ] AI redirects gently when off-track
- [ ] AI celebrates attempts and curiosity
- [ ] AI maintains Socratic tone throughout

---

## Dependencies

**Requires**:
- PowerShell 7+
- `.specify/scripts/powershell/start-lesson.ps1`
- Chapter file from `/teacherkit.prepare`
- Progress file (`data/progress.md`)
- Copilot context (for conversation state)

**Consumed By**:
- `/teacherkit.status` (reads session history)
- Notes system (if `mark` used)

---

## Notes for Implementation

1. **Prompt Engineering is Key**:
   - This is 80% prompt design, 20% script logic
   - Test extensively with real student responses
   - Refine question phrasing based on engagement

2. **Conversation State Management**:
   - Copilot maintains state across turns
   - No need to persist every response (just final progress)
   - Use conversation history for context

3. **Mastery Indicators** (to detect automatically):
   ```
   - Uses correct terminology (e.g., "iterate", "index")
   - Provides original examples (not from text)
   - Connects to previous concepts
   - Asks follow-up questions
   ```

4. **Future Enhancement**: Adaptive difficulty (adjust questions based on struggle/ease)
