# Prompt Contract: Parse Textbook

**Command Name**: `/teacherkit.parse`  
**Priority**: P1 (MVP)  
**Phase**: Upload & Outline  
**User Story**: US1

---

## Command Interface

### Invocation
```
/teacherkit.parse $TEXTBOOK_PATH
```

### Parameters

| Name | Type | Required | Description | Example |
|------|------|----------|-------------|---------|
| `$TEXTBOOK_PATH` | String | Yes | Path to uploaded Markdown/text file | `data/textbooks/intro-python.md` |

### Example Usage
```
/teacherkit.parse data/textbooks/intro-python.md
```

---

## Script Integration

**PowerShell Script Called**: `.specify/scripts/powershell/parse-textbook.ps1`

**Script Parameters**:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [string]$TextbookPath,
    
    [string]$OutputDir = "data/outlines",
    
    [switch]$Verbose
)
```

**Script Responsibilities**:
1. Validate textbook file exists and is readable
2. Extract all heading levels (#, ##, ###) to build hierarchical structure
3. Count estimated knowledge points per section
4. Calculate study time estimates (heuristic: 500 words = 1 hour)
5. Generate outline Markdown with YAML frontmatter
6. Save to `data/outlines/[textbook-name]-outline.md`
7. Return JSON with outline path and metadata

---

## Input Validation

**Pre-Conditions**:
- Textbook file must exist at `$TEXTBOOK_PATH`
- File must be UTF-8 encoded text (.md or .txt)
- File size â‰?50MB (soft limit, warning if > 10MB)

**Validation Rules**:
```powershell
# Check file exists
if (-not (Test-Path $TextbookPath)) {
    throw "Textbook not found at: $TextbookPath"
}

# Check file extension
if ($TextbookPath -notmatch '\.(md|txt)$') {
    Write-Warning "Unusual file extension. Expected .md or .txt"
}

# Check file size
$sizeBytes = (Get-Item $TextbookPath).Length
if ($sizeBytes -gt 50MB) {
    throw "File too large (>50MB). Please split into smaller files."
}
if ($sizeBytes -gt 10MB) {
    Write-Warning "Large file detected (>10MB). Parsing may take time..."
}
```

**Error Handling**:
- **File Not Found** â†?Return error message, suggest checking path
- **Empty File** â†?Return error message, file must have content
- **No Headings** â†?Return warning, generate flat outline
- **Encoding Issues** â†?Attempt UTF-8 with BOM fallback, warn if characters corrupted

---

## Output Format

### Success Response (JSON)

Returned by PowerShell script, displayed by Copilot prompt:

```json
{
  "status": "success",
  "outline_path": "data/outlines/intro-python-outline.md",
  "metadata": {
    "textbook": "intro-python.md",
    "total_chapters": 10,
    "total_sections": 45,
    "estimated_hours": 40,
    "generated": "2025-10-21T14:30:00"
  },
  "chapters": [
    {
      "number": 1,
      "title": "Getting Started",
      "sections": 3,
      "knowledge_points": 5
    },
    ...
  ]
}
```

### Copilot Display Format

After receiving script output, prompt should display:

```
âœ?Textbook Parsed Successfully!

ðŸ“– **Source**: intro-python.md  
ðŸ“‹ **Outline Generated**: data/outlines/intro-python-outline.md

**Course Structure**:
- **Chapters**: 10
- **Sections**: 45
- **Estimated Study Time**: 40 hours

**Chapter Preview**:
1. Getting Started (3 sections, ~2 hours)
2. Variables and Data Types (4 sections, ~3 hours)
3. Control Flow (5 sections, ~3 hours)
...

---

