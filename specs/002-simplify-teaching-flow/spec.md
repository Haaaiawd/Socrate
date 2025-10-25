# Feature Specification: Simplified Teaching Flow with Practice Exercises

**Feature Branch**: `002-simplify-teaching-flow`  
**Created**: 2025-10-22  
**Status**: Draft  
**Input**: User description: "简化教学流程:允许AI直接读取附加文件或用户描述内容,引入实操练习环节"

## Clarifications

### Session 2025-10-22

- Q: CLI `init` 命令作为"启动器"不能少,但规格说明强调"简化流程,无需CLI命令"。这两者如何协调? → A: CLI `init` 仅在首次使用时运行一次,创建项目结构;后续学习无需CLI。仅在每次创建新的学习内容时使用。

- Q: `/teacherkit.start` 应细化为多步骤执行(规划大纲 → 抽取知识点设置问题 → 质量检查 → 构建实操练习 → 开始教学对话)。这些步骤应该如何组织? → A: 每一步都是独立的prompt指令,用户依次执行直到进入教学对话。原因:AI对话上下文窗口有限,每步所需提示词和工具不同,拆分成多个命令更可控。

- Q: `/teacherkit.check` 质量检查步骤的触发机制? → A: 作为可选手动命令,用户按需调用。核心工作流为 outline → prepare → practice → lesson(必须步骤),用户可在prepare后选择性运行check进行质量验证。

- Q: 实操练习文件的生成和存储位置? → A: 练习文件自动保存到项目目录(如 `data/exercises/practice-xxx.py`)。AI平台(Copilot/Cursor/Claude Code)本身具有文件系统操作能力和权限,创建专门文件夹存放练习代码更有组织性。

- Q: 与 github/spec-kit 的架构对齐程度? → A: 模式对齐 - 借鉴多阶段命令链、提示词驱动架构、Markdown数据格式等通用模式,但命令名称和流程逻辑根据教学场景独立设计,不强制复用spec-kit的软件开发特定工作流。

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Direct File Attachment Learning (Priority: P1) 🎯 MVP

A student wants to start learning by simply attaching a file (PDF, TXT, MD) to the AI conversation, without manually uploading to specific directories or running CLI commands.

**Why this priority**: This dramatically simplifies the user experience. Instead of the multi-step process (upload file → run CLI → parse → prepare), students can just attach a file and say "teach me this". This removes friction and makes the system feel like a natural AI conversation.

**Independent Test**: Can be fully tested by attaching a textbook file to Copilot Chat, typing `/teacherkit.start`, and verifying the AI reads the content and generates a learning plan without requiring any file system operations.

**Acceptance Scenarios**:

1. **Given** a student has a textbook file on their computer, **When** they attach it to Copilot Chat and type `/teacherkit.start`, **Then** the AI reads the file content directly, analyzes its structure, and presents a learning plan
2. **Given** the AI has read an attached file, **When** it generates the learning plan, **Then** the plan includes chapters/sections extracted from the file structure, with estimated study times
3. **Given** a student attaches multiple files (e.g., PDF + notes), **When** `/teacherkit.start` is invoked, **Then** the AI analyzes all files and creates a unified learning plan
4. **Given** an attached file in an unsupported format, **When** the student tries to start learning, **Then** the AI politely explains the limitation and suggests converting to supported formats (MD, TXT, PDF)

---

### User Story 2 - Topic-Based Learning Without Files (Priority: P1) 🎯 MVP

A student wants to learn a topic (e.g., "Python loops", "machine learning basics") without providing a textbook, relying on the AI to generate the learning content.

**Why this priority**: Not all students have structured textbooks. This enables ad-hoc learning where the AI becomes both content creator and teacher, using its training knowledge to construct a learning path.

**Independent Test**: Can be fully tested by typing `/teacherkit.start "Python for loops"` without any attachments, and verifying the AI generates a complete learning outline with knowledge points and teaching plan.

**Acceptance Scenarios**:

1. **Given** a student wants to learn a specific topic, **When** they type `/teacherkit.start "topic description"`, **Then** the AI generates a structured learning outline (3-5 main concepts, sub-topics, examples)
2. **Given** the AI has generated an outline, **When** teaching begins, **Then** the AI presents knowledge points in a logical sequence with Socratic questions
3. **Given** a very broad topic (e.g., "learn programming"), **When** the student requests it, **Then** the AI asks clarifying questions (language? goals? prior experience?) to narrow the scope
4. **Given** a very specific topic (e.g., "Python list comprehension"), **When** learning starts, **Then** the AI provides a focused 15-20 minute lesson with examples and practice

