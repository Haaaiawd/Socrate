# Prompt Contract: Prepare Chapter

**Command Name**: `/teacherkit.prepare`  
**Priority**: P1 (MVP)  
**Phase**: Chapter Preparation  
**User Story**: US2

---

## Command Interface

### Invocation
```
/teacherkit.prepare $CHAPTER_NUMBER
```

### Parameters

| Name | Type | Required | Description | Example |
|------|------|----------|-------------|---------|
| `$CHAPTER_NUMBER` | Integer | Yes | Chapter to prepare (1-indexed) | `3` |

### Example Usage
```
/teacherkit.prepare 3
```

---

## Script Integration

**PowerShell Script Called**: `.specify/scripts/powershell/prepare-chapter.ps1`

**Script Parameters**:
```powershell
param(
    [Parameter(Mandatory=$true)]
    [int]$ChapterNumber,
    
    [Parameter(Mandatory=$true)]
    [string]$OutlinePath,
    
    [string]$OutputDir = "data/chapters",
    
    [switch]$Force  # Overwrite existing chapter
)
```

**Script Responsibilities**:
1. Read outline to find chapter title and sections
2. Extract corresponding chapter content from textbook
3. Break chapter into knowledge points (KPs)
4. Generate Socratic guiding questions for each KP
5. Identify prerequisites from outline dependencies
6. Generate chapter Markdown with YAML frontmatter
7. Save to `data/chapters/[textbook-name]/chapter-[NN].md`
8. Return JSON with chapter metadata

---

## Input Validation

**Pre-Conditions**:
- Outline file must exist (run `/teacherkit.parse` first)
- Chapter number must be valid (1 to total_chapters from outline)
- Textbook source file must be accessible

**Validation Rules**:
```powershell
# Check outline exists
if (-not (Test-Path $OutlinePath)) {
    throw "Outline not found. Run /teacherkit.parse first."
}

# Load outline metadata
$outline = Get-Content $OutlinePath -Raw | ConvertFrom-Yaml
$totalChapters = $outline.total_chapters

# Validate chapter number
if ($ChapterNumber -lt 1 -or $ChapterNumber -gt $totalChapters) {
    throw "Invalid chapter number: $ChapterNumber (valid range: 1-$totalChapters)"
}

# Check if chapter already prepared
$chapterFile = "$OutputDir/chapter-$($ChapterNumber.ToString('00')).md"
if ((Test-Path $chapterFile) -and -not $Force) {
    Write-Warning "Chapter $ChapterNumber already prepared. Use -Force to overwrite."
    return @{ status = "skipped"; path = $chapterFile }
}
```

**Error Handling**:
- **Outline Missing** ‚Ü?Guide user to run `/teacherkit.parse`
- **Invalid Chapter Number** ‚Ü?Show valid range
- **Chapter Already Exists** ‚Ü?Ask if user wants to overwrite
- **Textbook Content Missing** ‚Ü?Check if textbook file was moved

---

## Output Format

### Success Response (JSON)

```json
{
  "status": "success",
  "chapter_path": "data/chapters/intro-python/chapter-03.md",
  "metadata": {
    "chapter_number": 3,
    "chapter_title": "Control Flow",
    "knowledge_point_count": 7,
    "estimated_time": "3 hours",
    "difficulty": "Beginner",
    "prerequisites": ["Chapter 1", "Chapter 2"],
    "prepared": "2025-10-21T15:00:00"
  },
  "knowledge_points": [
    {
      "id": "KP-3.1",
      "title": "Conditional Statements (if-else)",
      "question_count": 3
    },
    ...
  ]
}
```

### Copilot Display Format

```
‚ú?Chapter 3 Prepared!

üìñ **Chapter**: Control Flow  
üéØ **Knowledge Points**: 7  
‚è±Ô∏è **Estimated Time**: 3 hours  
üìä **Difficulty**: Beginner

**Prerequisites**:
- ‚ú?Chapter 1: Getting Started
- ‚ú?Chapter 2: Variables and Data Types

**Knowledge Points Overview**:
1. KP-3.1: Conditional Statements (if-else) - 3 questions
2. KP-3.2: For Loops - 4 questions
3. KP-3.3: While Loops - 3 questions
4. KP-3.4: Break and Continue - 2 questions
5. KP-3.5: Nested Loops - 4 questions
6. KP-3.6: Loop Patterns - 3 questions
7. KP-3.7: Practical Applications - 5 questions

üìÑ **Saved to**: `data/chapters/intro-python/chapter-03.md`

---

**Next Steps**:
1. Review the chapter preparation file
2. Start learning: `/teacherkit.lesson 3`
```

### Error Response (JSON)

```json
{
  "status": "error",
  "error_type": "OutlineMissing",
  "message": "No outline found. Please parse your textbook first.",
  "suggestion": "Run: /teacherkit.parse data/textbooks/your-book.md"
}
```

---

## Knowledge Point Extraction Logic

**Rule-Based Heuristics** (from research.md):

1. **Heading-Based KPs**:
   ```powershell
   # Each ### heading becomes a KP
   $headings = $chapterContent | Select-String -Pattern '^###\s+(.+)$'
   ```

2. **Paragraph Clustering**:
   ```powershell
   # Group paragraphs into concepts (5-10 paragraphs = 1 KP)
   $paragraphs = $chapterContent -split '\n\n'
   $knowledgePoints = @()
   for ($i = 0; $i -lt $paragraphs.Count; $i += 7) {
       $kpContent = $paragraphs[$i..($i+6)] -join '\n\n'
       $knowledgePoints += $kpContent
   }
   ```