**Next Steps**:
1. Review the outline: Open `data/outlines/intro-python-outline.md`
2. Prepare first chapter: `/teacherkit.prepare 1`
```

### Error Response (JSON)

```json
{
  "status": "error",
  "error_type": "FileNotFound",
  "message": "Textbook not found at: data/textbooks/missing.md",
  "suggestion": "Check the file path. Did you forget to upload the textbook?"
}
```

---

## Side Effects

1. **Creates Outline File**: `data/outlines/[textbook-name]-outline.md` with YAML frontmatter + Markdown body
2. **Updates Progress**: (Optional) Initialize progress.md if this is first textbook
3. **Logs Activity**: Writes to `.specify/logs/teacher-activity.log` with timestamp

**No Side Effects On**:
- Original textbook file (read-only)
- Existing outlines (unless same name â†?overwrite with confirmation)
- Chapter files (not created yet)

---

## Success Criteria (from spec.md)

**Functional Requirements Met**:
- FR1: Parse uploaded Markdown files
- FR2: Extract hierarchical chapter structure
- FR3: Generate structured outline

**Success Metrics**:
- Outline accuracy â‰?90% (chapters match textbook)
- Processing time < 5 seconds for 10MB file
- No crashes on valid UTF-8 input

---

## Teaching Prompt Template

Embedded in `.github/prompts/teacherkit.parse.prompt.md`:

```markdown
---
command: /teacherkit.parse
description: Parse a textbook and generate learning outline
version: 1.0.0
requires_script: .specify/scripts/powershell/parse-textbook.ps1
---

# Parse Textbook Command

You are an AI teaching assistant helping a student organize their learning materials.

## User Input Expected

The student will provide:
```
/teacherkit.parse [path to textbook file]
```

## Execution Steps

1. **Validate Input**:
   - Confirm file path is provided
   - Check file exists using PowerShell script

2. **Call PowerShell Script**:
   ```powershell
   .specify/scripts/powershell/parse-textbook.ps1 -TextbookPath $ARGS[0] -Verbose
   ```

3. **Display Results**:
   - Show success message with course structure preview
   - Provide next steps (review outline, prepare chapter)

4. **Handle Errors**:
   - If file not found â†?Ask student to verify path
   - If parsing fails â†?Show error details and suggest fixes

## Tone & Style

- **Encouraging**: "Great! Let's organize your learning materials..."
- **Clear**: Use emojis (ðŸ“– ðŸ“‹ âœ? and structured output
- **Actionable**: Always end with "Next Steps" section
```

---

## Testing Checklist

**Manual Validation**:
- [ ] Command accepts valid textbook path
- [ ] Script generates outline file with correct structure
- [ ] Outline includes YAML frontmatter with metadata
- [ ] Chapter numbers are sequential (1, 2, 3...)
- [ ] Estimated study times are reasonable
- [ ] Error handling works for missing files
- [ ] Warning shown for large files (>10MB)
- [ ] Copilot displays formatted output, not raw JSON

**PowerShell Unit Tests** (Pester):
- [ ] `parse-textbook.ps1` parses sample Markdown correctly
- [ ] Script handles UTF-8 encoding
- [ ] Script rejects files >50MB
- [ ] Script creates output directory if missing
- [ ] Script returns valid JSON structure

---

## Dependencies

**Requires**:
- PowerShell 7+ (for cross-platform support)
- `.specify/scripts/powershell/parse-textbook.ps1` script exists
- `data/textbooks/` directory exists (student creates)
- `data/outlines/` directory (auto-created by script)

**Consumed By**:
- `/teacherkit.prepare` (reads generated outline)
- `/teacherkit.status` (displays outline metadata)

---

## Notes for Implementation

1. **Heading Extraction Pattern**:
   ```powershell
   $content = Get-Content $TextbookPath -Raw
   $headings = $content | Select-String -Pattern '^(#{1,6})\s+(.+)$' -AllMatches
   ```

2. **Knowledge Point Heuristic**:
   - 1 chapter = ~5-10 knowledge points
   - Count paragraphs between headings as proxy

3. **Study Time Formula**:
   ```
   reading_time = word_count / 250 words per minute
   practice_time = reading_time * 1.5
   total_time = reading_time + practice_time
   ```

4. **Future Enhancement**: Use AI to summarize each chapter for better KP estimates