---

### User Story 3 - Integrated Practice Exercises with Code Files (Priority: P1) 🎯 MVP

A student learning programming wants hands-on practice through exercises where they fill in missing code, and the AI provides guidance and feedback.

**Why this priority**: Reading alone doesn't solidify programming skills. Practice exercises transform passive learning into active application, which is critical for technical topics. This differentiates the system from a simple Q&A bot.

**Independent Test**: Can be fully tested by reaching a practice checkpoint in a lesson, receiving a code file with TODO markers, completing the exercise, and getting AI feedback.

**Acceptance Scenarios**:

1. **Given** a student is learning a programming concept, **When** they complete the theoretical knowledge points, **Then** the AI offers a practice exercise: "Ready to try coding this yourself?"
2. **Given** the student accepts a practice exercise, **When** the AI generates it, **Then** a new code file is created with:
   - Clear function/variable names indicating the concept
   - TODO comments marking areas to complete
   - Example test cases to verify correctness
   - Helpful hints in comments
3. **Given** a student has completed a practice file, **When** they submit it (via attachment or running code), **Then** the AI reviews the solution, provides feedback (what works, what could improve), and asks guiding questions rather than giving direct corrections
4. **Given** a student struggles with an exercise, **When** they ask for help, **Then** the AI provides graduated hints (conceptual → specific → partial solution) without immediately revealing the full answer
5. **Given** a student completes an exercise correctly, **When** the AI reviews it, **Then** the AI celebrates the achievement and suggests an extension challenge or next concept

---

### User Story 4 - Seamless Learning Session Management (Priority: P2)

A student wants to pause and resume learning sessions naturally within the conversation, without explicit save/load commands.

**Why this priority**: Modern chat interfaces maintain conversation context. The system should leverage this to make pausing and resuming feel natural (just close and reopen the chat) rather than requiring explicit commands.

**Independent Test**: Can be fully tested by starting a lesson, pausing (closing chat), reopening later, and verifying the AI remembers where the student left off.

**Acceptance Scenarios**:

1. **Given** a student is mid-lesson, **When** they close the chat window or stop responding, **Then** their progress is automatically saved to conversation context
2. **Given** a student returns to the conversation later, **When** they greet the AI or ask to continue, **Then** the AI resumes from the last knowledge point or practice exercise
3. **Given** a student wants to review what they've covered, **When** they ask "what have we learned so far?", **Then** the AI provides a summary of completed topics and current progress
4. **Given** a long break between sessions (days/weeks), **When** the student returns, **Then** the AI offers a quick review: "Last time we covered [X]. Would you like a quick recap before continuing?"

---

### User Story 5 - Adaptive Practice Difficulty (Priority: P3)

The AI adjusts exercise difficulty based on student performance, offering simpler problems if struggling or more challenging ones if excelling.

**Why this priority**: Enhances learning effectiveness but not critical for MVP. Basic practice exercises are sufficient initially; adaptive difficulty adds polish.

**Independent Test**: Can be tested by completing exercises with varying success rates and observing whether subsequent exercises adjust in complexity.

**Acceptance Scenarios**:

1. **Given** a student completes multiple exercises easily (< 1 hint needed), **When** the AI generates the next exercise, **Then** it increases complexity (e.g., combining multiple concepts, removing some hints)
2. **Given** a student struggles with exercises (>3 hints or incorrect solutions), **When** the AI generates the next exercise, **Then** it simplifies (breaks into smaller steps, adds more hints, uses clearer examples)
3. **Given** a student's performance improves over time, **When** reviewing progress, **Then** the AI acknowledges growth: "You're getting stronger at [concept]! Let's try something a bit trickier."

---

### Edge Cases

- **What happens when a student attaches a very large file (>100MB)?**  
  AI warns: "This file is quite large. It may take a moment to analyze. Would you like me to focus on specific chapters instead of the whole book?" Then processes in chunks if user confirms.

- **How does the system handle corrupted or unreadable files?**  
  AI detects the issue and responds: "I'm having trouble reading this file. It might be corrupted. Could you try converting it to plain text or Markdown?"

