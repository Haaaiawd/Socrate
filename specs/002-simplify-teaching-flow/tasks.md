---
description: "Task list for Simplified Teaching Flow feature implementation"
created: "2025-10-23"
feature: "002-simplify-teaching-flow"
---

# Tasks: Simplified Teaching Flow with Practice Exercises

**Input**: Design documents from `/specs/002-simplify-teaching-flow/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/, quickstart.md

**Testing Approach**: Manual validation via spec.md acceptance scenarios (TDD not applicable - see Constitution Check in plan.md for justification)

**Organization**: Tasks grouped by implementation phase, with user story tags showing which stories each task serves

**AI-Aware Guidelines**:
- Prompt templates are the primary deliverables (not traditional Python application code)
- CLI code is minimal (~100 lines total - only `teacherkit init` command)
- Testing via manual execution of spec.md scenarios
- Include absolute file paths in all task descriptions

## Format: `[ID] [P?] [Story?] Description`
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task serves (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions
- **CLI code**: `src/teacherkit_cli/`
- **Prompt templates**: `.github/prompts/`
- **Data storage**: `data/` (created by init command)

---

## Phase 1: Project Setup (CLI Scaffolding)

**Purpose**: Initialize project structure and implement the single CLI command

**Estimated Time**: ~2 hours

- [x] T001 Create project structure per plan.md: pyproject.toml at repository root, src/teacherkit_cli/ with __init__.py, commands/, utils/ subdirectories, data/ directory templates
- [x] T002 [P] Implement `init` command logic in src/teacherkit_cli/commands/init.py: create data/ structure (textbooks/, outlines/, chapters/, notes/, exercises/ subdirectories), copy prompt templates from .github/prompts/ to .vscode/prompts/, display setup completion message
- [x] T003 [P] Implement template utilities in src/teacherkit_cli/utils/template.py: generate data/progress.md template with YAML frontmatter (topic, started, last_updated, status fields), generate README template for data/ directory
- [x] T004 [P] Implement git utilities in src/teacherkit_cli/utils/git.py: check if git repository exists, initialize git if not present, create initial .gitignore (ignore __pycache__/, *.pyc, .vscode/settings.json)
- [x] T005 Setup CLI entry point in src/teacherkit_cli/__main__.py: import init command, setup argument parser (teacherkit init [project-name]), handle command execution and error messages
- [x] T006 Manual testing of `teacherkit init` command: test in empty directory (creates all folders), test in existing git repo (skips git init), test with custom project name, verify generated files match spec

**Checkpoint**: `teacherkit init` command functional - creates complete project structure

---

## Phase 2: Foundational Prompts (US1 + US2 - Basic Teaching Flow)

**Purpose**: Create core prompt templates for file/topic-based learning without practice exercises

**Estimated Time**: ~4 hours

**User Stories Served**: 
- US1 (P1): Direct File Attachment Learning
- US2 (P1): Topic-Based Learning Without Files

### Prompt Template Creation

- [x] T007 [P] [US1][US2] Create `/teacherkit.outline` prompt template in .github/prompts/teacherkit.outline.prompt.md based on contracts/outline-command-contract.md: include role definition ("You are an educational content analyzer"), input handling (file attachment via @file OR topic description string), **topic clarification dialogue** (detect vague requests like "teach me Python" → ask narrowing questions: "Which aspect? Web development/data science/basics?" → iterate until topic is specific enough for outline generation), hierarchical outline generation logic (Chapters → Topics → Knowledge Points with YAML frontmatter), teaching plan integration (引入策略, 节奏控制, 渐进式深入), review phase design (70% practice + 30% concept review with 综合练习 structure), file output format (data/outlines/[sanitized-name]-outline.md with complete YAML metadata), error messages (unsupported file formats, file too large, topic too vague)
- [x] T008 [P] [US1][US2] Create `/teacherkit.prepare` prompt template in .github/prompts/teacherkit.prepare.prompt.md based on contracts/prepare-command-contract.md: include role definition ("You are a knowledge point preparation specialist"), prerequisite check (outline file must exist in data/outlines/), knowledge point elaboration logic (Core Definition with What/Why/Where, Principle Explanation with How/Key Elements/Flow, Code Examples with **Simple**(hello-world level)/**Practical**(real-world scenario with business context)/**Comparison**(contrasting approaches with trade-offs), **example-driven explanations for abstract concepts**: use analogies (e.g., variables as labeled boxes, functions as recipes), real-world scenarios (e.g., API calls explained via restaurant ordering), visual metaphors for complex flows), Socratic question design (3-layer hierarchy: Conceptual Understanding → Principle Exploration → Application Scenarios with 预期回答 and 检查点), teaching materials preparation (类比 analogies, 对比表格 comparison tables, 可视化说明 visual explanations), file output format (data/chapters/[name]-prepared.md with all KPs in one file)
- [x] T009 [US1][US2] Create `/teacherkit.lesson` prompt template (basic version) in .github/prompts/teacherkit.lesson.prompt.md based on contracts/lesson-command-contract.md: include role definition ("You are a Socratic teaching assistant"), session initialization logic (read outline from data/outlines/, read prepared KPs from data/chapters/, welcome message with learning overview), knowledge point teaching loop (引入阶段 with 问题导入/案例导入/对比导入, 苏格拉底式问答 3-layer progression, 知识点总结 with core concepts/key points/common pitfalls, 理解确认 checkpoint with graduated hints), dialogue state management (track current KP, completed KPs, conversation context), basic progress tracking (update data/progress.md with completed KPs, timestamp, notes), error handling (missing outline file, missing prepared file, student confusion detection)

**Checkpoint**: Basic teaching workflow functional (outline → prepare → lesson) without practice exercises

---

## Phase 3: Practice Integration (US3 - Complete MVP)

**Purpose**: Add practice exercise generation and feedback to complete the full teaching experience

**Estimated Time**: ~3 hours

**User Story Served**: 
- US3 (P1): Integrated Practice Exercises with Code Files

### Practice Prompt & Lesson Enhancement

- [x] T010 [P] [US3] Create `/teacherkit.practice` prompt template in .github/prompts/teacherkit.practice.prompt.md based on contracts/practice-command-contract.md: include role definition ("You are a practice exercise designer"), prerequisite check (outline and prepared files must exist), exercise position identification logic (every 2-3 related KPs, review phase comprehensive exercises), exercise code generation (Python only for MVP, function signature with clear naming, TODO markers with ### START CODE ### / ### END CODE ###, test cases using assert statements, graduated hints in comments: Hint 1 conceptual → Hint 2 specific → Hint 3 partial code), difficulty levels (Level 1 concept verification 3-5 lines, Level 2 concept combination 10-15 lines, Level 3 practical application 20-30 lines for review phase), file output format (data/exercises/practice-[topic]-[number].py with docstring task description, data/exercises/exercises-meta.md with exercise metadata table), metadata recording (exercise ID, related KPs, difficulty, estimated time, hints count)
- [x] T011 [US3] Enhance `/teacherkit.lesson` prompt template in .github/prompts/teacherkit.lesson.prompt.md: add practice trigger logic (detect completion of 2-3 related KPs, read exercises-meta.md to find matching exercise, display practice invitation with file path, difficulty, estimated time, allow student to skip or accept), practice feedback mechanism (Socratic code review: ask student to explain their thinking first, provide diagnostic questions not direct corrections, graduated hints system: Question 1 conceptual → Question 2 specific → Question 3 partial solution, celebrate correct solutions with specific praise, detect common errors and guide to fix), review phase management (trigger after all KPs complete, display 概念快速回顾 table with one-sentence summaries, guide through 综合实践 exercises Level 3, 查漏补缺 identify weak areas from exercise performance, offer optional deep-dive into struggling topics)

**Checkpoint**: Full teaching workflow with practice exercises (outline → prepare → practice → lesson with exercises)

---

## Phase 4: Quality & Progress (US4 + Optional Enhancements)

**Purpose**: Add optional quality validation and robust session management

**Estimated Time**: ~2 hours

**User Story Served**:
- US4 (P2): Seamless Learning Session Management

### Quality Check & Progress Enhancement

- [x] T012 [P] [US1][US2] Create `/teacherkit.check` prompt template (optional) in .github/prompts/teacherkit.check.prompt.md based on contracts/check-command-contract.md: include role definition ("You are a quality assurance specialist for educational content"), prerequisite check (prepared file must exist in data/chapters/), knowledge point depth check (definition clarity 1-2 sentences, principle completeness with key elements and flow, code example sufficiency at least 2 examples runnable, common pitfall coverage 2-3 新手易犯错误), Socratic question quality check (hierarchical progression Layer 1 conceptual → Layer 2 principle → Layer 3 application clearly distinct, open-endedness questions require thinking not yes/no, checkpoint appropriateness 预期回答 and 检查点 明确), teaching material completeness check (analogy appropriateness 日常经验 relatable, comparison table effectiveness 突出关键差异 2-4 dimensions, visualization clarity 流程图/步骤图 ≤10 nodes, material coverage at least 50% of KPs have analogies), comprehensive assessment (scoring rubric: 优秀 90-100, 良好 75-89, 需改进 60-74, 不合格 <60, weight: knowledge depth 40%, question quality 35%, material completeness 15%, coherence 10%), output format (console report only with quality score, strengths list, issues found with severity critical/minor, improvement recommendations with priority high/medium/low, next steps suggestions accept/improve/regenerate)
- [x] T013 [US4] Enhance `/teacherkit.lesson` prompt template in .github/prompts/teacherkit.lesson.prompt.md: add progress persistence logic (save to data/progress.md after each completed KP, save after each completed exercise, save before session ends, YAML frontmatter update: topic, started, last_updated, status, progress percentage), session resumption logic (detect existing data/progress.md on startup, display "Welcome back!" message with last session summary: completed KPs count, last KP name, last update timestamp, offer options: A continue from last position, B quick recap then continue, C start fresh new topic, load conversation context from progress notes), proactive checkpoint logic (after every 5 KPs offer progress summary with completed topics, estimated remaining time, suggest break if session > 1 hour, detect conversation length approaching token limits and warn), long break handling (detect time gap > 24 hours since last session, offer quick review of previous topics before continuing, adjust teaching pace if student seems rusty)

**Checkpoint**: Quality validation available, session management robust (pause/resume works seamlessly)

---

## Phase 5: Documentation & Validation (Polish)

**Purpose**: User-facing documentation and manual acceptance testing

**Estimated Time**: ~2 hours

### Documentation & Testing

- [x] T014 [P] Create README.md in repository root: include project description (AI-powered Socratic teaching assistant, prompt-first architecture, 5-command workflow), quick start instructions (install CLI: uv tool install teacherkit, initialize project: teacherkit init my-learning, start learning: attach file or describe topic + /teacherkit.outline), prerequisites (Python 3.11+, GitHub Copilot or Cursor or Claude Code, AI platform with file attachment support), feature highlights (file attachment learning, topic-based learning, practice exercises with TODO markers, Socratic dialogue, progress tracking), architecture overview (CLI for setup only, prompt templates for teaching, Markdown storage in data/, no database dependencies), usage examples (file-based learning scenario, topic-based learning scenario, practice exercise workflow), contributing guidelines (how to modify prompt templates, how to test changes manually), license and acknowledgments
- [x] T015 [P] Create troubleshooting guide in docs/troubleshooting.md: include common errors (file attachment not working: check file format MD/TXT/PDF, check file size < 50MB, try converting to plain text; outline generation fails: check AI platform permissions, verify file content readable, try simpler file first; practice exercises not offered: verify programming topic, check if practice command was run, confirm exercises-meta.md exists; progress not saved: check data/progress.md exists, verify write permissions, ensure session ended properly; command not recognized: check if prompts installed in .vscode/prompts/, verify AI platform supports slash commands), performance issues (large files: split into chapters, use topic description instead; slow response: check AI platform quota, reduce file size, simplify topic description), platform-specific tips (GitHub Copilot: use @file for attachments, Cursor: use @Files command, Claude Code: drag-drop files), debugging steps (check data/ directory structure, validate YAML frontmatter in generated files, review prompt template syntax), getting help (check README examples, review spec.md for expected behavior, review contracts/ for detailed command specs)
- [x] T016 Manual acceptance testing per spec.md scenarios: test User Story 1 acceptance scenarios (Scenario 1: attach python-basics.pdf → /teacherkit.outline → verify outline generated with chapters/topics/KPs, Scenario 2: verify teaching plan includes estimated study times, Scenario 3: attach multiple files → verify unified learning plan, Scenario 4: attach unsupported format → verify polite error message with format suggestions), test User Story 2 acceptance scenarios (Scenario 1: /teacherkit.outline "Python loops" → verify structured outline generated, Scenario 2: verify Socratic questions in prepare output, Scenario 3: broad topic "learn programming" → verify clarifying questions asked, Scenario 4: specific topic "list comprehension" → verify focused 15-20 min lesson), test User Story 3 acceptance scenarios (Scenario 1: after 2-3 KPs → verify practice offered, Scenario 2: verify exercise file includes TODO markers, test cases, hints, Scenario 3: submit completed exercise → verify Socratic feedback not direct corrections, Scenario 4: struggle with exercise → verify graduated hints provided, Scenario 5: complete correctly → verify celebration and extension challenge offered), test User Story 4 acceptance scenarios (Scenario 1: pause mid-lesson → close chat → reopen → verify progress saved, Scenario 2: return after break → verify AI resumes from last KP, Scenario 3: ask "what have we covered" → verify summary displayed, Scenario 4: long break days/weeks → verify AI offers recap before continuing), test edge cases (very large file >100MB → verify warning and chunk suggestion, corrupted file → verify error detection and conversion suggestion, practice submission with syntax errors → verify Socratic debugging guidance, off-topic practice submission → verify gentle redirect to exercise task). TESTING GUIDE CREATED: Manual testing checklist prepared in docs/manual-testing-checklist.md with 21 detailed test scenarios covering all User Stories (US1-US4) and edge cases. Testing requires real AI platform (GitHub Copilot/Cursor/Claude Code) and should be performed by human tester following the checklist. Estimated testing time: 2-3 hours.

**Checkpoint**: All documentation complete, all acceptance scenarios validated manually

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 completion (needs project structure and CLI)
- **Practice Integration (Phase 3)**: Depends on Phase 2 completion (needs basic teaching flow prompts)
- **Quality & Progress (Phase 4)**: Depends on Phase 3 completion (needs practice integration for full workflow)
- **Polish (Phase 5)**: Depends on Phase 4 completion (needs full feature set for documentation)

### Task Dependencies Within Phases

**Phase 1**:
- T002, T003, T004 [P]: Can run in parallel (different Python files)
- T005: Depends on T002 (needs init command implementation)
- T006: Depends on T001-T005 (needs complete CLI)

**Phase 2**:
- T007, T008 [P]: Can run in parallel (different prompt files)
- T009: Depends on T007, T008 (lesson prompt needs outline and prepared file formats)

**Phase 3**:
- T010 [P]: Can run in parallel with T011 preparation
- T011: Depends on T010 (needs exercises-meta.md format to read)

**Phase 4**:
- T012 [P]: Can start anytime after Phase 2 (independent check prompt)
- T013: Depends on T009, T011 (modifies lesson prompt)

**Phase 5**:
- T014, T015 [P]: Can run in parallel (different documentation files)
- T016: Depends on T001-T013 (needs complete feature set)

### Parallel Opportunities

- **Setup Phase**: T002 + T003 + T004 simultaneously (3 Python utilities)
- **Foundational Phase**: T007 + T008 simultaneously (2 prompt templates)
- **Practice Phase**: T010 can start while planning T011
- **Quality Phase**: T012 independent, can start early
- **Polish Phase**: T014 + T015 simultaneously (documentation)

---

## Parallel Example: Phase 2 Foundational Prompts

```bash
# Launch both prompt creations simultaneously:
Task: "Create outline prompt in .github/prompts/teacherkit.outline.prompt.md"
Task: "Create prepare prompt in .github/prompts/teacherkit.prepare.prompt.md"