3. **Keyword Detection**:
   ```powershell
   # Flag important concepts (definition, example, important, note)
   if ($paragraph -match '(definition|example|important|note):?\s+') {
       $isKP = $true
   }
   ```

**Target**: 80%+ accuracy for MVP (validated manually during testing)

---

## Socratic Question Generation

**Question Template Library** (embedded in script):

```powershell
$questionTemplates = @{
    "concept" = @(
        "Can you explain {concept} in your own words?",
        "What real-world example can you think of for {concept}?",
        "How would you describe {concept} to a friend?"
    ),
    "comparison" = @(
        "What's the difference between {concept1} and {concept2}?",
        "When would you use {concept1} instead of {concept2}?"
    ),
    "application" = @(
        "When might you need to use {concept} in a program?",
        "Can you think of a problem where {concept} would be useful?"
    ),
    "misconception" = @(
        "Why do you think students confuse {concept1} with {concept2}?",
        "What's wrong with thinking {misconception}?"
    )
}
```

**Generation Strategy**:
1. Parse KP title to extract main concept
2. Select 3-5 templates based on KP type
3. Fill placeholders with extracted keywords
4. Add one open-ended "extend your thinking" question

**AI Enhancement** (Post-MVP):
- Use Copilot API to refine questions based on KP content
- Adapt difficulty based on student's progress level

---

## Side Effects

1. **Creates Chapter File**: `data/chapters/[textbook-name]/chapter-[NN].md`
2. **Creates Directory**: Auto-creates `data/chapters/[textbook-name]/` if missing
3. **Logs Activity**: Appends to `.specify/logs/teacher-activity.log`

**No Side Effects On**:
- Outline file (read-only)
- Textbook file (read-only)
- Progress file (not updated until lesson starts)

---

## Success Criteria (from spec.md)

**Functional Requirements Met**:
- FR4: Break chapters into knowledge points
- FR5: Generate Socratic guiding questions
- FR6: Validate prerequisites

**Success Metrics**:
- KP extraction accuracy ‚â?80%
- 3-5 questions per KP
- Preparation time < 10 seconds per chapter

---

## Teaching Prompt Template

Embedded in `.github/prompts/teacherkit.prepare.prompt.md`:

```markdown
---
command: /teacherkit.prepare
description: Prepare a chapter with knowledge points and questions
version: 1.0.0
requires_script: .specify/scripts/powershell/prepare-chapter.ps1
---

# Prepare Chapter Command

You are an AI teaching assistant preparing structured learning materials.

## User Input Expected

```
/teacherkit.prepare [chapter number]
```

## Execution Steps

1. **Validate Input**:
   - Check outline exists (guide to parse textbook if not)
   - Validate chapter number range

2. **Find Current Outline**:
   - Use most recent outline in `data/outlines/`
   - Or ask user to specify if multiple textbooks

3. **Call PowerShell Script**:
   ```powershell
   .specify/scripts/powershell/prepare-chapter.ps1 -ChapterNumber $ARGS[0] -OutlinePath $OUTLINE_PATH
   ```

4. **Display Results**:
   - Show KP overview with question counts
   - Highlight prerequisites if any
   - Provide next step (start lesson)

5. **Handle Errors**:
   - Outline missing ‚Ü?Guide to parse textbook
   - Invalid chapter ‚Ü?Show valid range
   - Already prepared ‚Ü?Offer to overwrite

## Tone & Style

- **Organized**: Present structured information clearly
- **Encouraging**: "Let's prepare your learning materials..."
- **Actionable**: Always show next steps
```

---

## Testing Checklist

**Manual Validation**:
- [ ] Command accepts valid chapter number
- [ ] Script generates chapter file with KPs and questions
- [ ] Questions are Socratic (not direct answers)
- [ ] Prerequisites correctly identified from outline
- [ ] YAML frontmatter includes all required fields
- [ ] Error handling for missing outline
- [ ] Warning for already prepared chapters
- [ ] Copilot displays formatted output

**PowerShell Unit Tests** (Pester):
- [ ] `prepare-chapter.ps1` extracts KPs from sample chapter
- [ ] Script generates 3+ questions per KP
- [ ] Script validates chapter number range
- [ ] Script creates output directory if missing
- [ ] Script handles Force flag correctly

---

## Dependencies

**Requires**:
- PowerShell 7+ with `powershell-yaml` module (for YAML parsing)
- `.specify/scripts/powershell/prepare-chapter.ps1` script exists
- Outline file from `/teacherkit.parse`
- Access to original textbook file
- `data/chapters/` directory (auto-created)

**Consumed By**:
- `/teacherkit.lesson` (reads chapter KPs)
- `/teacherkit.status` (shows preparation progress)

---

## Notes for Implementation

1. **YAML Module Installation**:
   ```powershell
   Install-Module -Name powershell-yaml -Scope CurrentUser
   ```

2. **Zero-Padding Chapter Numbers**:
   ```powershell
   $fileName = "chapter-{0:D2}.md" -f $ChapterNumber  # chapter-03.md
   ```

3. **Difficulty Heuristics**:
   - Chapters 1-3: Beginner
   - Chapters 4-7: Intermediate
   - Chapters 8+: Advanced

4. **Future Enhancement**: Use AI to analyze chapter complexity and adjust difficulty automatically