- **What if a student submits a practice exercise with syntax errors?**  
  AI treats it as a teaching moment: "I notice there's a syntax issue on line X. What do you think the error message is telling us?" (Socratic approach to debugging)

- **How does the AI handle off-topic practice submissions?**  
  AI gently redirects: "This is interesting code, but it doesn't seem related to [current topic]. Let's focus on the exercise: [restates task]. Want to give it another try?"

- **What if a student requests a topic the AI knows little about?**  
  AI is honest: "I can help with the fundamentals, but this is a specialized topic. I recommend these resources: [links]. Should we start with the basics I do know well?"

- **How does conversation context loss (API limits) affect session continuity?**  
  AI detects when context is nearing limits and proactively saves progress: "We've covered a lot today! Let me save your progress. You can start fresh next time with '/teacherkit.resume'."

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST accept file attachments (PDF, MD, TXT) directly in the chat interface without requiring file system uploads
- **FR-002**: System MUST read and analyze attached file content to extract learning structure (chapters, sections, topics)
- **FR-003**: System MUST generate learning plans from user-provided topic descriptions when no file is attached
- **FR-004**: System MUST present the generated learning plan with hierarchical structure (main concepts → sub-topics → knowledge points)
- **FR-004a**: Teaching workflow MUST be decomposed into sequential prompt commands, each handling a distinct phase:
  - `/teacherkit.outline` - (Required) Generate learning outline from file/topic
  - `/teacherkit.prepare` - (Required) Extract knowledge points and formulate Socratic questions
  - `/teacherkit.check` - (Optional) Validate knowledge point quality (depth, breadth, question appropriateness) - user may skip
  - `/teacherkit.practice` - (Required) Identify appropriate positions for practice exercises and generate exercise skeletons
  - `/teacherkit.lesson` - (Required) Begin interactive teaching dialogue
- **FR-004b**: Each prompt command MUST be designed with context-efficient prompts and appropriate tool usage for its specific phase
- **FR-004c**: Core teaching workflow (outline → prepare → practice → lesson) MUST be completable without running optional check command
- **FR-005**: System MUST conduct Socratic dialogue for theoretical knowledge points as defined in the existing teaching prompt
- **FR-006**: System MUST detect appropriate moments to offer practice exercises (after completing 2-3 related knowledge points)
- **FR-007**: System MUST generate practice code files with:
  - Automatic save to dedicated directory (`data/exercises/` or equivalent)
  - Clear naming conventions (e.g., `practice-[topic]-[number].py`)
  - TODO/START CODE/END CODE markers indicating fill-in sections
  - Example test cases or expected outputs
  - Conceptual hints in comments
- **FR-007a**: Practice file generation MUST leverage AI platform's file system capabilities (create_file tool in Copilot/Cursor/Claude Code) to write files directly
- **FR-008**: System MUST accept completed practice code via attachment or inline code blocks
- **FR-009**: System MUST review practice submissions using Socratic method (ask what the student tried, guide toward corrections) rather than providing direct fixes
- **FR-010**: System MUST provide graduated hints for struggling students (conceptual → specific → partial code)
- **FR-011**: System MUST celebrate successful completions and offer extension challenges
- **FR-012**: System MUST maintain learning progress within conversation context
- **FR-013**: System MUST detect when students return after a break and offer to resume or recap
- **FR-014**: System MUST handle topic clarification dialogue (ask questions when request is too broad)
- **FR-015**: System MUST log key learning milestones (completed topics, practice exercises, session times) for progress tracking
- **FR-016**: System MUST support switching between topics mid-session if student requests
- **FR-017**: System MUST provide actionable error messages when files cannot be read or topics are unclear
- **FR-018**: System MUST generate example-driven explanations for abstract concepts (analogy, real-world scenario, code snippet)

### Key Entities

- **Learning Session**: Represents an active teaching interaction. Attributes: session ID (auto-generated), attached files list, topic description, current phase (planning/teaching/practicing), current knowledge point, completed knowledge points, practice exercises attempted, total time elapsed. Relationship: One session per conversation thread.

- **Learning Plan**: Structured outline generated from file or topic. Attributes: title, source (file attachment or AI-generated), main concepts list (with sub-topics), estimated duration, difficulty level. Relationship: One plan per session.

- **Knowledge Point**: Discrete concept to learn. Attributes: KP ID, title, description, type (theory/practice), Socratic questions list, mastery status (not started/learning/practiced/mastered). Relationship: Multiple KPs per Learning Plan.