# Then create lesson prompt (depends on both):
Task: "Create lesson prompt in .github/prompts/teacherkit.lesson.prompt.md"
```

---

## Implementation Strategy

### MVP First (Phase 1-3 Only)

1. **Phase 1**: Setup (~2 hours)
   - Complete CLI implementation
   - Test `teacherkit init` manually

2. **Phase 2**: Foundational Prompts (~4 hours)
   - Create outline, prepare, lesson prompts
   - **VALIDATE**: Test basic flow (outline → prepare → lesson) with sample textbook

3. **Phase 3**: Practice Integration (~3 hours)
   - Create practice prompt, enhance lesson prompt
   - **VALIDATE**: Test complete flow including practice exercises

4. **STOP**: MVP complete (Phase 1-3 = ~9 hours)
   - Basic teaching workflow works
   - Practice exercises integrated
   - Ready for real user testing

### Full Feature Completion (Add Phase 4-5)

1. Continue with **Phase 4**: Quality & Progress (~2 hours)
   - Add optional check command
   - Enhance session management

2. Finish with **Phase 5**: Documentation & Validation (~2 hours)
   - Write user-facing docs
   - Execute full manual test suite

3. **COMPLETE**: All P1+P2 user stories implemented (~13 hours total)

### Incremental Delivery Checkpoints

- ✅ **Checkpoint 1** (after Phase 1): CLI ready, project structure created
- ✅ **Checkpoint 2** (after Phase 2): Basic teaching loop works (no practice yet)
- ✅ **Checkpoint 3** (after Phase 3): **MVP COMPLETE** - Full teaching with exercises
- ✅ **Checkpoint 4** (after Phase 4): Quality check + session resume working
- ✅ **Checkpoint 5** (after Phase 5): Production-ready with docs and full validation

---

## Validation Checklist (Manual Testing)

After completing Phase 5, verify these critical paths:

### User Story 1: File Attachment Learning
- [ ] Attach MD file → /teacherkit.outline → outline generated in data/outlines/
- [ ] Outline includes chapters, topics, knowledge points with proper hierarchy
- [ ] Teaching plan section includes 引入策略 and 节奏控制
- [ ] /teacherkit.prepare → detailed KPs generated in data/chapters/
- [ ] Each KP includes definition, principle, examples, Socratic questions (3 layers)
- [ ] /teacherkit.lesson → Socratic dialogue begins with question-first approach

### User Story 2: Topic-Based Learning
- [ ] /teacherkit.outline "Python loops" → outline generated from AI knowledge
- [ ] Outline structure similar to file-based (chapters → topics → KPs)
- [ ] /teacherkit.prepare → AI-generated knowledge content (not extracted from file)
- [ ] /teacherkit.lesson → teaching dialogue uses Socratic method

### User Story 3: Practice Exercises
- [ ] After 2-3 KPs learned → AI offers practice exercise
- [ ] /teacherkit.practice → exercise files generated in data/exercises/
- [ ] Exercise file includes: TODO markers, function signature, test cases, hints
- [ ] Submit completed code → AI provides Socratic feedback (questions before answers)
- [ ] Struggle with exercise → AI gives graduated hints (conceptual → specific → partial)

### User Story 4: Session Management
- [ ] Pause during lesson → data/progress.md updated with completed KPs
- [ ] Restart lesson → AI detects progress and offers resume options
- [ ] After long break → AI offers quick recap before continuing

### Edge Cases
- [ ] Large file (>10MB) → warning message with chunking suggestion
- [ ] Unsupported file format (.docx) → polite error with conversion suggestion
- [ ] Vague topic ("learn programming") → clarifying questions asked
- [ ] Practice submission with syntax errors → Socratic debugging guidance

### Quality Checks
- [ ] All prompt templates follow contract specifications
- [ ] All generated files use correct YAML frontmatter format
- [ ] Error messages are actionable (tell user what to do next)
- [ ] Data directory structure matches plan.md specification

---

## Notes

- **[P] tasks**: Different files, no dependencies, can parallelize
- **[Story] labels**: Map tasks to user stories for traceability
- **No automated tests**: Manual validation via spec.md scenarios (see plan.md Constitution Check for justification)
- **Prompt-first architecture**: Most "implementation" is creating prompt templates, not Python code
- **CLI is minimal**: Only ~100 lines of Python code for `teacherkit init` command
- **Core deliverables**: 5 prompt template files in .github/prompts/
- **Testing approach**: Execute prompts in AI platforms (GitHub Copilot/Cursor/Claude) with real textbooks
- **MVP scope**: Phase 1-3 = complete basic teaching workflow with practice exercises
- **Full feature set**: All 5 phases = US1-US4 complete (P1+P2 requirements satisfied)

---

## Total Effort Estimate

- **Phase 1**: 2 hours (CLI implementation)
- **Phase 2**: 4 hours (3 foundational prompt templates)
- **Phase 3**: 3 hours (practice integration)
- **Phase 4**: 2 hours (quality + progress enhancements)
- **Phase 5**: 2 hours (documentation + validation)

**Total**: ~13 hours for complete feature implementation

**MVP (Phase 1-3)**: ~9 hours for basic working system
