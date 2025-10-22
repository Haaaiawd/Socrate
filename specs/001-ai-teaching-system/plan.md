# Implementation Plan: AI Teaching System

**Branch**: `001-ai-teaching-system` | **Date**: 2025-10-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-ai-teaching-system/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

**Primary Requirement**: Build a Socratic teaching system where students upload textbooks, AI generates structured learning plans, prepares chapters with knowledge points and guiding questions, then conducts interactive dialogue sessions following pedagogical best practices.

**Technical Approach**: **Dual-Layer Architecture** combining a lightweight CLI tool with prompt-driven commands:

1. **CLI Layer** (`teacherkit`): Python-based tool (using Typer framework) for repository initialization and configuration management, following the spec-kit pattern. Installed via `uv tool install teacherkit --from git+<repo>` or invoked with `uvx --from git+<repo> teacherkit init <project>`.

2. **Prompt Command Layer** (`/teacherkit.*`): Markdown prompt files in `.github/prompts/` that define AI teaching behaviors and orchestrate PowerShell scripts for file operations. Executed through GitHub Copilot Chat for interactive learning workflows.

3. **Script Layer**: PowerShell 7+ scripts serve as the common backend, called by both CLI (for initialization) and prompt commands (for teaching operations). Handle file I/O, text processing, and template rendering.

All student data (textbooks, outlines, chapters, notes, progress) is stored as Markdown files. This architecture balances professional tooling (uv/Python CLI) with AI-native interaction (prompt commands), enabling rapid development and natural extensibility to other AI platforms (Claude Code, Cursor).

## Technical Context

**Architecture**: Dual-Layer (CLI + Prompt Commands)  
**CLI Tool**: Python 3.11+ with Typer framework (installed via uv package manager)  
**Command Layer**: Markdown prompt files in `.github/prompts/` (GitHub Copilot `/teacherkit.*` commands)  
**Script Layer**: PowerShell 7+ (file I/O, text processing, template rendering - shared by CLI and prompts)  
**Storage**: Markdown files with YAML frontmatter (no database)  
**AI Execution**: GitHub Copilot Chat (no direct OpenAI API integration needed)  
**Testing Strategy**: 
- Python CLI: Unit tests with pytest
- PowerShell scripts: Pester unit tests
- Prompt commands: Manual validation checklists (MVP phase)
**Target Platform**: Cross-platform (Windows/macOS/Linux) with PowerShell 7+, VS Code with GitHub Copilot extension  
**Project Type**: Hybrid - Educational Tool with CLI + Prompt Command Collection  
**Performance Goals**: 
- Repository initialization: < 10 seconds
- File parsing: < 2 minutes for 5MB textbook
- Command response: < 3 seconds for file operations, < 10 seconds for AI dialogue
**Constraints**: 
- Single-user mode (MVP)
- Requires active internet for Copilot AI features and CLI installation (uv)
- English-language textbooks only (MVP)
- Python 3.11+ and PowerShell 7+ required
**Scale/Scope**: 
- CLI: 2 commands (init, config)
- Prompt commands: 5 teaching commands (/teacherkit.parse, /teacherkit.prepare, /teacherkit.lesson, /teacherkit.status, /teacherkit.notes)
- PowerShell scripts: 6-8 utility scripts
- Support 1 student, unlimited textbooks
- No concurrent session handling needed

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Principle Compliance Checklist**:

- [x] **Markdown-First Storage**: YES - All data stored as `.md` files in `data/` directory. No database.
- [x] **CLI-First Interface**: YES - Dual-layer: Python CLI (`teacherkit init/config`) for setup + prompt commands (`/teacherkit.*`) for teaching. Both layers provide command-driven UX.
- [x] **Test-Driven Development**: YES - Python CLI and PowerShell scripts have unit tests (pytest + Pester). Prompt quality validated manually (adapted TDD for prompt engineering).
- [x] **AI-Aware Code Quality**: YES - Prompt files are inherently AI-readable. Python CLI uses type hints and docstrings. PowerShell scripts follow best practices.
- [x] **Incremental MVP Approach**: YES - 3 P1 user stories form MVP (parse→prepare→teach). P2/P3 deferred. CLI starts minimal (init/config).
- [x] **Educational Flow Integrity**: YES - User-provided teaching prompt template enforces Socratic method. Context loading in prompts.
- [x] **Observability & Debuggability**: YES - CLI logs to console. PowerShell scripts log to `logs/`. Copilot conversations are traceable in VS Code.

