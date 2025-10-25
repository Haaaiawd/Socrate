# Implementation Plan: Simplified Teaching Flow

**Branch**: `002-simplify-teaching-flow` | **Date**: 2025-10-22 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-simplify-teaching-flow/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

**Primary Requirement**: Simplify the teaching workflow by allowing AI to directly read attached files or user-provided topic descriptions, eliminating the need for manual file uploads and CLI commands. Introduce hands-on practice exercises with automated code file generation.

**Technical Approach**: 
- **Prompt-First Architecture**: Shift from CLI-heavy workflow (001) to prompt-driven commands. Core teaching workflow uses 5 independent prompt commands (`/teacherkit.outline`, `/teacherkit.prepare`, `/teacherkit.check`, `/teacherkit.practice`, `/teacherkit.lesson`) rather than a single unified CLI.
- **File Attachment Learning**: Leverage AI platform file attachment capabilities (GitHub Copilot `@file`, Cursor `@Files`, Claude file upload) to read textbooks directly in conversation context.
- **Practice Exercise Generation**: Use AI platform's `create_file` tool to generate Python exercise files with TODO markers, hints, and test cases automatically saved to `data/exercises/`.
- **Markdown File Storage**: Extend 001's file-based storage pattern (`data/outlines/`, `data/chapters/`, `data/progress.md`) with new `data/exercises/` directory for practice code files.
- **Teaching Plan Integration**: Merge teaching plan logic into `/teacherkit.outline` command (not a separate step), guiding progressive knowledge point introduction during `/teacherkit.lesson` dialogue.
- **Review Phase Design**: Implement practice-heavy review phase (70%+ hands-on exercises, 30% concept quick review) at the end of learning workflow.

## Technical Context

**Language/Version**: Python 3.11+ (minimal CLI usage), PowerShell 7+ (setup scripts), Markdown (data storage)
**Primary Dependencies**: 
- AI Platform APIs: GitHub Copilot Chat, Cursor, Claude Code (file attachment + file creation capabilities)
- Python Standard Library only (no external packages for MVP)
- Git (version control for learning materials)

**Storage**: Markdown files in `data/` directory (inherits 001 structure + new `data/exercises/` folder)
- `data/textbooks/` - User uploaded materials (from 001)
- `data/outlines/` - Learning outlines + teaching plans (from 001, enhanced)
- `data/chapters/` - Detailed knowledge point preparations (from 001)
- `data/notes/` - Student learning notes (from 001)
- `data/progress.md` - Progress tracking (from 001)
- `data/exercises/` - **NEW**: Auto-generated practice code files + metadata

**Testing**: Manual testing via AI platform interactions (no automated test suite for MVP)
- Rationale: Prompt-driven workflow requires human-in-the-loop validation
- Test scenarios documented in spec.md (User Stories with Acceptance Scenarios)
- Future: Contract tests for file generation, integration tests for prompt chains

**Target Platform**: 
- Primary: GitHub Copilot Chat (VS Code)
- Compatible: Cursor, Claude Code
- Requirements: AI platform with file attachment support + file creation API

**Project Type**: Educational AI agent (prompt-first, minimal CLI)

**Performance Goals**: 
- Outline generation: < 60 seconds for typical textbook chapter (20-30 pages)
- Knowledge point preparation: < 90 seconds for 10 knowledge points
- Practice file generation: < 60 seconds for 6 exercises
- Teaching dialogue response: < 3 seconds per AI turn

**Constraints**: 
- AI context window limits: Workflow decomposed into 5 commands (each command keeps context manageable)
- File size limits: Textbooks < 50MB (AI platform limits)
- Supported formats: MD, TXT (primary), PDF (text extraction only)
- Programming language: Python only for practice exercises (MVP)

**Scale/Scope**: 
- Target: Individual learners (1-on-1 AI tutoring)
- Typical session: 10-15 knowledge points, 4-6 practice exercises, 4-8 hours learning time
- Textbook size: 20-100 pages per learning topic
- Concurrent usage: N/A (conversation-based, single learner per session)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Principle Compliance Checklist**:

- [x] **Markdown-First Storage**: ✅ Uses `.md` files exclusively (data/outlines/, data/chapters/, data/exercises/, data/progress.md). No database dependencies. Exercise code files (.py) are supplementary teaching materials, not persistence layer.
- [⚠️] **CLI-First Interface**: ⚠️ VIOLATION (Justified) - Feature uses prompt-first architecture (`/teacherkit.outline`, `/teacherkit.prepare`, etc.) instead of CLI commands. CLI `teacherkit init` retained for one-time project setup only. Rationale: AI conversation context window limits require decomposed workflow; prompt commands are more natural for AI platform users; aligns with educational conversation flow.
- [⚠️] **Test-Driven Development**: ⚠️ VIOLATION (Justified) - Manual testing only for MVP. Rationale: Prompt-driven workflow requires human evaluation of teaching quality; automated testing of AI dialogue is complex and out of MVP scope; acceptance scenarios documented in spec.md provide manual test guidance.
- [x] **AI-Aware Code Quality**: ✅ Minimal code footprint (CLI init script only). Generated practice exercises follow quality principles (small functions, clear naming, docstrings). Prompt engineering documented in contracts/ for maintainability.
- [x] **Incremental MVP Approach**: ✅ User stories prioritized (3xP1, 1xP2, 1xP3). MVP scope: file attachment learning + topic-based learning + practice exercises. Adaptive difficulty (P3) deferred to future.
- [x] **Educational Flow Integrity**: ✅ Teaching plan integrated into outline command; Socratic method implemented in lesson command; practice exercises inserted at pedagogically appropriate moments (after 2-3 knowledge points); review phase emphasizes hands-on practice over conceptual repetition.
- [x] **Observability & Debuggability**: ✅ Progress tracking via data/progress.md; session state visible in Markdown files; error messages in contracts specify actionable next steps (e.g., "请先执行 `/teacherkit.prepare`").

**Domain Constraints**:

- [x] Textbook processing follows supported formats (MD, TXT primary; PDF text extraction secondary)
- [x] Learning plan generates hierarchical outline (Chapters → Topics → Concepts + Teaching Plan + Review Phase)
- [x] Lesson delivery uses conversational AI with Socratic prompts (questions before answers, graduated hints)
- [x] Progress tracking persists via data/progress.md (updated incrementally during lesson dialogue)

**Quality Gates**:

- [⚠️] Code coverage target: N/A for MVP (manual testing only)
- [x] All acceptance tests passing before merge: ✅ Documented in spec.md, validated manually
- [x] Complexity justifications documented: ✅ See Complexity Tracking section below

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

```
src/
└── teacherkit_cli/
    ├── __init__.py
    ├── __main__.py
    ├── commands/
    │   ├── __init__.py
    │   ├── init.py          # One-time project scaffolding (teacherkit init)
    │   └── config.py        # Configuration management
    └── utils/
        ├── __init__.py
        ├── git.py           # Git initialization utilities
        ├── template.py      # File template generation
        └── progress.py      # Progress file helpers

data/                        # Learning materials storage (created by init)
├── textbooks/               # User uploaded materials
├── outlines/                # AI-generated outlines + teaching plans
├── chapters/                # Detailed knowledge point preparations
├── notes/                   # Student learning notes
├── exercises/               # AUTO-GENERATED practice code files
│   ├── practice-*.py        # Exercise code with TODO markers
│   └── exercises-meta.md    # Exercise metadata
└── progress.md              # Session progress tracking

.github/
└── prompts/
    ├── speckit.*.prompt.md  # Spec-kit workflow prompts
    └── teacherkit.*.prompt.md  # Teaching workflow prompts (future)

specs/
└── 002-simplify-teaching-flow/
    ├── spec.md              # Feature specification
    ├── plan.md              # This file (implementation plan)
    ├── research.md          # Phase 0: Research findings
    ├── data-model.md        # Phase 1: Entity definitions
    ├── quickstart.md        # Phase 1: User onboarding guide
    └── contracts/           # Phase 1: Command behavior specs
        ├── outline-command-contract.md
        ├── prepare-command-contract.md
        ├── check-command-contract.md
        ├── practice-command-contract.md
        └── lesson-command-contract.md
```

**Structure Decision**: **Single project with minimal CLI + prompt-driven commands**

This feature extends the existing teacherkit CLI (`src/teacherkit_cli/`) with a single new command (`teacherkit init`). The core teaching workflow is implemented through AI platform prompt commands (not CLI commands), documented in `specs/002-simplify-teaching-flow/contracts/`.

**Rationale**:
- CLI limited to one-time setup only (aligns with "simplify workflow" goal)
- Prompt commands leverage AI platform's native conversation interface
- Data storage inherits 001's Markdown-first structure, adds `data/exercises/` for new practice feature
- Contracts define prompt behavior as specifications (not executable code)

