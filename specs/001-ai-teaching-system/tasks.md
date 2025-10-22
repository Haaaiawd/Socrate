# Tasks: AI Teaching System

**Feature Branch**: `001-ai-teaching-system`  
**Date Generated**: 2025-10-21  
**Date Updated**: 2025-10-22  
**Total Tasks**: 69  
**Completed Tasks**: 26 (37.7%)  
**MVP Scope**: Phase 1-3 (26 core tasks completed, tests marked OPTIONAL)

---

## Task Summary

| Phase | User Story | Task Count | Completed | Can Run in Parallel | Independent Test |
|-------|------------|------------|-----------|---------------------|------------------|
| Setup | - | 8 | 6/8 (75%) | 3 tasks | Project structure exists |
| Foundational | - | 9 | 7/9 (78%) | 5 tasks | Scripts pass unit tests |
| User Story 1 | Textbook Parsing | 17 | 13/17 (76%) | 9 tasks | Can parse textbook ? generate outline |
| User Story 2 | Chapter Preparation | 13 | 6/13 (46%) | 6 tasks | Can extract KPs ? generate questions |
| User Story 3 | Socratic Dialogue | 14 | 0/14 (0%) | 5 tasks | Can conduct lesson session |
| User Story 4 | Progress Tracking | 4 | 0/4 (0%) | 2 tasks | Can track/display progress |
| User Story 5 | Notes | 3 | 0/3 (0%) | 1 task | Can save/retrieve notes |

**MVP Path**: Setup ? Foundational ? US1+US2 (26 core tasks completed = Phase 1-3 foundation ready)

**Notes**: Test tasks (T004-T005, T016-T017, T026-T027, T032, T040) marked OPTIONAL per spec-kit philosophy

---

## Dependencies

```
Setup Phase (parallel infrastructure)
    ?
Foundational Phase (shared utilities)
    ?
US1: Textbook Parsing ????
    ?                   ?
US2: Chapter Prep ????????(US2-5 have minimal dependencies on US1)
    ?                   ?
US3: Socratic Dialogue ???
    ?                   ?
US4: Progress Tracking ???
    ?                   ?
US5: Notes ???????????????
```

**Key Dependencies**:
- **US2 depends on US1**: Needs outline.md format from US1
- **US3 depends on US2**: Needs chapter.md format from US2
- **US4 depends on US3**: Needs session data from US3
- **US5 depends on US3**: Needs active lesson context

**Parallel Opportunities**:
- Setup tasks: CLI skeleton + PowerShell utils + test infrastructure can run simultaneously
- US2-US5 can start design/contract work before US1 implementation completes
- All prompt files can be developed in parallel once contract interfaces are stable

---

## Phase 1: Setup (Project Initialization)

**Goal**: Establish project structure, CLI tool skeleton, and development environment

**Independent Test**: Can run `teacherkit init test-project` and `teacherkit config` successfully

### Tasks

- [X] T001 Create pyproject.toml with teacherkit package metadata (Python 3.11+, Typer, rich, gitpython dependencies)
- [X] T002 [P] Create src/teacherkit_cli/__init__.py with Typer app entry point and main() function
- [X] T003 [P] Create src/teacherkit_cli/commands/__init__.py as commands package marker
- [ ] T004 [P] Create tests/python/conftest.py with pytest fixtures for CLI testing (OPTIONAL - skipped)
- [ ] T005 [P] Create tests/powershell/ directory for Pester tests (OPTIONAL - skipped)
- [X] T006 Create .gitignore with Python cache, logs, data directory exclusions
- [X] T007 Create README.md with teacherkit installation instructions (uv tool install)
- [X] T008 Create project directory templates in .specify/templates/ (outline-template.md, chapter-template.md, progress-template.md, teaching-prompt-template.md)

---

## Phase 2: Foundational (Shared Utilities)

**Goal**: Build reusable components needed by multiple user stories (CLI utils, PowerShell scripts, logging)