- **Practice Exercise**: Hands-on coding task. Attributes: exercise ID, related KP, programming language, skeleton code (with TODOs), test cases, hints, student solution (when submitted), feedback given, completion status. Relationship: Multiple exercises per Knowledge Point (optional).

- **Progress Checkpoint**: Auto-saved state. Attributes: timestamp, completed KPs, current KP, exercises completed, conversation context snapshot. Relationship: Multiple checkpoints per session (auto-saved every 10 minutes).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can start learning within 30 seconds of attaching a file or describing a topic (no CLI commands or file uploads required)
- **SC-002**: 90% of attached files (MD, TXT, PDF under 50MB) are successfully parsed and generate a structured learning plan
- **SC-003**: AI generates coherent learning plans for common topics (programming, math, science) from text descriptions alone in 95% of cases
- **SC-004**: Practice exercises are offered at appropriate intervals (after 2-3 theoretical KPs) in 100% of programming-related sessions
- **SC-005**: Generated practice code files include clear TODOs, hints, and test cases in 100% of exercises
- **SC-006**: AI provides Socratic feedback (questions before answers) for practice submissions in 90% of interactions
- **SC-007**: Students can resume sessions after breaks with context intact (last topic, progress) in 85% of cases within conversation history limits
- **SC-008**: Students report the learning flow feels "natural and conversational" rather than "command-driven" in qualitative feedback (target: 80% positive sentiment)
- **SC-009**: Average time to first practice exercise is under 15 minutes for typical programming topics
- **SC-010**: Students successfully complete at least one practice exercise per session in 70% of programming-related learning sessions
- **SC-011**: Error messages for unsupported files or unclear topics provide actionable next steps in 100% of cases

## Assumptions

- **CLI Init Command**: The `teacherkit init` CLI command is retained for one-time project setup (creating directory structure, git initialization, `.vscode/` configuration). Students run this once when creating a new learning project, then rely entirely on prompt commands for daily learning activities.
- **Multi-Step Prompt Commands**: Teaching workflow is decomposed into sequential prompt commands (outline → prepare → check → practice → lesson) rather than a single unified command. Rationale: AI conversation context windows are limited; each phase requires different prompt engineering and tools. Sequential execution provides better control and context efficiency.
- **File Format Support**: MVP supports text-based formats (MD, TXT) fully. PDF support is basic (text extraction only, no OCR for scanned documents). Proprietary formats (DOCX, EPUB) are out of scope for MVP.
- **AI Context Limits**: Assumes conversation context can hold ~10-15 knowledge points worth of dialogue before summarization is needed. Long textbooks may require chapter-by-chapter approach.
- **Practice Exercise Languages**: MVP focuses on Python for code exercises (most common in teaching scenarios). Other languages (JavaScript, Java, C++) deferred to future versions.
- **Code Execution**: MVP does not execute student code automatically. Students run code themselves and report results. Auto-execution with sandboxing is a future enhancement.
- **Single Topic Per Session**: MVP handles one learning topic per conversation thread. Multi-topic management (parallel tracks) is deferred. Students can use `teacherkit init` to create separate projects for different learning topics.
- **Markdown File Storage**: Learning artifacts (outlines, chapters, exercises, progress) are persisted as `.md` files in `data/` directory structure (inherited from Feature 001). No database dependencies. AI platform file creation APIs (`create_file`, `read_file`) handle file operations. Progress tracking uses `data/progress.md` with YAML frontmatter for session resumption (US4). Rationale: Simplifies storage architecture compared to complex persistence systems while maintaining conversation context benefits.
- **English Language**: MVP focuses on English-language teaching. Internationalization is deferred.
- **Self-Motivated Learners**: Assumes students will complete practice exercises independently. Gamification, reminders, or enforcement mechanisms are out of scope for MVP.
- **AI Platform**: Designed for GitHub Copilot Chat, Cursor, Claude Code (tools with file attachment support). May require adaptations for other AI platforms.
- **File System Access**: Assumes AI platform has file creation/modification capabilities (e.g., `create_file` tool). Practice exercise files are automatically saved to `data/exercises/` directory without requiring manual file operations from students.
- **Architecture Pattern**: Follows spec-kit's multi-stage command pattern (outline → prepare → lesson analogous to specify → plan → tasks) and prompt-driven design philosophy. However, command semantics and workflow logic are tailored for educational scenarios rather than software specification workflows.