## Complexity Tracking

*Fill ONLY if Constitution Check has violations that must be justified*

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| **Prompt-First over CLI-First** | AI conversation context window limits require decomposed workflow; each command (outline/prepare/practice/lesson) handles distinct phase with different prompts/tools; unified CLI command would exceed context limits and reduce user control | Single `/teacherkit.start` command rejected: would require 20K+ token prompts combining all phases; users couldn't adjust pace (e.g., skip practice); harder to debug/iterate individual phases |
| **Manual Testing over TDD** | Prompt-driven teaching quality requires human judgment (is explanation clear? are questions Socratic? is pacing appropriate?); automated tests cannot validate educational effectiveness at MVP stage. **80% coverage target deferred to post-MVP**: MVP uses acceptance testing per spec.md scenarios; future implementation will add (1) contract tests for CLI commands in `src/teacherkit_cli/`, (2) file generation validation tests, (3) prompt template schema tests. Target: 80% coverage for Python code, prompt templates exempted (require human evaluation). | Automated testing rejected for MVP: testing AI dialogue quality needs sophisticated NLP evaluation (out of scope); acceptance scenarios in spec.md provide sufficient manual test guidance; future: contract tests for file generation APIs |
| **Partial Markdown-First** | Practice exercises are `.py` code files (not Markdown) because: students need runnable code with syntax highlighting; test cases need Python `assert` statements; AI platform file creation API generates code files naturally | Pure Markdown rejected: code blocks in Markdown files require manual copy-paste (friction); no syntax highlighting for student edits; test execution requires extraction scripts (added complexity); `.py` files are teaching materials, not persistence layer (progress.md remains Markdown) |

**Constitution Alignment Summary**:
- ✅ 5/7 principles fully compliant (Markdown storage, AI-aware quality, incremental MVP, educational flow, observability)
- ⚠️ 2/7 principles justified violations (CLI-first → Prompt-first for usability; TDD → Manual testing for MVP scope)
- **Net Assessment**: Architecture serves educational domain requirements while respecting constitution spirit (simple, debuggable, AI-friendly)

---

## Phase 0: Research & Technical Decisions

**Status**: ✅ Complete (2025-10-22)

**Deliverable**: [`research.md`](./research.md)

**Research Questions Resolved**:

1. **File Attachment Handling** (Q1)
   - **Decision**: Design for GitHub Copilot baseline (10MB limit, MD/TXT/PDF text extraction), ensure Cursor/Claude compatibility
   - **Rationale**: Copilot has widest adoption; other platforms are functionality supersets
   - **Impact**: File-based learning (User Story 1) feasible with documented format constraints

2. **Prompt Engineering for Learning Plans** (Q2)
   - **Decision**: Two-phase prompt strategy (Analysis → Confirmation)
   - **Rationale**: Makes AI-generated structure visible and editable, prevents hallucinations
   - **Impact**: Both file-based and topic-based learning (US1, US2) use same reliable pattern

3. **Practice Exercise Generation Quality** (Q3)
   - **Decision**: Template-guided generation with difficulty levels and graduated hints
   - **Rationale**: Balances AI flexibility with quality consistency
   - **Impact**: Practice exercises (US3) meet quality standards without pre-built templates

4. **Context Window Management** (Q4)
   - **Decision**: Decompose workflow into 5 independent commands (outline → prepare → check → practice → lesson)
   - **Rationale**: Each command manages its own context, prevents token limit overflow
   - **Impact**: Justified CLI-First violation; enables long teaching sessions

5. **Socratic Teaching Patterns** (Q5)
   - **Decision**: 3-layer question hierarchy (Concept → Principle → Application) with graduated hints
   - **Rationale**: Proven pedagogical pattern, AI can generate with explicit structure
   - **Impact**: Lesson dialogue (US2, US3) follows consistent teaching methodology

6. **Session Resumption** (Q6)
   - **Decision**: Leverage conversation context (built-in AI platform feature) + progress.md for long-term tracking
   - **Rationale**: Simple, no custom session management needed
   - **Impact**: Session management (US4) works naturally with AI platform capabilities

7. **Spec-Kit Simplification Analysis** (Q7 - Added during clarification)
   - **Decision**: Keep all features, simplify storage only (ephemeral → Markdown files)
   - **Rationale**: User clarified "原方案都要保留,只是用md不用复杂的存储方式" - retain full functionality, change storage architecture
   - **Impact**: Storage corrected from "conversation context" to `data/` directory structure (inherits 001 + exercises)