**Independent Test**: All utility functions pass unit tests, can be imported/called from tests

### Tasks

- [X] T009 [P] Create .specify/scripts/powershell/common/logging.ps1 with Write-Log, Initialize-Logger functions
- [X] T010 [P] Create .specify/scripts/powershell/common/markdown.ps1 with Read-Markdown, Write-Markdown, Parse-FrontMatter functions
- [X] T011 [P] Create .specify/scripts/powershell/common/validation.ps1 with Test-Prerequisites, Validate-Textbook functions
- [X] T012 [P] Create src/teacherkit_cli/utils/__init__.py as utils package marker
- [X] T013 [P] Create src/teacherkit_cli/utils/git.py with Git init/clone functions using gitpython
- [X] T014 Create src/teacherkit_cli/utils/template.py with template download from GitHub releases
- [X] T015 Create src/teacherkit_cli/utils/progress.py with StepTracker class (like spec-kit's progress display)
- [ ] T016 Create tests/powershell/common/logging.Tests.ps1 with Pester tests for logging functions (OPTIONAL - skipped)
- [ ] T017 Create tests/powershell/common/markdown.Tests.ps1 with Pester tests for Markdown I/O functions (OPTIONAL - skipped)

---

## Phase 3: User Story 1 - Textbook Parsing (P1 - MVP)

**Goal**: Parse textbook files and generate structured outlines with chapter/section hierarchy

**Independent Test**: Run `/teacherkit.parse data/textbooks/sample.md` â†?verify outline.md created with correct structure

### Tasks

#### CLI Implementation

- [X] T018 [US1] Create src/teacherkit_cli/commands/init.py with init_command() function (handle multiple init calls: skip if directory exists or prompt to overwrite for separate student workspaces)
- [X] T019 [US1] Implement directory creation in init.py (data/, logs/, .vscode/prompts/)
- [X] T020 [US1] Implement template copying in init.py (from .specify/templates/ to project)
- [X] T021 [US1] Implement Git initialization in init.py using utils/git.py
- [X] T022 [US1] Add progress tracking to init.py using utils/progress.py StepTracker
- [X] T023 [P] [US1] Create src/teacherkit_cli/commands/config.py with config_command() function
- [X] T024 [P] [US1] Implement prerequisite checks in config.py (Python 3.11+, PowerShell 7+, Git, VS Code, Copilot)
- [ ] T025 [P] [US1] Implement verbose (-v/--verbose) and debug (-d/--debug) flags in CLI commands (init.py and config.py) (NOT IN MVP SCOPE)
- [ ] T026 [P] [US1] Create tests/python/test_init.py with pytest tests for init command (OPTIONAL - skipped)
- [ ] T027 [P] [US1] Create tests/python/test_config.py with pytest tests for config command (OPTIONAL - skipped)

#### PowerShell Script

- [X] T028 [P] [US1] Create .specify/scripts/powershell/Parse-Textbook.ps1 with textbook parsing logic (include progress display for large files >5MB)
- [X] T029 [US1] Implement heading extraction in Parse-Textbook.ps1 (# Chapter, ## Section detection, log warnings for malformed sections)
- [X] T030 [US1] Implement outline generation in Parse-Textbook.ps1 (hierarchical structure + YAML frontmatter)
- [X] T031 [US1] Implement file I/O in Parse-Textbook.ps1 (write outline to data/outlines/)
- [ ] T032 [P] [US1] Create tests/powershell/Parse-Textbook.Tests.ps1 with Pester tests (OPTIONAL - skipped)

#### Prompt Command

- [X] T033 [P] [US1] Create .vscode/prompts/teacherkit.parse.prompt.md with YAML frontmatter (description, scripts)
- [X] T034 [US1] Implement prompt instructions in teacherkit.parse.prompt.md (call Parse-Textbook.ps1, display results)
- [ ] T035 [P] [US1] Create .vscode/prompts/teacherkit.view-outline.prompt.md for displaying generated outlines with chapter summaries (NOT IN MVP SCOPE)

---

## Phase 4: User Story 2 - Chapter Preparation (P1 - MVP)

**Goal**: Extract knowledge points from chapters and generate Socratic questions

**Independent Test**: Run `/teacherkit.prepare 1` â†?verify chapter-01.md created with KPs and questions

### Tasks

#### PowerShell Script

- [X] T036 [P] [US2] Create .specify/scripts/powershell/Prepare-Chapter.ps1 with chapter extraction logic
- [X] T037 [US2] Implement knowledge point extraction in Prepare-Chapter.ps1 (heading-based rules)
- [X] T038 [US2] Implement question generation in Prepare-Chapter.ps1 (template library: concept/comparison/application)
- [X] T039 [US2] Implement chapter file writing in Prepare-Chapter.ps1 (data/chapters/ with YAML frontmatter)
- [ ] T040 [P] [US2] Create tests/powershell/Prepare-Chapter.Tests.ps1 with Pester tests (OPTIONAL - skipped)

#### Prompt Command

- [X] T041 [P] [US2] Create .vscode/prompts/teacherkit.prepare.prompt.md with YAML frontmatter
- [X] T042 [US2] Implement prompt instructions in teacherkit.prepare.prompt.md (call Prepare-Chapter.ps1, display KPs)
- [ ] T043 [P] [US2] Create .vscode/prompts/teacherkit.show-chapter.prompt.md for chapter display (NOT IN MVP SCOPE)

#### Additional Components

- [ ] T044 [P] [US2] Create question template library in .specify/templates/question-templates.json
- [ ] T045 [US2] Implement template loading in Prepare-Chapter.ps1 (read question-templates.json)
- [ ] T046 [US2] Implement difficulty tagging in Prepare-Chapter.ps1 (Beginner/Intermediate/Advanced based on keywords)
- [ ] T047 [P] [US2] Add manual review flag to Prepare-Chapter.ps1 (log "needs review" for low-confidence KPs)
- [ ] T048 [US2] Create sample textbook in data/textbooks/sample-python.md for testing

---

## Phase 5: User Story 3 - Socratic Dialogue (P1 - MVP)

**Goal**: Conduct interactive teaching sessions using Socratic method prompts

**Independent Test**: Run `/teacherkit.lesson 1` â†?verify session starts, AI asks guiding questions, progress saves

### Tasks

#### PowerShell Script

- [X] T049 [P] [US3] Create .specify/scripts/powershell/Start-Lesson.ps1 with session initialization logic
- [X] T050 [US3] Implement chapter loading in Start-Lesson.ps1 (read chapter.md, extract current KP)
- [X] T051 [US3] Implement session state creation in Start-Lesson.ps1 (in-memory JSON for Copilot context)
- [X] T052 [US3] Implement progress saving in Start-Lesson.ps1 (Update-Progress.ps1 created separately)
- [ ] T053 [P] [US3] Create tests/powershell/Start-Lesson.Tests.ps1 with Pester tests (OPTIONAL - skipped)

#### Prompt Commands

- [X] T054 [P] [US3] Create .vscode/prompts/teacherkit.lesson.prompt.md with Socratic teaching template (in .github/prompts/)
- [X] T055 [US3] Implement Socratic rules in teacherkit.lesson.prompt.md (no direct answers, guide with questions)
- [X] T056 [US3] Implement response evaluation logic in prompt (check understanding using keyword matching for MVP, semantic similarity for future versions, ask follow-ups)
- [X] T057 [US3] Implement hint escalation in prompt (provide more detailed hints after 3+ failed attempts - 4 levels)
- [X] T058 [US3] Implement session exit handling in prompt (save progress on `exit`/`pause` command)
- [ ] T058a [US3] Implement API retry logic with exponential backoff in Start-Lesson.ps1 (NOT MVP SCOPE - basic error handling included)
- [ ] T059 [P] [US3] Create .vscode/prompts/teacherkit.resume.prompt.md for resuming lessons (CAN REUSE teacherkit.lesson)
- [ ] T060 [P] [US3] Create teaching-prompt-template.md in .specify/templates/ (Socratic method guidelines - ALREADY IN PROMPT)

#### Integration

- [ ] T061 [US3] Implement auto-save mechanism in Start-Lesson.ps1 (NOT MVP SCOPE - manual pause/save sufficient)
- [X] T062 [US3] Create data/progress.md template in .specify/templates/progress-template.md (already exists from Phase 1)

---

## Phase 6: User Story 4 - Progress Tracking (P2)

**Goal**: Track and display student learning progress across chapters

**Independent Test**: Complete US3 session â†?run `/teacherkit.status` â†?verify progress displayed correctly

### Tasks

- [ ] T063 [P] [US4] Create .specify/scripts/powershell/Get-Status.ps1 with progress reading logic
- [ ] T064 [P] [US4] Create .vscode/prompts/teacherkit.status.prompt.md with status display formatting
- [ ] T065 [US4] Implement progress calculation in Get-Status.ps1 (completed/total chapters percentage)
- [ ] T066 [US4] Implement next recommendation in Get-Status.ps1 (suggest next chapter based on prerequisites)

---

## Phase 7: User Story 5 - Notes (P3)

**Goal**: Allow students to mark and save text highlights during lessons

**Independent Test**: During US3 session â†?use `mark` command â†?verify note saved in notes.md

### Tasks

- [ ] T067 [P] [US5] Create .specify/scripts/powershell/Manage-Notes.ps1 with note capture logic
- [ ] T068 [P] [US5] Create .vscode/prompts/teacherkit.notes.prompt.md with note display/search commands
- [ ] T069 [US5] Implement note export in Manage-Notes.ps1 (generate Markdown summary)

---

## Implementation Strategy

### Success Criteria Validation Strategy

**Integration-First Testing**: Success Criteria (SC-001 to SC-012) are validated through integration testing during implementation, not as a separate phase. Each User Story task references relevant SC requirements, and the `/implement` command verifies functionality in real environments.

**Automated Testing**: Tests are OPTIONAL and only included when:
- Explicitly requested by stakeholders
- Required for CI/CD pipelines
- Needed for performance regression testing

**Validation Approach**:
- US1 tasks verify SC-001, SC-002, SC-007 (performance, accuracy, response times)
- US2 tasks verify SC-012 (knowledge point extraction accuracy)
- US3 tasks verify SC-003, SC-010 (Socratic dialogue quality, redirect behavior)
- US4 tasks verify SC-005 (progress tracking)
- US5 tasks verify SC-009 (note capture accuracy)
- All tasks verify SC-008 (actionable error messages) during implementation

### MVP First Approach (Recommended)

**Phase 1 MVP** (User Story 1 Only - ~2-3 days):
1. Complete Setup + Foundational phases first (build infrastructure)
2. Implement US1 completely (CLI init, Parse-Textbook.ps1, parse prompt)
3. Test end-to-end: `teacherkit init` ? `teacherkit config` ? `/teacherkit.parse sample.md` ? verify outline

**Benefits**: Delivers immediate value (students can organize textbooks), validates CLI+script architecture, provides foundation for US2-3

**Phase 2 Expansion** (US2-3 - ~3-4 days):
- Add chapter preparation and Socratic dialogue
- Test full teaching workflow: parse ? prepare ? teach

**Phase 3 Enhancement** (US4-5 - ~1-2 days):
- Add progress tracking and notes
- Polish user experience

### Parallel Execution Opportunities

**Setup Phase** (3 tasks can run in parallel):
- T002 (CLI __init__.py), T004 (pytest conftest), T005 (Pester directory) - independent files

**Foundational Phase** (5 tasks can run in parallel):
- T009 (logging.ps1), T010 (markdown.ps1), T011 (validation.ps1), T012 (utils __init__.py), T013 (git.py) - different files, no dependencies

**User Story 1** (9 tasks can run in parallel):
- T023-T024 (config.py implementation) - separate from init.py
- T025-T027 (pytest tests) - can write tests before implementation (TDD)
- T028 (Parse-Textbook.ps1) - independent from CLI commands
- T032 (Pester tests) - can write test structure early
- T033 (parse prompt) - contract-first, doesn't need script implementation

**User Story 2** (6 tasks can run in parallel):
- T036 (Prepare-Chapter.ps1), T041 (prepare prompt), T043 (show-chapter prompt), T044 (question templates), T048 (sample textbook) - different files

**User Story 3** (5 tasks can run in parallel):
- T049 (Start-Lesson.ps1), T054 (lesson prompt), T059 (resume prompt), T060 (teaching template), T062 (progress template) - different files

---

## Execution Guidance

### Task Checklist Format

All tasks follow: `- [ ] T### [optional: P] [optional: US#] Description with file path`

- **[P]** = Parallelizable (different files, no blocking dependencies)
- **[US#]** = User Story assignment (US1-US5)

### Validation Checkpoints

After each phase completion:

1. **Setup**: Run `teacherkit --version` and verify CLI responds
2. **Foundational**: If tests exist, run `pytest tests/python/` and `Invoke-Pester tests/powershell/` - all should pass
3. **US1**: Run full workflow: `teacherkit init demo` ? `teacherkit config` ? `/teacherkit.parse sample.md` ? check outline.md exists
4. **US2**: Run `/teacherkit.prepare 1` ? check chapter-01.md has 5+ KPs with questions
5. **US3**: Run `/teacherkit.lesson 1` ? interact with Socratic dialogue, exit, verify progress.md updated
6. **US4**: Run `/teacherkit.status` ? verify progress display
7. **US5**: During US3, use `mark` ? verify notes.md captures highlight

### Common Pitfalls

1. **PowerShell Path Issues**: Use `$PSScriptRoot` for relative paths in scripts
2. **YAML Frontmatter Parsing**: Test with malformed YAML (missing closing `---`)
3. **Prompt Command Discovery**: Ensure `.vscode/prompts/` files have correct YAML frontmatter
4. **Git Initialization**: Handle case where Git is not installed (config.py should warn)
5. **Template Distribution**: Bundle templates in package or download from GitHub releases
6. **uv Installation**: Document uv installation as prerequisite (not automatic)

---

## Risk Mitigation Tasks

### High-Priority Risks

1. **PowerShell Script Reliability** (Medium/High):
   - Mitigation: T016-T017, T031, T038, T051 (comprehensive Pester tests)
   - Fallback: Provide manual script execution guidance in error messages

2. **CLI Packaging with uv** (Medium/Medium):
   - Mitigation: T001 (pyproject.toml must follow uv conventions)
   - Test early: Try `uv tool install --editable .` locally

3. **Prompt Quality** (Low/High):
   - Mitigation: T060 (teaching-prompt-template.md with Socratic rules)
   - Validation: Manual testing with real textbooks

4. **Knowledge Point Extraction Accuracy** (Medium/Medium):
   - Mitigation: T039 (rule-based extraction), T047 (manual review flag)
   - Acceptance: 80% accuracy target, manual refinement allowed

---

## Testing Strategy

### Unit Tests (OPTIONAL)

Automated tests are OPTIONAL and only included when:
- Explicitly requested by stakeholders
- Required for CI/CD pipelines  
- Needed for regression testing

**If included**:
- **Python CLI**: pytest with test fixtures (T004, T026, T027)
- **PowerShell Scripts**: Pester with mock functions (T016, T017, T032, T040, T053)

### Integration Tests (Primary Validation)

- **End-to-End Workflows**: Test full user story flows with real data during implementation
- **Validation Points**: Check file existence, content structure, YAML validity
- **Success Criteria**: Each User Story verifies relevant SC requirements through actual usage

### Manual Tests (Required for Prompts)

- **Socratic Dialogue Quality**: Human evaluation of AI teaching effectiveness
- **Edge Cases**: Test error handling, malformed inputs, API failures

---

## File Structure Reference

```
teacherkit/
??? src/
?   ??? teacherkit_cli/
?       ??? __init__.py              # T002 - CLI entry point
?       ??? commands/
?       ?   ??? __init__.py          # T003
?       ?   ??? init.py              # T018-T022
?       ?   ??? config.py            # T023-T024
?       ??? utils/
?           ??? __init__.py          # T012
?           ??? git.py               # T013
?           ??? template.py          # T014
?           ??? progress.py          # T015
??? .vscode/
?   ??? prompts/
?       ??? teacherkit.parse.prompt.md       # T033-T034
?       ??? teacherkit.prepare.prompt.md     # T041-T042
?       ??? teacherkit.show-chapter.prompt.md # T043
?       ??? teacherkit.lesson.prompt.md      # T054-T058
?       ??? teacherkit.resume.prompt.md      # T059
?       ??? teacherkit.status.prompt.md      # T064
?       ??? teacherkit.notes.prompt.md       # T068
??? .specify/
?   ??? scripts/
?   ?   ??? powershell/
?   ?       ??? common/
?   ?       ?   ??? logging.ps1              # T009
?   ?       ?   ??? markdown.ps1             # T010
?   ?       ?   ??? validation.ps1           # T011
?   ?       ??? Parse-Textbook.ps1           # T028-T031
?   ?       ??? Prepare-Chapter.ps1          # T036-T040
?   ?       ??? Start-Lesson.ps1             # T049-T053
?   ?       ??? Get-Status.ps1               # T063-T065
?   ?       ??? Manage-Notes.ps1             # T067, T069
?   ??? templates/
?       ??? outline-template.md              # T008
?       ??? chapter-template.md              # T008
?       ??? progress-template.md             # T008, T062
?       ??? teaching-prompt-template.md      # T008, T060
?       ??? question-templates.json          # T044
??? tests/                                   # OPTIONAL
?   ??? python/
?   ?   ??? conftest.py                      # T004
?   ?   ??? test_init.py                     # T026
?   ?   ??? test_config.py                   # T027
?   ??? powershell/
?       ??? common/
?       ?   ??? logging.Tests.ps1            # T016
?       ?   ??? markdown.Tests.ps1           # T017
?       ??? Parse-Textbook.Tests.ps1         # T032
?       ??? Prepare-Chapter.Tests.ps1        # T040
?       ??? Start-Lesson.Tests.ps1           # T053
??? data/                                    # Created by init.py (T019)
?   ??? textbooks/
?   ?   ??? sample-python.md                 # T048
?   ??? outlines/
?   ??? chapters/
?   ??? notes/
?   ??? progress.md
??? logs/                                    # Created by init.py (T019)
??? pyproject.toml                           # T001
??? README.md                                # T007
??? .gitignore                               # T006
```

---

## Summary

- **Total**: 69 tasks across 7 phases (Phase 8 removed - validation integrated into implementation)
- **MVP**: 34 tasks (Setup + Foundational + US1)
- **Parallel**: 27 tasks marked [P] can run simultaneously
- **Timeline**: 5-7 days full implementation (2-3 days MVP only)
- **Critical Path**: Setup ? Foundational ? US1 ? US2 ? US3
- **Testing Strategy**: Integration-first (SC validation during implementation), automated tests OPTIONAL

**Next Steps**: 
1. Confirm MVP scope with stakeholder (US1 only vs US1-3)
2. Run `/speckit.implement` command to begin execution
3. Execute Setup and Foundational phases in parallel
4. Implement US1 with continuous testing
5. Iterate based on feedback

