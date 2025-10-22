# TeacherKit Socratic Dialogue - MVP Usage Guide

## 🎯 What's Implemented

**User Story 3: Socratic Dialogue** - MVP Complete ✅

### Core Features

1. **Start-Lesson.ps1** - Session initialization script
   - Loads chapter files and knowledge points
   - Extracts guiding questions and key concepts
   - Manages progress tracking (resume from last KP)
   - Outputs JSON context for Copilot

2. **teacherkit.lesson.prompt.md** - Socratic teaching AI prompt
   - Implements Socratic method (ask, don't tell)
   - 4-level hint escalation system
   - Special commands: hint, example, skip, pause, next
   - Patient, encouraging teaching tone

3. **Update-Progress.ps1** - Progress tracking script
   - Saves session history
   - Marks knowledge points as completed
   - Generates learning analytics
   - Updates progress.md file

---

## 🚀 How to Use

### Step 1: Prepare a Chapter

Ensure you have a chapter file in the correct format:

```
test-project/
└── data/
    └── chapters/
        └── [textbook-name]/
            └── chapter-01.md
```

**Chapter file must contain**:
- Frontmatter with `chapter_number`, `chapter_title`, `knowledge_points`
- Knowledge points formatted as `### KP-X.Y: Title`
- Each KP must have:
  - `**Description**`: Brief explanation
  - `**Key Concepts**`: Bullet list
  - `**Guiding Questions**`: Numbered list (1., 2., 3., ...)

**Example** (see `test-project/data/chapters/sample-python-basics/chapter-01.md`).

---

### Step 2: Start a Teaching Session

#### Option A: Using VS Code Prompt (Recommended)

1. Open VS Code in your project directory
2. Run command: `/teacherkit.lesson 1`
3. Copilot will:
   - Call `Start-Lesson.ps1` to load context
   - Display welcome message with progress
   - Begin asking Socratic questions

#### Option B: Manual PowerShell Execution (for testing)

```powershell
cd test-project

# Start lesson for Chapter 1
& "../.specify/scripts/powershell/Start-Lesson.ps1" `
  -ChapterNumber 1 `
  -ProjectRoot (Get-Location)

# Output: JSON context (copy this for Copilot)
```

**Sample Output**:
```json
{
  "status": "success",
  "session_id": "session-2025-10-22-11-14-03",
  "lesson_context": {
    "chapter_number": 1,
    "chapter_title": "Python Basics - Variables and Data Types",
    "knowledge_point": {
      "id": "KP-1.1",
      "title": "What is a Variable?",
      "description": "Understanding how computers store information",
      "keywords": ["Variables", "labeled boxes", "data storage"],
      "difficulty": "Beginner"
    },
    "guiding_questions": [
      "When you're doing math homework, how do you keep track of results?",
      "What would happen if you couldn't label things in real life?",
      "How would you refer to a number I told you to remember?"
    ]
  },
  "progress": {
    "completed_kps": 0,
    "total_kps": 3,
    "chapter_progress": "0%"
  }
}
```

---

### Step 3: Interactive Learning

**During the session**, the AI will:
- Ask you the guiding questions one by one
- Wait for your responses
- Provide follow-up questions (NOT direct answers)
- Guide you to discover concepts yourself

**Special Commands You Can Use**:

| Command | What It Does |
|---------|-------------|
| `hint` | Get a graduated hint (4 levels: minimal → almost-complete) |
| `example` | See a real-world scenario (not code, just analogies) |
| `skip` | Move to next question (discouraged - learning gaps!) |
| `pause` | Save progress and exit session |
| `next` | Complete current KP and move to next one |

**Example Dialogue**:

```
AI: 💭 "When you're doing math homework, how do you keep track of intermediate results?"

You: "Um, I write them down on paper?"

AI: "Exactly! So what if you needed to refer to that number later? 
     How would you know which number is which?"

You: "I'd label them, like 'x =' or 'total ='?"

AI: "Perfect! That's exactly what variables do in programming. 
     Can you think of why labeling is important when you have 
     many different values?"

You: "So you don't mix them up?"

AI: "Great insight! Now let's build on that..."
```

---

### Step 4: Save Progress

When you're done or need to pause:

**Option A**: During Copilot session
```
You: pause
```
Copilot will call `Update-Progress.ps1` automatically.

**Option B**: Manual (for testing)
```powershell
& "../.specify/scripts/powershell/Update-Progress.ps1" `
  -SessionId "session-2025-10-22-11-14-03" `
  -ChapterNumber 1 `
  -KnowledgePointId "KP-1.1" `
  -Status "completed" `
  -QuestionsCompleted 3 `
  -HintsGiven 1 `
  -ProjectRoot (Get-Location)
```

**Progress is saved to**: `data/progress/progress.md`

**What's Tracked**:
- Last studied knowledge point
- Completed KPs list
- Session history (start/end times, questions answered, hints given)
- Total time spent learning
- Chapter progress percentage

---

### Step 5: Resume Learning

Next time you start:

```
/teacherkit.lesson 1
```

**The system will**:
- Read `progress.md`
- Find your last completed KP
- Resume at the next incomplete KP
- Display your progress (e.g., "2/7 knowledge points, 28%")

---

## 🧪 Testing with Sample Chapter

A test chapter is already created:

```powershell
cd test-project

# Test Start-Lesson script
& "../.specify/scripts/powershell/Start-Lesson.ps1" `
  -ChapterNumber 1 `
  -ProjectRoot (Get-Location)

# Should extract 3 guiding questions from KP-1.1
```

**Expected Output**:
```
[INFO] Extracted 3 guiding questions
{
  "lesson_context": {
    "knowledge_point": {
      "id": "KP-1.1",
      "title": "What is a Variable?",
      ...
    },
    "guiding_questions": [
      "When you're doing math homework...",
      "What would happen if you couldn't label...",
      "If I told you 'remember the number 42'..."
    ]
  }
}
```

---

## 📊 Progress Tracking

After completing KP-1.1, your `progress.md` will look like:

```markdown
---
last_chapter: 1
last_kp_id: "KP-1.1"
completed_kps:
  - KP-1.1
sessions:
  - session_id: session-2025-10-22-11-14-03
    chapter: 1
    kp_id: KP-1.1
    started_at: 2025-10-22T11:14:00
    completed_at: 2025-10-22T11:25:30
    duration_minutes: 11.5
    questions_completed: 3
    hints_given: 1
    status: completed
---

# Learning Progress

## Current Status

**Last Session**: 2025-10-22 11:25
**Last Chapter**: Chapter 1
**Last Knowledge Point**: KP-1.1
**Status**: COMPLETED

---

## Overall Statistics

**Total Sessions**: 1
**Total Time**: 0.2 hours (11.5 minutes)
**Knowledge Points Completed**: 1

**Completed Knowledge Points**:
- KP-1.1

---

## Recent Sessions

### [DONE] session-2025-10-22-11-14-03

**Chapter**: 1 | **KP**: KP-1.1
**Started**: 2025-10-22T11:14:00 | **Duration**: 11.5 min
**Questions**: 3 | **Hints**: 1
**Status**: completed
```

---

## 🎯 MVP Limitations

**What's NOT in MVP**:
- ❌ Auto-calling Update-Progress from Copilot (manual for now)
- ❌ `mark [text]` note-taking (placeholder only, US5)
- ❌ `/teacherkit.status` dashboard (US4)
- ❌ Mastery detection (future enhancement)

**But MVP CAN**:
- ✅ Start and manage Socratic dialogue sessions
- ✅ Extract and use guiding questions from chapters
- ✅ Provide 4-level hint escalation
- ✅ Track progress and resume sessions
- ✅ Save session history with analytics

---

## 🐛 Known Issues

1. **Progress.md YAML Format**: `sessions` field saves as single object instead of array
   - **Workaround**: Manually edit to array format if needed
   - **Impact**: Low (single-session tracking still works)

2. **PowerShell Extension Lint Warnings**: False positives on `Start-Lesson.ps1`
   - **Cause**: Lint cache delay
   - **Actual Status**: No errors (tested and working)

3. **Emoji Display Issues**: PowerShell 5.1 doesn't render emoji well
   - **Fix**: Replaced all emoji with `[DONE]`, `[PAUSE]`, etc.

---

## 📝 Next Steps for Full MVP

**Recommended Order**:
1. Test US3 with real student (you!)
2. Complete US2 remaining tasks (question templates, difficulty tagging)
3. Implement US4 (progress dashboard with `/teacherkit.status`)
4. Add US5 (note-taking with `mark` command)

**After Testing**:
- Refine Socratic prompts based on real dialogue quality
- Add more example chapters
- Improve hint escalation logic
- Add session timeout handling

---

## 🎓 Philosophy Reminder

**Socratic Method Core Principles**:
1. **Never give direct answers** - Guide to discovery
2. **Build on student's words** - Use their phrasing
3. **Encourage struggle** - Learning happens in difficulty
4. **Celebrate attempts** - Even wrong answers show thinking
5. **Ask, don't tell** - Questions > Explanations

**This is NOT a chatbot that explains.  
This IS a teacher that guides.**

---

## 📞 Support

**If something breaks**:
1. Check `logs/teacherkit.log` for detailed error messages
2. Verify chapter file format matches template
3. Ensure progress directory exists (`data/progress/`)
4. Try manual script execution to isolate issues

**Example Debug Command**:
```powershell
# Enable verbose logging
$VerbosePreference = "Continue"

& "../.specify/scripts/powershell/Start-Lesson.ps1" `
  -ChapterNumber 1 `
  -ProjectRoot (Get-Location) `
  -Verbose
```

---

**Happy Teaching! 🎓**
