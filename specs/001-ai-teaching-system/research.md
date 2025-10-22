# Research: AI Teaching System

**Date**: 2025-10-21  
**Purpose**: Resolve technical unknowns and establish best practices for dual-layer teaching system (CLI + Prompts)

## Research Tasks Completed

### 1. CLI Architecture Decision

**Question**: Should we build a traditional CLI, use pure prompt-driven approach, or adopt a hybrid architecture?

**Research Findings**:
- **Spec-Kit Analysis**: Examined github/spec-kit repository structure
  - **CLI Layer**: Python 3.11+ with Typer framework
    - Commands: `specify init`, `specify config`
    - Installation: `uv tool install` or `uvx --from git+URL`
    - Entry point: `src/specify_cli/__init__.py` with Typer app
    - Features: StepTracker progress, template download, Git init
  - **Prompt Layer**: `.github/prompts/*.prompt.md` files for workflows
    - Pattern: YAML frontmatter + detailed instructions
    - Execution: AI agent reads prompt, calls scripts, processes output
  - **Dual-layer benefit**: Professional setup UX + AI-native workflows

- **GitHub Copilot Capabilities**:
  - Supports custom slash commands via `.vscode/prompts/` directory
  - Can execute PowerShell scripts and parse JSON results
  - Maintains conversation context across multi-turn interactions
  - Perfect for Socratic dialogue with proper prompt design

**Decision**: **Adopt dual-layer architecture (CLI for setup + prompts for teaching)**

**Rationale**: 
1. Proven pattern (spec-kit has 1000+ stars, maintained by GitHub)
2. Best of both worlds: professional installation + AI-native teaching
3. CLI handles one-time setup, prompts handle interactive learning
4. Matches user expectation: "简单的cli，就像是spec-kit"

**Alternatives Considered**:
- Pure CLI approach: Rejected - loses Copilot's conversational strengths for Socratic teaching
- Pure prompt approach: Rejected - poor first-run experience, no `teacherkit init` command
- Standalone desktop app: Rejected - massive scope increase

---

### 2. CLI Implementation Stack

**Question**: What language and framework should power the CLI tool?