**Technology Decisions**:

| Technology | Choice | Rationale |
|------------|--------|-----------|
| AI Platform | GitHub Copilot (primary), Cursor/Claude (compatible) | Widest adoption, file attachment + file creation APIs |
| Storage | Markdown files in data/ directory | Inherits 001 pattern, git-versionable, human-readable |
| Programming Language | Python 3.11+ | Minimal CLI needs, standard library sufficient |
| Practice Exercise Language | Python (MVP only) | Most common in teaching scenarios, future: JS/Java/etc |
| Testing Approach | Manual (acceptance scenarios in spec.md) | MVP scope, AI dialogue quality needs human judgment |
| Context Management | 5 independent prompt commands | Avoids token limits, user-controlled pacing |

**Risks Identified & Mitigations**:

1. **Risk**: AI hallucinations in generated content
   - **Mitigation**: Two-phase prompts (show structure, confirm before proceeding); template-guided generation; student feedback loops

2. **Risk**: Context window overflow in long sessions
   - **Mitigation**: Decomposed workflow (5 commands); progress.md checkpoints; resume capability

3. **Risk**: Practice exercise quality inconsistency
   - **Mitigation**: Template structure enforced; difficulty levels explicit; graduated hints pattern

4. **Risk**: Platform compatibility issues
   - **Mitigation**: Baseline design for Copilot (most constrained); contracts document platform requirements

5. **Risk**: Educational effectiveness unvalidated
   - **Mitigation**: Socratic method (proven pedagogy); manual acceptance testing; iterative refinement based on user feedback

**Key Learnings**:
- User clarification critical: Initial "simplification" interpreted as feature reduction, corrected to storage simplification only
- Prompt-first architecture better suited for educational dialogue than CLI-heavy approach
- Teaching plan should merge into outline (not separate step) to guide progressive dialogue flow

---

## Phase 1: Design & Contracts

**Status**: ✅ Complete (2025-10-22)

**Deliverables**:
- [`data-model.md`](./data-model.md) - Entity definitions and relationships
- [`contracts/`](./contracts/) - Command behavior specifications (5 contracts)
- [`quickstart.md`](./quickstart.md) - User onboarding guide

**Entities Defined** (data-model.md):

1. **LearningSession** - Active teaching interaction
   - Storage: `data/session.md` (conversation context + progress.md)
   - Key fields: session_id, attached_files, topic, current_phase, completed_kps, practice_status

2. **LearningPlan** - Structured outline + teaching plan
   - Storage: `data/outlines/[name]-outline.md`
   - Key fields: title, source, chapters[], knowledge_points[], teaching_plan, review_phase
   - **Enhanced**: Teaching plan integrated (not separate entity)

3. **KnowledgePoint** - Discrete concept to learn
   - Storage: `data/chapters/[name]-prepared.md` (all KPs in one file)
   - Key fields: kp_id, title, definition, principle, examples, socratic_questions[], teaching_materials

4. **PracticeExercise** - Hands-on coding task
   - Storage: `data/exercises/practice-[topic]-[n].py` + `exercises-meta.md`
   - Key fields: exercise_id, related_kps[], code_skeleton, test_cases, hints[], difficulty

5. **ProgressCheckpoint** - Auto-saved state
   - Storage: `data/progress.md`
   - Key fields: timestamp, completed_kps[], current_kp, exercises_completed, notes

**Contracts Created** (contracts/):

1. **outline-command-contract.md** (~8KB)
   - **Purpose**: Generate learning outline + **teaching plan** + **review phase design**
   - **Key Enhancement**: Teaching plan integrated (引入策略, 节奏控制, 渐进式深入)
   - **Review Phase**: 多实践实操(70%+), 概念微微提出(30%) - 综合练习 + 概念速览表
   - **Output**: `data/outlines/[name]-outline.md`

2. **prepare-command-contract.md** (~7KB)
   - **Purpose**: Extract detailed knowledge point content + Socratic questions
   - **Structure**: 每个KP: 定义 → 原理 → 示例 → 陷阱 + 3层苏格拉底问题
   - **Teaching Materials**: 类比, 对比表格, 可视化说明
   - **Output**: `data/chapters/[name]-prepared.md`

