# Prompt Contract: Manage Notes

**Command Name**: `/teacherkit.notes`  
**Priority**: P2 (Post-MVP)  
**Phase**: Note Taking  
**User Story**: US5

---

## Command Interface

### Invocation
```
/teacherkit.notes $ACTION [$ARGS...]
```

### Parameters

| Name | Type | Required | Description | Example |
|------|------|----------|-------------|---------|
| `$ACTION` | String | Yes | Action: `add`, `view`, `search` | `add` |
| `$ARGS` | Variable | Depends | Arguments for action | `"Remember this!"` |

### Example Usage
```
/teacherkit.notes add "print() requires parentheses"       # Add quick note
/teacherkit.notes view                                      # View all notes
/teacherkit.notes search "loop"                            # Search notes
```

---

## Script Integration

**PowerShell Script Called**: `.specify/scripts/powershell/manage-notes.ps1`

**Script Parameters**:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('add', 'view', 'search')]
    [string]$Action,
    
    [string]$Text = "",           # For 'add' action
    [string]$Query = "",          # For 'search' action
    [string]$Source = "",         # Auto-detected from context
    [string]$NotesPath = "data/notes/"
)
```

**Script Responsibilities**:
1. **Add**: Append note to appropriate notes file with metadata
2. **View**: Read notes file and return formatted list
3. **Search**: Find notes matching query (simple text search)

---

## Actions

### Action: Add Note

**Usage**: `/teacherkit.notes add "[note text]"`

**Script Behavior**:
- Detect current textbook from progress.md
- Detect current chapter/KP from context
- Append to `data/notes/[textbook]-notes.md`
- Include timestamp and source reference

**Output**:
```
�?Note Added!

📝 **Text**: "print() requires parentheses"  
📍 **Source**: Chapter 1, KP-1.3 (First Program)  
🕒 **Time**: 2025-10-21 14:30

Your note has been saved to: `data/notes/intro-python-notes.md`
```

---

### Action: View Notes

**Usage**: `/teacherkit.notes view`

**Script Behavior**:
- Read notes file for current textbook
- Return all notes with metadata
- Group by chapter

**Output**:
```
📔 My Notes: Introduction to Python Programming

**Total Notes**: 15

---

## Chapter 1: Getting Started

### Note #1 - 2025-10-20 14:30
**Source**: KP-1.2 (Installing Python)  
**Text**: "Python 3.11 is recommended for beginners"  
**Tags**: #installation #version

### Note #2 - 2025-10-20 15:00
**Source**: KP-1.3 (First Program)  
**Text**: "print() function displays text to the console"  
**Tags**: #basics #syntax

---

## Chapter 2: Variables

[... more notes ...]

---

**Tip**: Use `/teacherkit.notes search` to find specific notes quickly!
```

---

### Action: Search Notes

**Usage**: `/teacherkit.notes search "[query]"`

**Script Behavior**:
- Search notes file for query string (case-insensitive)
- Return matching notes with context

**Output**:
```
🔍 Search Results for "loop"

**Found**: 3 notes

---

### Note #12 - 2025-10-21 16:00
**Source**: Chapter 3, KP-3.2 (For Loops)  
**Text**: "for loops are best when you know **how many times** to repeat"  
**Match**: [loop]

### Note #14 - 2025-10-21 16:30
**Source**: Chapter 3, KP-3.3 (While Loops)  
**Text**: "while **loops** continue until condition is false"  
**Match**: [loop]

### Note #15 - 2025-10-21 16:45
**Source**: Chapter 3, KP-3.5 (Nested Loops)  
**Text**: "**loop** inside another loop for 2D grids"  
**Match**: [loop]

---

**Tip**: Click the source link to review the context!
```

---

## Side Effects

1. **Adds Note**: Appends to `data/notes/[textbook]-notes.md` (action: add)
2. **Creates Notes File**: Auto-creates if first note for textbook
3. **Logs Activity**: Writes to activity log

**No Side Effects On**:
- Progress file
- Chapter files
- Textbook/outline files

---

## Success Criteria (from spec.md)

**Functional Requirements Met**:
- FR14: Save highlighted text/concepts
- FR15: Attach notes to specific chapters/KPs
- FR16: Retrieve notes later

**Success Metrics**:
- Notes correctly linked to source KP
- Search returns relevant results
- No data loss

---

## Teaching Prompt Template

Embedded in `.github/prompts/teacherkit.notes.prompt.md`:

```markdown
---
command: /teacherkit.notes
description: Add, view, and search learning notes
version: 1.0.0
requires_script: .specify/scripts/powershell/manage-notes.ps1
---

# Notes Command

Help students capture important insights during learning.

## Execution Steps

1. **Parse Action**:
   - Extract action (add/view/search) from user input

2. **Call PowerShell Script**:
   ```powershell
   .specify/scripts/powershell/manage-notes.ps1 -Action $ACTION -Text $TEXT -Query $QUERY
   ```

3. **Display Results**:
   - For 'add': Confirm note saved
   - For 'view': Show all notes organized by chapter
   - For 'search': Show matching notes with context

4. **Provide Tips**:
   - Suggest when to take notes (new concepts, "aha" moments)
   - Remind to review notes periodically

## Tone & Style

- **Supportive**: "Great idea to note that down!"
- **Organized**: Present notes clearly
- **Encouraging**: Celebrate building a knowledge base
```

---

## Testing Checklist

**Manual Validation**:
- [ ] `add` action creates note with correct metadata
- [ ] `view` action displays all notes grouped by chapter
- [ ] `search` action finds matching notes
- [ ] Notes file auto-created if missing
- [ ] Source KP auto-detected from context

**PowerShell Unit Tests**:
- [ ] `manage-notes.ps1` appends notes correctly
- [ ] Script handles YAML frontmatter properly
- [ ] Script validates notes file structure
- [ ] Search returns relevant results

---

## Dependencies

**Requires**:
- PowerShell 7+
- `.specify/scripts/powershell/manage-notes.ps1`
- Progress file (for context detection)
- Notes directory (`data/notes/`)

---

## Notes for Implementation

Priority: P2 (implement after core teaching loop)

**Future Enhancements**:
- Export notes to PDF/markdown
- Tag-based organization
- Spaced repetition reminders