**Research Findings**:
- **Spec-Kit Stack Confirmation**:
  - Language: Python 3.11+
  - CLI Framework: Typer (Click-based, type-hinted)
  - Package Manager: uv (Astral's Rust-based tool)
  - Distribution: Git-based (`uv tool install --from git+URL`)
  - Progress UI: Rich library (colored output, progress bars)
  
- **uv Benefits**:
  - 10-100x faster than pip
  - Git-aware (can install from repos directly)
  - No virtualenv confusion (manages isolation automatically)
  - Cross-platform (Windows/macOS/Linux)

- **Typer Benefits**:
  - Automatic help generation
  - Type hints for validation
  - Minimal boilerplate
  - Click ecosystem compatibility

**Decision**: **Python 3.11+ + Typer + uv (exact spec-kit stack)**

**Rationale**:
1. Proven by spec-kit (thousands of users)
2. Professional packaging and installation UX
3. Cross-platform support
4. Fast iteration (uv's speed)
5. Type safety (Typer's type hints)

**Alternatives Considered**:
- PowerShell module: Rejected - harder cross-platform distribution, no uv packaging
- Node.js CLI: Rejected - adds JavaScript to project (Python+PowerShell already present)
- Go CLI: Rejected - compilation overhead, not spec-kit pattern

---

### 3. PowerShell vs. Python for Backend Scripts

**Question**: Should backend scripts (file operations, text processing) be PowerShell or Python?

**Research Findings**:
- **Environment Context**: 
  - User is on Windows (D:\PROJECTALL path)
  - Existing `.specify/scripts/powershell/*.ps1` files already present
  - PowerShell 7+ has cross-platform support

- **Dual-Layer Requirement**:
  - Both CLI (Python) and prompts (Copilot) need same backend operations
  - Options: (1) Python scripts called by both, (2) PowerShell scripts called by both, (3) duplicate logic
  - PowerShell scripts can be called from Python via subprocess

- **Capability Comparison**:
  - **Markdown Parsing**: 
    - PowerShell: Regex + `ConvertFrom-Markdown` cmdlet (sufficient for MVP)
    - Python: `markdown-it-py`, `mistune` (more powerful)
  - **YAML Frontmatter**: 
    - PowerShell: `powershell-yaml` module
    - Python: `python-frontmatter` (cleaner API)
  - **File I/O**: Both handle well

**Decision**: **Use PowerShell 7+ for shared backend scripts**

**Rationale**:
1. Avoids code duplication (both CLI and prompts call same scripts)
2. Consistency with existing `.specify/scripts/`
3. No Python dependency management for scripts
4. Adequate for MVP text processing needs
5. CLI can wrap PowerShell calls via subprocess if needed

**Alternatives Considered**:
- Python-only backend: Rejected - forces CLI to bundle Python script equivalents
- Duplicate logic: Rejected - maintenance nightmare

---

### 4. Knowledge Point Extraction Strategy

**Question**: How to automatically extract knowledge points from textbook chapters?

**Research Findings**:
- **Reviewed Educational Content Structure**:
  - Textbooks typically have: Chapter Title → Section Headings → Paragraphs → Examples
  - Knowledge points often correlate with:
    - Level 2-3 headings (## or ###)
    - Bold/italic terms in text
    - Numbered/bulleted lists
    - Definition-style paragraphs ("X is...", "Y means...")

- **Extraction Approaches**:
  1. **Rule-Based (MVP)**: 
     - Extract all ## and ### headings
     - Include first 1-2 sentences after heading as description
     - Mark difficulty as "Beginner" by default (manual override supported)
  2. **Keyword-Based**: Scan for "definition", "theorem", "principle", "concept"
  3. **NLP-Based (Future)**: Use NER (Named Entity Recognition) to find technical terms

**Decision**: **Rule-based extraction for MVP, with manual review prompt**

**Rationale**:
1. 80% accuracy achievable with simple rules (per SC-012 in spec)
2. Teachers can edit generated chapter.md files if needed
3. Avoids NLP library dependencies
4. Fast processing (< 5 seconds for typical chapter)

**Implementation**:
```powershell
# Pseudocode
function Extract-KnowledgePoints {
    param($ChapterContent)
    
    $headings = $ChapterContent -match "^##+ (.+)$"
    foreach ($heading in $headings) {
        $title = $heading
        $description = Get-FirstSentence -After $heading
        $knowledgePoint = @{
            Title = $title
            Description = $description
            Difficulty = "Beginner"  # Default
            Questions = Generate-SocraticQuestions $title
        }
    }
}
```

---

### 4. Socratic Question Generation

**Question**: How to generate effective guiding questions for each knowledge point?

**Research Findings**:
- **Analyzed User-Provided Teaching Prompt** (`Openai学习提示词.md`):
  - Core principle: "引导用户,不要只是给出答案"
  - Techniques: "使用问题、提示和小步骤"
  - Question types: "检查并强化", "让用户教你"

- **Socratic Method Patterns** (from ChatGPT Study Mode research):
  - **Conceptual questions**: "Can you explain this in your own words?"
  - **Application questions**: "What might happen if...?"
  - **Comparison questions**: "How is this similar to...?"
  - **Causal questions**: "Why do you think...?"

- **Question Template Library**:
  ```
  Level 1 (Understanding): 
    - "What does {concept} mean to you?"
    - "Can you describe {concept} in simple terms?"
  
  Level 2 (Application):
    - "How would you use {concept} to solve...?"
    - "What might happen if we applied {concept} to...?"
  
  Level 3 (Analysis):
    - "What's the relationship between {concept} and {related_concept}?"
    - "Why is {concept} important for...?"
  ```

**Decision**: **Use template-based question generation + AI enhancement**

**Rationale**:
1. PowerShell script generates 2-3 template questions per knowledge point
2. - Templates provide starter questions, then Copilot fills with extracted keywords
- Example: "What is {KP.title}? Can you explain it in your own words?" → "What is a for loop? Can you explain it in your own words?"

2. During `/teacherkit.lesson`, Copilot dynamically adapts questions based on student responses
3. Templates ensure minimum quality; AI provides contextual flexibility

**Implementation**:
- `prepare-chapter.ps1` embeds question templates in chapter.md
- `teaching-prompt-template.md` instructs Copilot to use embedded questions as starting points
- Copilot improvises follow-ups based on student's actual answers

---

### 5. Progress Tracking Schema

**Question**: How to structure progress.md file for efficient updates and queries?

**Research Findings**:
- **Requirements** (from spec FR-011):
  - Track completed chapters
  - Track current position (chapter + knowledge point)
  - Show overall completion percentage
  - Persist session timestamps

- **Format Options**:
  1. **Pure Markdown**: Human-readable but hard to parse
  2. **YAML Frontmatter + Markdown**: Best of both worlds
  3. **JSON**: Machine-readable but not human-friendly

**Decision**: **YAML frontmatter + Markdown table**

**Schema**:
```yaml
---
textbook: "Introduction to Python"
student: "default"  # MVP: single user
started: 2025-10-21
last_session: 2025-10-21T15:30:00
total_chapters: 10
completed_chapters: 2
current_chapter: 3
current_knowledge_point: "Functions - Definition"
completion_percentage: 20
---

# Learning Progress: Introduction to Python

## Chapter Status

| Chapter | Title | Status | Knowledge Points | Last Studied |
|---------|-------|--------|------------------|--------------|
| 1 | Basics | ✓ Complete | 8/8 | 2025-10-21 |
| 2 | Variables | ✓ Complete | 6/6 | 2025-10-21 |
| 3 | Functions | ~ In Progress | 2/10 | 2025-10-21 |
| 4 | Lists | - Not Started | 0/12 | - |
...
```

**Rationale**:
- YAML frontmatter for script parsing (`manage-progress.ps1`)
- Markdown table for human readability
- Single file per textbook (no database needed)
- Easy to version control

---

### 6. Prompt Command Structure (GitHub Copilot)

**Question**: What's the optimal structure for `.github/prompts/*.prompt.md` files?

**Research Findings**:
- **Spec-Kit Pattern Analysis**:
  ```markdown
  ---
  description: "Short description"
  scripts:
    ps: path/to/script.ps1 -Json
  ---
  
  ## User Input
  $ARGUMENTS
  
  ## Outline
  [Step-by-step instructions for AI]
  
  ## Rules
  [Constraints and guidelines]
  ```

- **GitHub Copilot Documentation**:
  - `description` field appears in command palette
  - `scripts` section auto-executes before prompt processing
  - `$ARGUMENTS` placeholder replaced with user input
  - Supports Markdown formatting for rich instructions

**Decision**: **Adopt spec-kit pattern with teaching-specific sections**

**Template Structure**:
```markdown
---
description: "[Command purpose]"
scripts:
  ps: .specify/scripts/powershell/[script-name].ps1 -Json
---

## User Input
$ARGUMENTS

## Teaching Context
[Load current state from progress.md]

## Execution Steps
1. [Step 1]
2. [Step 2]
...

## Socratic Rules
[Educational guidelines from teaching prompt]

## Output Format
[Expected result structure]
```

---

## Technology Decisions Summary

| Decision Area | Choice | Rationale |
|---------------|--------|-----------|
| **Architecture** | Dual-Layer (CLI + Prompts + Scripts) | Proven pattern (spec-kit), professional setup + AI teaching |
| **CLI Framework** | Python 3.11+ with Typer | Matches spec-kit, type-safe, minimal boilerplate |
| **Package Manager** | uv (Astral) | Fast (10-100x pip), Git-aware, cross-platform |
| **CLI Scope** | Minimal (init + config) | Avoid feature creep, teaching stays prompt-driven |
| **Prompt Platform** | VS Code Copilot | Built-in, no API costs, conversational strength |
| **Script Language** | PowerShell 7+ | Shared backend for CLI and prompts, no duplication |
| **Data Format** | Markdown + YAML frontmatter | Human-readable, git-friendly, no database |
| **Knowledge Extraction** | Rule-based (headings + context) | 80% accuracy sufficient for MVP, fast |
| **Question Generation** | Template library + AI adaptation | Ensures quality baseline, allows flexibility |
| **Progress Schema** | YAML + Markdown table | Parseable + readable, single file per textbook |
| **Testing Strategy** | pytest (CLI) + Pester (scripts) + manual (prompts) | Layer-appropriate testing |
| **Distribution** | Git-based via uv | No PyPI needed for MVP, direct install from repo |

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Users lack Python 3.11+ or uv | Medium | High | `teacherkit config` checks prerequisites; quickstart provides install links |
| PowerShell extraction accuracy < 85% | Medium | Medium | Manual review prompt in `/teacherkit.prepare`; teachers can edit chapter.md |
| CLI and prompts drift out of sync | Low | Medium | Both call same PowerShell scripts; integration tests verify consistency |
| Prompt quality varies with Copilot updates | Low | High | Version-lock prompts with date stamps; test after Copilot updates |
| Progress.md merge conflicts in multi-user | Low | Low | Out of scope for MVP; document as known limitation |
| CLI packaging issues on different OSes | Medium | Medium | Test on Windows/macOS/Linux; use uv's cross-platform features |

---

## Open Questions (for Phase 1)

1. **CLI Template Distribution**: Bundle templates in package or download from GitHub releases?
2. **Outline Template Details**: Exact YAML frontmatter fields for outline.md?
3. **Chapter File Naming**: `chapter-01.md` or `chapter-01-introduction.md`?
4. **Note Capture Mechanism**: How does student mark text during Copilot dialogue? (May need VS Code extension for US5)
5. **Error Handling**: Standard error format for script failures called from both CLI and prompts?
6. **CLI Entry Point**: Register `teacherkit` command via pyproject.toml scripts section?

These will be resolved during data-model.md and contracts/ design.
