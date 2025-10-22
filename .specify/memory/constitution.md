<!--
Sync Impact Report:
- Version Change: INITIAL → 1.0.0
- Initial constitution creation for Teacher AI Agent project
- Principles Added: 7 core principles (Markdown-First Storage, CLI-First Interface, Test-Driven Development, AI-Aware Code Quality, Incremental MVP Approach, Educational Flow Integrity, Observability & Debuggability)
- Sections Added: Educational Domain Constraints, Development Workflow & Quality Gates, Governance
- Templates Status:
  ✅ plan-template.md - Aligned with constitution principles
  ✅ spec-template.md - Aligned with user story and testing requirements
  ✅ tasks-template.md - Aligned with TDD and MVP principles
- Follow-up TODOs: None - all placeholders filled
-->

# Teacher AI Agent Constitution

## Core Principles

### I. Markdown-First Storage
**Storage and data management MUST use Markdown files as the primary persistence layer.**

- All course content, outlines, chapter details, and learning notes MUST be stored as `.md` files
- File structure MUST follow a clear hierarchy: `outlines/`, `chapters/`, `notes/`
- Each Markdown file MUST be human-readable and git-friendly for version control
- Metadata MAY use YAML frontmatter for structured data within Markdown files
- No database dependencies for MVP - keep it simple and file-based

**Rationale**: Simplicity, portability, and version control. Students can access their notes outside the system. Developers can easily inspect and debug content.

### II. CLI-First Interface
**All interactions MUST happen through a command-line interface.**

- Every feature MUST be accessible via CLI commands (e.g., `teacher create-outline`, `teacher start-lesson`)
- Commands MUST follow standard conventions: `teacher <command> [options] [arguments]`
- Output MUST be clear and formatted for terminal display (colored text, tables, progress indicators)
- Interactive prompts are ALLOWED for complex workflows (e.g., lesson dialogues)
- Text input/output protocol: arguments/stdin → stdout, errors → stderr

**Rationale**: CLI ensures scriptability, automation potential, and keeps the MVP focused. No frontend overhead in initial phase.

### III. Test-Driven Development (NON-NEGOTIABLE)
**All code MUST follow strict TDD practices with Red-Green-Refactor cycle.**

- Tests MUST be written BEFORE implementation
- Tests MUST fail initially (Red phase) to verify they test the right behavior
- Implementation follows to make tests pass (Green phase)
- Refactoring comes after tests pass (Refactor phase)
- Minimum 80% code coverage required for core logic
- Integration tests MUST cover critical user journeys (textbook parsing, lesson generation, dialogue flow)

**Rationale**: Ensures correctness, prevents regressions, and builds confidence for AI-assisted development. Critical for educational software where accuracy matters.

### IV. AI-Aware Code Quality
**Code MUST be written with AI agent collaboration and maintenance in mind.**

- Functions MUST be small, focused, and self-documenting (max 50 lines)
- Every module MUST have a clear docstring explaining purpose, inputs, outputs
- Use type hints (Python) or type annotations consistently
- Avoid implicit behavior - make dependencies and side effects explicit
- Complex algorithms MUST include inline comments explaining "why", not "what"
- File paths MUST always be absolute to avoid ambiguity in AI tool calls
- Configuration MUST be centralized and documented (e.g., `config.yaml` or `.env`)

**Rationale**: AI agents (like GitHub Copilot, Claude) work better with explicit, well-structured code. Reduces hallucinations and improves code generation quality.

### V. Incremental MVP Approach
**Features MUST be delivered in prioritized, independently testable increments.**