**Domain Constraints**:

- [x] Textbook processing follows supported formats (Markdown, plain text for MVP)
- [x] Learning plan generates hierarchical outline (Course → Chapters → Sections → Knowledge Points)
- [x] Lesson delivery uses conversational AI with educational prompts (user-provided template integrated)
- [x] Progress tracking persists across sessions (progress.md file updated by scripts)

**Quality Gates**:

- [x] Code coverage target: 80% minimum - Applies to Python CLI (pytest) and PowerShell scripts (Pester). Prompt commands use manual validation checklists (see Phase 8 quality verification tasks).
- [x] All tests passing before merge - PowerShell Pester tests + Python pytest + manual prompt validation
- [x] Complexity justifications documented if principles violated (see Complexity Tracking below)

## Project Structure

### Documentation (this feature)

```
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

**Dual-Layer Architecture** (CLI + Prompts + Scripts):

```
Teacher/
├── src/
│   └── teacherkit_cli/                     # Python CLI tool (Layer 1: Setup)
│       ├── __init__.py                     # CLI entry point (Typer app)
│       ├── commands/
│       │   ├── __init__.py
│       │   ├── init.py                     # teacherkit init <project>
│       │   └── config.py                   # teacherkit config
│       └── utils/
│           ├── __init__.py
│           ├── git.py                      # Git operations (init, clone)
│           ├── template.py                 # Template download from GitHub
│           └── progress.py                 # StepTracker for progress display
├── .vscode/
│   └── prompts/                            # Layer 2: Teaching Interface
│       ├── teacherkit.parse.prompt.md      # US1: Parse textbook → outline
│       ├── teacherkit.prepare.prompt.md    # US2: Extract knowledge points
│       ├── teacherkit.lesson.prompt.md     # US3: Socratic dialogue
│       ├── teacherkit.status.prompt.md     # US4: Progress tracking
│       └── teacherkit.notes.prompt.md      # US5: Note management
├── .specify/
│   ├── scripts/
│   │   └── powershell/                     # Layer 3: Shared Backend
│   │       ├── check-prerequisites.ps1     # Used by CLI + prompts
│   │       ├── Parse-Textbook.ps1          # MD parsing, outline generation
│   │       ├── Prepare-Chapter.ps1         # Knowledge point extraction
│   │       ├── Start-Lesson.ps1            # Session initialization
│   │       ├── Get-Status.ps1              # Progress tracking updates
│   │       └── Manage-Notes.ps1            # Note capture and retrieval
│   └── templates/                          # Output templates
│       ├── outline-template.md             # Outline structure with YAML
│       ├── chapter-template.md             # Chapter + knowledge points
│       ├── teaching-prompt-template.md     # Socratic dialogue rules
│       └── progress-template.md            # Progress tracking format
├── data/                                   # User data (created by CLI init)
│   ├── textbooks/                          # Original textbook files
│   ├── outlines/                           # Generated outlines
│   ├── chapters/                           # Prepared chapters
│   ├── notes/                              # Student highlights
│   └── progress.md                         # Learning progress
├── logs/                                   # Script execution logs
├── tests/
│   ├── python/                             # CLI tool tests (pytest)
│   │   ├── test_init.py
│   │   ├── test_config.py
│   │   └── conftest.py
│   └── powershell/                         # Script tests (Pester)
│       ├── parse-textbook.Tests.ps1
│       ├── prepare-chapter.Tests.ps1
│       └── manage-progress.Tests.ps1
├── pyproject.toml                          # Python package metadata
├── README.md
└── .gitignore
```

**Structure Decision**: 

This is a **Hybrid Educational Tool** combining:

1. **CLI Layer** (`src/teacherkit_cli/`): Python + Typer for professional setup experience
   - Repository initialization (`teacherkit init`)
   - Configuration checks (`teacherkit config`)
   - Follows spec-kit pattern: uv packaging, StepTracker progress, template distribution

2. **Prompt Layer** (`.vscode/prompts/`): Markdown commands for AI-native teaching
   - Parse textbook (`/teacherkit.parse`)
   - Prepare chapters (`/teacherkit.prepare`)
   - Conduct lessons (`/teacherkit.lesson`)
   - Track progress (`/teacherkit.status`)
   - Manage notes (`/teacherkit.notes`)

3. **Script Layer** (`.specify/scripts/powershell/`): PowerShell 7+ utilities shared by both layers
   - File I/O operations (read/write Markdown + YAML)
   - Knowledge point extraction (rule-based heuristics)
   - Progress tracking updates
   - Session management

This architecture prioritizes:
- **Professional UX**: CLI for installation/setup (like spec-kit)
- **AI-Native Teaching**: Prompt commands for interactive learning (leveraging Copilot's conversational strength)
- **Code Reuse**: PowerShell scripts serve both CLI and prompts
- **Simplicity**: 2 CLI commands + 5 prompts + 6 scripts vs. monolithic application

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Dual-layer architecture (CLI + Prompts) | Setup complexity demands professional CLI (like spec-kit), but teaching interaction benefits from AI-native prompts. Hybrid approach provides best of both worlds. | Pure CLI approach: Would require complex terminal UI for Socratic dialogue, losing Copilot's conversational strengths. Pure prompt approach: Poor first-run experience, no `teacherkit init` command for professional onboarding. |
| PowerShell backend for both layers | Cross-platform scripts handle file I/O for CLI and prompts, avoiding code duplication. Existing `.specify/scripts/` establishes precedent. | Python-only approach: Would force CLI to bundle PowerShell script equivalents (more code). JavaScript/Node.js: Adds third language to project, increases complexity. |
| Manual testing for prompts (TDD partial) | Automated prompt testing requires complex harness to simulate Copilot responses. MVP uses manual validation checklist. CLI gets full pytest coverage. | Fully automated TDD for AI prompts: Would need mock Copilot API, expected output fixtures (fragile), semantic similarity checks. Overhead exceeds MVP benefit. |
| Python CLI instead of single-language solution | Python + Typer + uv provides professional packaging matching spec-kit expectations. Cross-platform installation via uv familiar to target users. | PowerShell-only module: Lacks uv packaging, harder cross-platform distribution. Pure Bash: Windows users would need WSL/Git Bash. Node.js CLI: Not spec-kit pattern. |

---

## Phase 0: Research & Technical Decisions

**Date Completed**: 2025-10-21  
**Output Artifact**: [research.md](./research.md)

### Research Tasks Completed

1. **CLI Architecture Feasibility**
   - **Question**: Should we build a traditional CLI or use prompt-driven approach?
   - **Finding**: Dual-layer architecture optimal - Python CLI (like spec-kit) for setup, prompt commands for teaching. Researched github/spec-kit: confirmed Python+Typer+uv pattern with template distribution, StepTracker progress, and cross-platform support.
   - **Decision**: Implement `teacherkit` CLI (init/config) + `/teacherkit.*` prompts (teaching workflow).

2. **CLI Implementation Stack**
   - **Question**: What language/framework for CLI tool?
   - **Finding**: spec-kit uses Python 3.11+ with Typer framework, packaged via uv. This provides: professional installation UX (`uv tool install`), cross-platform support, progress tracking (StepTracker), template management from GitHub.
   - **Decision**: Python 3.11+ + Typer + uv (exact spec-kit stack). Minimal scope: 2 commands (init, config).

3. **PowerShell vs. Python for File Operations**
   - **Question**: Should backend scripts be PowerShell or Python?
   - **Finding**: PowerShell 7+ is cross-platform, already used in `.specify/scripts/`, handles Markdown/YAML well. Can be called from both Python CLI and prompt commands, avoiding duplication.
   - **Decision**: PowerShell 7+ for MVP. Shared by CLI and prompts. Python wrappers only if subprocess overhead becomes issue.

4. **Knowledge Point Extraction Strategy**
   - **Question**: How to automatically break chapters into knowledge points (KPs) without AI API?
   - **Finding**: Rule-based heuristics sufficient for MVP: heading detection (###), paragraph clustering (5-10 paragraphs = 1 KP), keyword flagging ("definition", "example").
   - **Decision**: Implement rule-based extraction with 80%+ accuracy target. Manual refinement allowed. Future: AI-assisted extraction.

5. **Socratic Question Generation**
   - **Question**: How to generate guiding questions without pre-training custom models?
   - **Finding**: Template library approach works well. Create question templates (concept, comparison, application, misconception) and fill with extracted keywords. User-provided teaching prompt enhances AI adaptation.
   - **Decision**: Template-based generation + AI refinement during lesson (Copilot adapts based on context).

6. **Progress Tracking Schema**
   - **Question**: What's the minimal data structure to track learning progress?
   - **Finding**: YAML frontmatter + Markdown table provides human readability + machine parsability. No database needed.
   - **Decision**: Single `progress.md` file (MVP), future: per-student files for multi-user.

7. **Prompt Command Structure**
   - **Question**: How should `.vscode/prompts/*.prompt.md` files be structured?
   - **Finding**: VS Code Copilot pattern: YAML frontmatter (metadata), "User Input Expected" section, "Execution Steps" with script calls, "Tone & Style" guidelines. Similar to spec-kit's prompt structure.
   - **Decision**: Adopt VS Code prompt structure. Each command gets one prompt file.

8. **Package Distribution Strategy**
   - **Question**: How should `teacherkit` CLI be distributed and installed?
   - **Finding**: spec-kit uses uv for installation: `uv tool install` or `uvx --from git+URL`. Templates distributed via GitHub releases (zip/tar.gz), extracted on first run. No PyPI publishing needed for MVP.
   - **Decision**: Git-based installation via uv. Templates in repository. PyPI publishing deferred to post-MVP.

### Technology Decisions Summary

| Decision Area | Choice | Rationale |
|--------------|--------|-----------|
| CLI Framework | Python 3.11+ + Typer | Matches spec-kit, professional UX, cross-platform |
| Package Manager | uv (Astral) | Fast, Git-aware, matches spec-kit installation pattern |
| CLI Scope | Minimal (init + config) | Avoid feature creep, teaching is prompt-driven |
| Command Interface | Dual-layer: CLI + Copilot `/teacherkit.*` | Setup via CLI, teaching via prompts |
| Script Language | PowerShell 7+ | Cross-platform, existing usage, handles YAML/Markdown |
| Storage Format | Markdown + YAML frontmatter | Human-readable, Git-friendly, no database overhead |
| KP Extraction | Rule-based heuristics (MVP) | 80%+ accuracy without AI API calls, fast implementation |
| Question Generation | Template library + AI adaptation | Balances consistency with personalization |
| Testing Strategy | pytest (CLI) + Pester (scripts) + manual (prompts) | Pragmatic for hybrid architecture |

### Risks & Mitigations

1. **Risk**: Users may not have Python 3.11+ or uv installed
   - **Mitigation**: `teacherkit config` command checks prerequisites. Quickstart guide provides installation links. Error messages include fix instructions.

2. **Risk**: GitHub Copilot may not execute PowerShell scripts reliably from prompts
   - **Mitigation**: Scripts return JSON; prompts handle display. Fallback: manual script execution guidance in error messages.

3. **Risk**: Rule-based KP extraction may produce low-quality knowledge points
   - **Mitigation**: Manual review step in workflow. User can edit chapter files. Target 80% accuracy (good enough for MVP).

4. **Risk**: Students may not understand Socratic method (expect direct answers)
   - **Mitigation**: Quickstart guide explains approach. Teaching prompt explicitly redirects direct answer requests.

5. **Risk**: CLI and prompts may drift out of sync (duplicate logic)
   - **Mitigation**: Both layers call same PowerShell scripts. Scripts are single source of truth. Integration tests verify consistency.
   - **Finding**: Template library approach works well. Create question templates (concept, comparison, application, misconception) and fill with extracted keywords. User-provided teaching prompt enhances AI adaptation.
   - **Decision**: Template-based generation + AI refinement during lesson (Copilot adapts based on context).

6. **Progress Tracking Schema**
   - **Question**: What's the minimal data structure to track learning progress?
   - **Finding**: YAML frontmatter + Markdown table provides human readability + machine parsability. No database needed.
   - **Decision**: Single `progress.md` file (MVP), future: per-student files for multi-user.

7. **Prompt Command Structure**
   - **Question**: How should `.vscode/prompts/*.prompt.md` files be structured?
   - **Finding**: VS Code Copilot pattern: YAML frontmatter (metadata), "User Input Expected" section, "Execution Steps" with script calls, "Tone & Style" guidelines. **Note**: spec-kit research references `.github/prompts/` as GitHub Copilot's convention, but our implementation uses `.vscode/prompts/` for VS Code Copilot compatibility.
   - **Decision**: Adopt VS Code prompt structure in `.vscode/prompts/`. Each command gets one prompt file.

### Technology Decisions Summary

| Decision Area | Choice | Rationale |
|--------------|--------|-----------|
| CLI Framework | Python 3.11+ + Typer | Matches spec-kit, professional UX, cross-platform |
| Package Manager | uv (Astral) | Fast, Git-aware, matches spec-kit installation pattern |
| CLI Scope | Minimal (init + config) | Avoid feature creep, teaching is prompt-driven |
| Command Interface | Dual-layer: CLI + Copilot `/teacherkit.*` | Setup via CLI, teaching via prompts |
| Script Language | PowerShell 7+ | Cross-platform, existing usage, handles YAML/Markdown |
| Storage Format | Markdown + YAML frontmatter | Human-readable, Git-friendly, no database overhead |
| KP Extraction | Rule-based heuristics (MVP) | 80%+ accuracy without AI API calls, fast implementation |
| Question Generation | Template library + AI adaptation | Balances consistency with personalization |
| Testing Strategy | Manual prompt validation + Pester unit tests | Pragmatic for prompt-driven architecture |

### Risks & Mitigations

1. **Risk**: GitHub Copilot may not execute PowerShell scripts reliably
   - **Mitigation**: Scripts return JSON; prompts handle display. Fallback: manual script execution guidance.

2. **Risk**: Rule-based KP extraction may produce low-quality knowledge points
   - **Mitigation**: Manual review step in workflow. User can edit chapter files. Target 80% accuracy (good enough for MVP).

3. **Risk**: Students may not understand Socratic method (expect direct answers)
   - **Mitigation**: Quickstart guide explains approach. Teaching prompt explicitly redirects direct answer requests.

---

## Phase 1: System Design

**Date Completed**: 2025-10-21  
**Output Artifacts**: 
- [data-model.md](./data-model.md) - Entity schemas and relationships
- [contracts/](./contracts/) - Command interface specifications
- [quickstart.md](./quickstart.md) - User onboarding guide

### CLI Tool Design

**CLI Commands** (Python + Typer):

1. **`teacherkit init <project-name>`** (P1)
   - **Purpose**: Initialize new teaching repository
   - **Operations**:
     - Create project directory structure (`data/`, `logs/`, `.vscode/prompts/`)
     - Download prompt templates from GitHub (or bundle in package)
     - Initialize Git repository with `.gitignore`
     - Copy or symlink PowerShell scripts from package
     - Create initial `progress.md` and `README.md`
     - Display "Next steps" instructions
   - **Implementation**: `src/teacherkit_cli/commands/init.py`
   - **Dependencies**: `git.py` (Git init), `template.py` (download), `progress.py` (StepTracker)
   - **Success Criteria**: Creates runnable repository in < 30 seconds, works offline (bundled templates)

2. **`teacherkit config`** (P1)
   - **Purpose**: Validate environment prerequisites
   - **Checks**:
     - Python 3.11+ installed
     - PowerShell 7+ available (`pwsh --version`)
     - Git configured (user.name, user.email)
     - VS Code installed (optional warning)
     - GitHub Copilot extension active (optional warning)
   - **Implementation**: `src/teacherkit_cli/commands/config.py`
   - **Output**: Colored checklist with fix instructions for failures
   - **Success Criteria**: Detects all 5 prerequisites, provides actionable error messages

**CLI Entry Point** (`src/teacherkit_cli/__init__.py`):
```python
import typer
from .commands import init, config

app = typer.Typer()
app.command()(init.init_command)
app.command()(config.config_command)

def main():
    app()
```

**Packaging** (`pyproject.toml`):
- Package name: `teacherkit`
- Entry point: `teacherkit = teacherkit_cli:main`
- Dependencies: `typer`, `rich` (colored output), `gitpython`
- Minimum Python: 3.11
- Installation: `uv tool install teacherkit --from git+https://github.com/<org>/<repo>`

### Data Model Design

**Storage Pattern**: Markdown files with YAML frontmatter (no database)

**Key Entities Defined**:

1. **Textbook** (`data/textbooks/[name].md`)
   - Original learning material uploaded by student
   - Optional YAML frontmatter (auto-generated if missing)
   - UTF-8 text, 50MB limit

2. **Outline** (`data/outlines/[name]-outline.md`)
   - Generated from textbook via parsing
   - YAML: course metadata (total chapters, estimated hours)
   - Body: Hierarchical chapter structure with knowledge point counts

3. **Chapter** (`data/chapters/[textbook]/chapter-[NN].md`)
   - Prepared teaching material with knowledge points
   - YAML: chapter metadata, difficulty, prerequisites
   - Body: Knowledge points (KP-X.Y) with Socratic guiding questions

4. **Progress** (`data/progress.md`)
   - Singleton file tracking learning advancement
   - YAML: current position, study time, completion percentage
   - Body: Chapter completion table + session history

5. **Notes** (`data/notes/[textbook]-notes.md`)
   - Student highlights and reflections
   - YAML: note count, last updated
   - Body: Timestamped notes with source references (chapter/KP)

6. **Lesson Session** (ephemeral - not persisted)
   - In-memory state during `/teacherkit.lesson`
   - Maintained in Copilot conversation context
   - Saved to progress.md on exit

**Data Flow**:
```
CLI init → Repository structure
          ↓
Textbook → Outline → Chapters → Session State → Progress + Notes
          ↑________________________/teacherkit.* prompts
```

**Validation Rules**: Defined for each entity (file existence, format checks, range validation)

**Storage Estimates**: ~27 MB for MVP (5 textbooks, 50 chapters, no database overhead)

### Command Contracts

**2 CLI Commands + 5 Prompt Commands Specified** (P1: CLI + 3 prompts, P2: 2 prompts):

**CLI Layer**:

1. **`teacherkit init <project>`** (P1)
   - Contract: [contracts/cli-init-contract.md](./contracts/cli-init-contract.md)
   - Success: Creates valid repository structure with all required files

2. **`teacherkit config`** (P1)
   - Contract: [contracts/cli-config-contract.md](./contracts/cli-config-contract.md)
   - Success: Detects all prerequisites, provides fix instructions

**Prompt Layer**:

3. **`/teacherkit.parse`** (P1)
   - **Input**: `<textbook-path>`
   - **Script**: `parse-textbook.ps1`
   - **Output**: Outline file with chapter structure
   - **Success Criteria**: 90%+ accuracy, < 5 seconds for 10MB file

4. **`/teacherkit.prepare`** (P1)
   - **Input**: `<chapter-number>`
   - **Script**: `prepare-chapter.ps1`
   - **Output**: Chapter file with KPs and Socratic questions
   - **Success Criteria**: 80%+ KP extraction accuracy, 3-5 questions per KP

5. **`/teacherkit.lesson`** (P1)
   - **Input**: `<chapter-number> [knowledge-point-id]`
   - **Script**: `start-lesson.ps1` (initialization)
   - **Behavior**: Socratic dialogue loop (prompt-driven)
   - **Success Criteria**: Zero direct answers given, mastery indicators detected

6. **`/teacherkit.status`** (P2)
   - **Input**: `[detail-level]` (summary/chapters/full)
   - **Script**: `get-status.ps1`
   - **Output**: Progress visualization with percentages

7. **`/teacherkit.notes`** (P2)
   - **Input**: `<action>` (add/view/search) `[args]`
   - **Script**: `manage-notes.ps1`
   - **Output**: Note saved or retrieved notes list

**Contract Components** (per command):
- Command interface (invocation syntax, parameters)
- Script integration (PowerShell script name, parameters)
- Input validation rules
- Output format (JSON for scripts, rich text for CLI, Markdown for prompts)
- Side effects (files created/modified)
- Success criteria from spec.md
- Teaching prompt template (for prompt commands only)
- Testing checklist (pytest for CLI, Pester for scripts, manual for prompts)
- Dependencies and implementation notes

### Quick Start Guide

**Target Audience**: Students using teacherkit CLI + GitHub Copilot for self-paced learning

**Content Structure**:
1. **What is This?** - Conceptual overview (CLI setup + AI teaching)
2. **Prerequisites** - Python 3.11+, uv, VS Code, Copilot, PowerShell 7+
3. **Installation** - `uv tool install teacherkit` or `uvx` one-liner
4. **First-Time Setup** - `teacherkit init my-learning`, `teacherkit config` checks
5. **Your First Learning Session** - Step-by-step tutorial (parse → prepare → learn)
6. **CLI Commands** - `teacherkit init`, `teacherkit config` usage
7. **Prompt Commands** - `/teacherkit.parse`, `/teacherkit.prepare`, `/teacherkit.lesson`, etc.
8. **During a Lesson** - Special commands (hint, example, pause, mark)
9. **Checking Progress** - `/teacherkit.status` usage
10. **Managing Notes** - `/teacherkit.notes` usage
11. **Typical Learning Workflow** - Recommended daily routine
12. **Troubleshooting** - Python/uv installation issues, PowerShell errors, Copilot problems
13. **Tips for Effective Learning** - Pedagogical best practices

**Tone**: Encouraging, clear, actionable. Uses emojis and structured formatting.

**Length**: ~2000 words (includes CLI installation steps + prompt usage)

### Design Decisions

1. **Dual-Layer Architecture Validated**
   - CLI (Python+Typer) handles professional setup (init/config)
   - Prompts (Markdown) handle AI-native teaching interaction
   - PowerShell scripts serve both layers (shared backend)
   - Architecture matches spec-kit pattern while preserving AI teaching strengths

2. **Markdown-First Storage Validated**
   - All entities map to `.md` files cleanly
   - No database needed for MVP scale (5 textbooks, 1 user)
   - Git-friendly, human-readable, debuggable

3. **Prompt Command Pattern Finalized**
   - Each prompt command = 1 prompt file + 1 PowerShell script
   - Prompts handle AI behavior, scripts handle file I/O
   - Clear separation of concerns

4. **CLI Minimal Scope Justified**
   - Only 2 commands (init, config) vs. 5 prompt commands
   - Avoids feature creep, focuses on setup UX
   - Teaching remains prompt-driven (leverages Copilot strengths)

5. **Socratic Dialogue as Core UX**
   - Teaching prompt template enforces question-driven interaction
   - Special commands (hint, skip, pause) provide escape hatches
   - Mastery detection via keyword analysis (manual review in MVP)

6. **Single-User MVP Scope**
   - `progress.md` is singleton (no per-student files yet)
   - Simplifies data model, testing, and implementation
   - Multi-user support deferred to v0.2.0

7. **Python+Typer+uv Stack Adopted**
   - Matches spec-kit precedent (proven pattern)
   - Professional packaging via uv (fast, Git-aware)
   - Cross-platform support (Windows/macOS/Linux)
   - pytest for CLI testing (standard Python practice)

---

## Next Steps

**Immediate Action**: Run `/speckit.tasks` command to break down implementation into actionable tasks.

**Phase 2 Output**: `tasks.md` file with:
- Task breakdown by component (CLI, Prompts, Scripts, Tests)
- Effort estimates (T-shirt sizing)
- Dependency graph (CLI → Scripts → Prompts)
- Testing tasks (pytest for CLI, Pester for scripts, manual for prompts)
- Risk mitigation tasks
- CLI-specific tasks: pyproject.toml, entry points, StepTracker, template bundling

**Implementation Order** (recommended):
1. CLI tool skeleton (pyproject.toml, __init__.py, basic commands)
2. PowerShell scripts (TDD with Pester, shared by CLI and prompts)
3. CLI commands (pytest, calls PowerShell scripts)
4. Prompt files (manual testing with sample textbook)
5. Integration testing (full workflow validation: CLI init → prompts → data)
6. Documentation finalization (README, CLI help, quickstart)

**Estimated Timeline** (based on dual-layer complexity):
- Phase 2 (Tasks): 2-3 hours
- Phase 3 (Implementation): 
  - CLI tool: 1-2 days (pyproject.toml, commands, utils)
  - PowerShell scripts: 1-2 days (shared backend)
  - Prompt files: 1 day (AI instructions)
  - Total: 3-5 days
- Phase 4 (Testing): 
  - CLI tests (pytest): 0.5 day
  - Script tests (Pester): 0.5 day
  - Integration: 0.5 day
  - Total: 1.5 days
- **Total MVP**: ~5-7 days

**Review Checkpoints**:
- ✅ After Phase 0: Research validated dual-layer architecture + spec-kit stack
- ✅ After Phase 1: Data model, CLI design, and contracts align with clarified requirements
- ⏳ After Phase 2: Task breakdown reviewed for completeness (CLI + prompts + scripts)
- ⏳ After Phase 3: Implementation passes pytest (CLI) + Pester (scripts) + manual validation (prompts)
- ⏳ After Phase 4: End-to-end workflow tested (teacherkit init → /teacherkit.* commands → data files)

