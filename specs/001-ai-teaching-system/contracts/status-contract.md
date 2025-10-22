# Prompt Contract: Check Status

**Command Name**: `/teacherkit.status`  
**Priority**: P2 (Post-MVP)  
**Phase**: Progress Tracking  
**User Story**: US4

---

## Command Interface

### Invocation
```
/teacherkit.status [$DETAIL_LEVEL]
```

### Parameters

| Name | Type | Required | Description | Example |
|------|------|----------|-------------|---------|
| `$DETAIL_LEVEL` | String | No | Level of detail: `summary`, `chapters`, `full` (default: `summary`) | `chapters` |

### Example Usage
```
/teacherkit.status                # Quick summary
/teacherkit.status chapters       # Chapter-by-chapter breakdown
/teacherkit.status full          # Full report with session history
```

---

## Script Integration

**PowerShell Script Called**: `.specify/scripts/powershell/get-status.ps1`

**Script Parameters**:
```powershell
param(
    [ValidateSet('summary', 'chapters', 'full')]
    [string]$DetailLevel = 'summary',
    
    [string]$ProgressPath = "data/progress.md"
)
```

**Script Responsibilities**:
1. Read progress.md to get current state
2. Calculate completion percentages
3. Format data based on detail level
4. Return JSON with progress metrics

---

## Output Format

### Summary Level

```
📊 Learning Progress Summary

📖 **Current Textbook**: Introduction to Python Programming  
📍 **Current Chapter**: Chapter 3 - Control Flow (KP-3.2)  
⏱️ **Total Study Time**: 5.5 hours  
📈 **Overall Progress**: 25% (3/10 chapters completed)  
🔥 **Study Streak**: 2 days

**Recent Activity**:
- Today: 45 minutes on Chapter 3
- Yesterday: 1.5 hours on Chapter 2

---

**Next Up**: Complete KP-3.2 (For Loops) �?Continue to KP-3.3
```

### Chapters Level

```
📊 Chapter Progress: Introduction to Python Programming

| Ch# | Title | Status | Progress | Last Studied | Time |
|-----|-------|--------|----------|--------------|------|
| 1 | Getting Started | �?| 5/5 KPs | 2025-10-20 | 2.0h |
| 2 | Variables | �?| 8/8 KPs | 2025-10-20 | 2.5h |
| 3 | Control Flow | ~ | 1/7 KPs | 2025-10-21 | 1.0h |
| 4 | Functions | - | 0/10 KPs | - | - |
| 5 | Lists | - | 0/12 KPs | - | - |
| ... | ... | ... | ... | ... | ... |

**Legend**: �?Complete | ~ In Progress | - Not Started

**Total**: 13/70 knowledge points mastered (19%)
```

### Full Level

Includes everything above plus:
- Session history (last 10 sessions)
- Time distribution chart (text-based)
- Recommendations for review

---

## Side Effects

**None** - This is a read-only command. No files are modified.

---

## Success Criteria (from spec.md)

**Functional Requirements Met**:
- FR11: Display current learning position
- FR12: Show chapter completion status
- FR13: Calculate overall progress percentage

**Success Metrics**:
- Accurate progress calculation (matches actual state)
- Display time < 2 seconds

---

## Teaching Prompt Template

Embedded in `.github/prompts/teacherkit.status.prompt.md`:

```markdown
---
command: /teacherkit.status
description: Display learning progress and achievements
version: 1.0.0
requires_script: .specify/scripts/powershell/get-status.ps1
---

# Status Command

Show the student their learning progress in an encouraging way.

## Execution Steps

1. **Call PowerShell Script**:
   ```powershell
   .specify/scripts/powershell/get-status.ps1 -DetailLevel $ARGS[0]
   ```

2. **Display Results**:
   - Use emojis to make it visually appealing
   - Highlight achievements (completed chapters, streak)
   - Show next steps

3. **Provide Encouragement**:
   - Celebrate progress, even if small
   - Motivate to continue
   - Suggest next action

## Tone & Style

- **Celebratory**: "You've completed 3 chapters! 🎉"
- **Motivating**: "You're 25% through the course—keep going!"
- **Clear**: Use tables and structured output
```

---

## Testing Checklist

**Manual Validation**:
- [ ] Command displays correct progress data
- [ ] Percentages calculated correctly
- [ ] Chapter status matches actual state
- [ ] Study time totals are accurate
- [ ] Different detail levels work

**PowerShell Unit Tests**:
- [ ] `get-status.ps1` parses progress.md correctly
- [ ] Script calculates percentages accurately
- [ ] Script handles missing progress file gracefully

---

## Dependencies

**Requires**:
- PowerShell 7+
- `.specify/scripts/powershell/get-status.ps1`
- Progress file (`data/progress.md`)

---

## Notes for Implementation

Priority: P2 (implement after MVP core loop works)