- User stories MUST be prioritized (P1, P2, P3...) based on user value
- Each user story MUST be independently testable and deliverable
- P1 features form the MVP - MUST be completed before P2/P3
- No feature creep - YAGNI (You Aren't Gonna Need It) principle strictly enforced
- Each increment MUST deliver tangible user value (e.g., "teacher can create outline" is P1)

**Rationale**: Enables fast iteration, early feedback, and prevents scope bloat. Essential for small projects with limited resources.

### VI. Educational Flow Integrity
**The system MUST respect pedagogical principles and maintain learning context.**

- TODO system MUST track the current teaching state (outline → chapter → lesson → quiz)
- AI MUST load context (current chapter, previously covered topics) before each interaction
- Teaching dialogues MUST follow Socratic method: ask questions, guide discovery
- Knowledge points MUST be granular and testable per chapter
- Student progress MUST be trackable (completed chapters, quiz results, notes)

**Rationale**: This is an educational tool. The learning experience must be coherent, progressive, and pedagogically sound. Context-aware AI is critical.

### VII. Observability & Debuggability
**All operations MUST be transparent, loggable, and debuggable.**

- Structured logging MUST be used (timestamp, level, module, message)
- Log files MUST be stored in a dedicated `logs/` directory
- CLI commands MUST support `-v/--verbose` and `-d/--debug` flags
- AI prompts and responses MUST be logged for debugging (sanitize sensitive data)
- Error messages MUST be actionable (tell user what went wrong and how to fix)

**Rationale**: Text-based I/O and file-based storage make debugging transparent. Logs enable post-mortem analysis and continuous improvement.

## Educational Domain Constraints

### Textbook Processing
- MUST support common textbook formats: PDF, Markdown, plain text (MVP: plain text/Markdown)
- Parser MUST extract chapters, sections, and key concepts
- MUST handle malformed input gracefully (skip unreadable sections, log warnings)
- Future versions MAY integrate web search for supplementary materials

### Learning Plan Generation
- MUST generate a hierarchical outline: Course → Chapters → Sections → Knowledge Points
- Each knowledge point MUST include: concept name, description, difficulty level, prerequisite knowledge
- MUST support custom teaching pace (fast/normal/slow) in future versions

### Lesson Delivery
- Dialogue mode MUST use conversational AI (e.g., OpenAI, Claude) with educational prompts
- MUST support predefined question templates per knowledge point
- MUST allow student to trigger explanations, examples, or quizzes
- Student responses MUST be evaluated for understanding (simple keyword matching for MVP)

### Note-Taking & Progress Tracking
- Students MUST be able to mark text during lessons for note collection (future: text selection; MVP: manual command)
- Progress MUST persist across sessions (track completed chapters, current position)
- TODO list MUST be visible in CLI status command (e.g., `teacher status`)

## Development Workflow & Quality Gates

### Code Review & Merge Criteria
- All PRs MUST pass automated tests (unit + integration)
- Code coverage MUST not decrease below 80%
- At least one peer review REQUIRED for core logic changes
- Constitution compliance MUST be verified (checklist in PR template)

### Complexity Justification
- Any violation of simplicity principles MUST be documented in `plan.md` Complexity Tracking table
- Justification MUST explain why simpler alternatives are insufficient
- Technical debt MUST be tracked in `TODO.md` with mitigation plan

### Versioning Policy
- MAJOR.MINOR.PATCH semantic versioning
- MAJOR: Breaking CLI command changes or incompatible file format changes
- MINOR: New features (new commands, new teaching modes)
- PATCH: Bug fixes, performance improvements, documentation updates

## Governance

**Constitution Authority**: This constitution supersedes all other project practices and conventions. In case of conflict, constitution principles take precedence.

**Amendment Process**:
1. Propose amendment with rationale in GitHub issue
2. Discuss with stakeholders (team, users if applicable)
3. Document impact on existing code/templates
4. Update constitution version (MAJOR for principle removal/redefinition, MINOR for additions, PATCH for clarifications)
5. Propagate changes to affected templates and documentation
6. Commit with message: `docs: amend constitution to vX.Y.Z (<change summary>)`

**Compliance Verification**:
- Every feature specification MUST include a Constitution Check section
- Every implementation plan MUST verify compliance before Phase 0 research
- Code reviews MUST explicitly verify adherence to principles

**Guidance Integration**:
- Runtime development guidance is embedded in this constitution
- For agent-specific workflows, refer to `.github/prompts/speckit.*.prompt.md` files
- When in doubt, prioritize simplicity, testability, and user value

**Version**: 1.0.0 | **Ratified**: 2025-10-21 | **Last Amended**: 2025-10-21