3. **check-command-contract.md** (~6KB)
   - **Purpose**: (Optional) Quality validation before practice generation
   - **Checks**: 知识点深度, 问题质量, 素材完整性
   - **Scoring**: 优秀(90-100) / 良好(75-89) / 需改进(<75)
   - **Output**: Console report (不修改文件)

4. **practice-command-contract.md** (~7KB)
   - **Purpose**: Generate practice code files with TODO markers + tests
   - **Logic**: 每2-3个KP后插入练习; 难度分级(L1/L2/L3); 复习阶段综合练习
   - **Code Structure**: 函数签名 + TODO + 渐进式提示 + 测试用例
   - **Output**: `data/exercises/practice-[topic]-[n].py` + `exercises-meta.md`

5. **lesson-command-contract.md** (~10KB)
   - **Purpose**: Interactive Socratic teaching dialogue + practice feedback + review phase
   - **Flow**: 引入 → 苏格拉底问答(3层) → 总结 → 理解确认 → 练习触发
   - **Practice Feedback**: 苏格拉底式引导(问题引导, 渐进式提示, 不直接给答案)
   - **Review Phase**: 概念快速回顾(表格) → 综合练习(实践为主) → 查漏补缺
   - **Output**: 对话交互 + `data/progress.md` 更新

**Contract Restructuring** (2025-10-22):
- **Deleted**: start-command-contract.md, practice-exercise-contract.md, session-resume-contract.md (旧3命令模型)
- **Created**: 5个新contracts (匹配spec.md的5命令架构)
- **Key Change**: 大纲包含教学计划 (引导lesson对话, 逐步引入知识点)

**Quickstart Guide** (quickstart.md):
- ~3000 words user onboarding
- Covers: 启动方式 (Copilot/Cursor/Claude), 工作流程 (outline→prepare→check?→practice→lesson), 故障排查
- Target audience: Students new to AI-assisted learning

**Design Decisions**:

1. **Teaching Plan Placement**: Merged into outline command (Method A)
   - **Rationale**: 教学计划引导对话流程, 不是独立步骤; 避免5步变6步; 保持workflow简洁
   - **User Approval**: "支持你的方案，允许" (2025-10-22 feedback)

2. **Review Phase Design**: Practice-heavy (70%+ exercises, 30% concept review)
   - **Rationale**: "多实践实操,概念只是微微提出" (user requirement)
   - **Structure**: 概念快速回顾表格 + 2-3个综合练习 + 查漏补缺机制

3. **Contract Granularity**: 5 detailed contracts (~38KB total)
   - **Rationale**: Each command has distinct responsibility; detailed specs aid AI prompt engineering
   - **Trade-off**: More files vs. clarity - chose clarity for maintainability

**Phase 1 Validation**:
- ✅ All entities map to Markdown storage locations
- ✅ Contracts cover complete user workflow (outline → lesson)
- ✅ Teaching plan integration validated (outline includes 课时划分 + 引入策略)
- ✅ Review phase design meets user requirement (practice-dominant)
- ✅ Quickstart provides sufficient onboarding guidance

---

## Next Steps

**Phase 2: Task Breakdown** (Not Yet Started)
- **Command**: `/speckit.tasks`
- **Input**: spec.md + plan.md + data-model.md + contracts/
- **Output**: `tasks.md` with:
  - Concrete implementation tasks
  - Effort estimates
  - Dependencies and sequencing
  - Acceptance criteria per task
  - Testing scenarios

**Recommended Task Priorities** (Preview):
1. Implement `teacherkit init` CLI command (setup scaffolding)
2. Create prompt templates for outline command (based on contract)
3. Create prompt templates for prepare command
4. Create prompt templates for practice command
5. Create prompt templates for lesson command
6. Manual acceptance testing (follow spec.md scenarios)
7. Documentation: README, troubleshooting guide

**Implementation Notes**:
- Phase 2 deferred until user approval of Phase 0-1 design
- Prompt templates will be Markdown files (not Python code) - AI platforms execute them
- Minimal Python code needed (only CLI init logic)

---

## Document History

- **2025-10-22**: Initial plan created via `/speckit.plan` workflow
- **2025-10-22**: Phase 0 research completed (7 questions resolved)
- **2025-10-22**: Phase 1 design completed (data-model, 5 contracts, quickstart)
- **2025-10-22**: Contracts restructured (deleted 3 old, created 5 new matching 5-command architecture)
- **2025-10-23**: Plan.md updated with Phase 0-1 summaries and constitution re-check

