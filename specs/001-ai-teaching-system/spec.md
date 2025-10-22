# Feature Specification: AI Teaching System

**Feature Branch**: `001-ai-teaching-system`  
**Created**: 2025-10-21  
**Status**: Draft  
**Input**: User description: "一个教师智能体,有以下流程: 1. 学生提供教材(MVP),或者自动搜索相应教材(后续版本) 2. 解析教材,确定学习计划,列出教学大纲 3. 根据学习大纲确定每个章节所需要掌握的知识点,格式为每次对话需要抛出的知识点和预设的提问 4. 备课完成,开始教学,用openai教学的提示词,我们是对话式学习 5. 最好让我能够直接在AI的输出上,选择部分文字标记,这样这部分就会记录在我的笔记板块"

## Clarifications

### Session 2025-10-21

- Q: CLI 架构模式 → A: **双层架构** - CLI工具负责仓库初始化和配置管理(类似spec-kit的`specify init`),提示词命令(`/teacherkit.*`)负责教学交互(解析教材、备课、上课)
- Q: CLI 工具范围 → A: **最小化CLI** - 只提供`teacherkit init`(项目初始化)和`teacherkit config`(配置检查/更新)命令,其余教学功能通过Copilot Chat提示词命令实现
- Q: CLI 实现语言 → A: **Python + Typer** - 采用与spec-kit相同的技术栈(Python 3.11+, Typer CLI框架, uv包管理器),PowerShell脚本作为底层工具被CLI和提示词命令共同调用
- Q: CLI 安装方式 → A: **uv工具安装** - 持久安装: `uv tool install teacherkit --from git+<repo-url>`,或一次性使用: `uvx --from git+<repo-url> teacherkit init <project>`
- Q: CLI 命令命名 → A: **teacherkit + /teacherkit.*** - CLI工具名为`teacherkit`,初始化命令为`teacherkit init`,提示词命令为`/teacherkit.parse`, `/teacherkit.prepare`, `/teacherkit.lesson`等

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Textbook Upload and Outline Generation (Priority: P1) 🎯 MVP

A student wants to start learning from a textbook by uploading it and getting an organized learning outline.

**Why this priority**: This is the foundation of the entire system. Without textbook parsing and outline generation, no other teaching activities can begin. It delivers immediate value by transforming unstructured content into a structured learning path.

**Independent Test**: Can be fully tested by uploading a sample Markdown/text textbook file and verifying that a hierarchical outline (Course → Chapters → Sections → Knowledge Points) is generated and saved as a Markdown file.

**Acceptance Scenarios**:

1. **Given** a student has uploaded a textbook file in Markdown format, **When** they use `/teacherkit.parse <textbook-path>` in Copilot Chat, **Then** the system parses the content and generates an outline file at `data/outlines/[textbook-name]-outline.md` with a hierarchical structure
2. **Given** an outline has been created, **When** the student uses `/teacherkit.view-outline`, **Then** the system displays the complete outline with chapters, sections, and estimated study time
3. **Given** a textbook with unclear structure (no clear chapter headings), **When** the outline generation runs, **Then** the system attempts best-effort parsing and logs warnings for manual review
4. **Given** a very large textbook (>10MB), **When** parsing begins, **Then** the system shows progress indicators and completes within reasonable time (< 2 minutes for text files)

---

### User Story 2 - Chapter Preparation and Knowledge Point Extraction (Priority: P1) 🎯 MVP

An AI teacher prepares a specific chapter by extracting knowledge points and generating guiding questions for each concept.

**Why this priority**: This is essential for structured teaching. The AI needs well-defined knowledge points and questions to guide students effectively through dialogues. Without this, teaching conversations would be unfocused.

**Independent Test**: Can be fully tested by selecting a chapter from an existing outline and verifying that knowledge points are extracted with associated Socratic-style questions, saved as a chapter MD file.

**Acceptance Scenarios**:

1. **Given** an outline exists with multiple chapters, **When** the student uses `/teacherkit.prepare 1` in Copilot Chat, **Then** the system extracts 5-10 key knowledge points from Chapter 1 with descriptions and difficulty levels
2. **Given** knowledge points have been extracted for a chapter, **When** preparation continues, **Then** the system generates 2-3 Socratic guiding questions per knowledge point (e.g., "What might happen if...", "How would you explain...") 
3. **Given** a prepared chapter file, **When** the student uses `/teacherkit.show-chapter 1`, **Then** they see an organized list of knowledge points with their questions (but not answers yet)
4. **Given** a chapter with complex topics, **When** preparation runs, **Then** the system marks advanced concepts with appropriate difficulty tags (Beginner/Intermediate/Advanced)

---

### User Story 3 - Interactive Socratic Dialogue Learning (Priority: P1) 🎯 MVP

A student engages in a guided learning conversation where the AI teacher uses Socratic questioning to help them discover answers rather than providing direct solutions.

**Why this priority**: This is the core teaching interaction that differentiates this system from a simple Q&A bot. It enables active learning and critical thinking, which is the primary educational value proposition.

**Independent Test**: Can be fully tested by starting a lesson session for a prepared chapter, engaging in dialogue, and verifying that the AI asks guiding questions, checks understanding, and avoids giving direct answers until the student demonstrates comprehension.

**Acceptance Scenarios**:

1. **Given** a prepared chapter with knowledge points, **When** the student uses `/teacherkit.lesson 1` in Copilot Chat, **Then** the system initializes an interactive dialogue session and presents the first knowledge point with a guiding question
2. **Given** an active lesson session, **When** the student types a response, **Then** the AI evaluates the answer and either asks a follow-up question, provides a hint, or confirms understanding before moving to the next point
3. **Given** a student asks for a direct answer, **When** the AI detects this pattern (e.g., "just tell me the answer"), **Then** the system gently redirects with "Let's think through this together. What do you think would happen if...?"
4. **Given** a student repeatedly struggles with a concept, **When** 3+ incorrect attempts occur, **Then** the AI provides a more detailed hint or a simpler analogical explanation while still encouraging independent thinking
5. **Given** a lesson is in progress, **When** the student types `exit` or `pause`, **Then** the system saves progress (current knowledge point, session notes) and allows resuming later with `/teacherkit.resume`

---

### User Story 4 - Progress Tracking and Learning Path Management (Priority: P2)

A student wants to see their learning progress, completed chapters, and what's next in their study plan.

**Why this priority**: While not essential for the initial MVP teaching interaction, progress tracking significantly improves user experience and motivation. It helps students stay organized and see their learning journey.

**Independent Test**: Can be fully tested by completing several lesson sessions and then running status/progress commands to verify accurate tracking of completed chapters, current position, and remaining topics.

**Acceptance Scenarios**:

1. **Given** multiple lesson sessions have been completed, **When** the student uses `/teacherkit.status`, **Then** the system displays: current chapter, completed chapters (✓), in-progress chapters (~), upcoming chapters, and overall progress percentage
2. **Given** progress data exists, **When** the student uses `/teacherkit.next`, **Then** the system recommends the next logical chapter or knowledge point based on prerequisites and completion status
3. **Given** a student has completed a full chapter, **When** they view their status, **Then** the system marks that chapter as complete (✓) and unlocks dependent chapters if any
4. **Given** long breaks between sessions, **When** the student returns and checks status, **Then** the system provides a brief recap of the last studied topic

---

### User Story 5 - Note Taking and Highlight Capture (Priority: P3)

A student can mark important text or concepts during lessons and save them to a personal notes board for later review.

**Why this priority**: This enhances the learning experience but is not critical for the core MVP. It adds value for students who want to create personalized study materials from their sessions.

**Independent Test**: Can be fully tested by simulating a lesson session where the student marks specific text/concepts, then verifying those highlights are saved to a notes file and can be retrieved later.

**Acceptance Scenarios**:

1. **Given** an active lesson session, **When** the student types `mark [text or concept ID]`, **Then** the system saves that snippet to `data/notes/[textbook-name]-notes.md` with timestamp and chapter context
2. **Given** accumulated notes, **When** the student uses `/teacherkit.notes`, **Then** the system displays all saved highlights organized by chapter with links back to source material
3. **Given** notes exist, **When** the student wants to export them, **Then** they can use `/teacherkit.export-notes md` (MVP supports Markdown only; future: PDF/HTML)

**Note**: P3 priority because initial MVP can function without this feature. Students can manually copy-paste important text as a workaround.

---

### Edge Cases

- **What happens when a textbook file is corrupted or unreadable?**  
  System attempts parsing, logs specific errors (e.g., "Line 45: invalid character"), and asks user to fix the file or provide a different format. Partial parsing is saved if any valid sections exist.

- **How does the system handle extremely long lesson sessions (> 1 hour)?**  
  System automatically suggests breaks every 30 minutes with a gentle reminder: "We've been studying for a while. Take a 5-minute break?" Progress is auto-saved every 5 minutes to prevent data loss.

- **What if a student's response is completely off-topic during Socratic dialogue?**  
  AI acknowledges the response politely ("That's an interesting thought!") but gently guides back: "For this concept, let's focus on [topic]. Can you think about...?"

- **What happens if the AI cannot generate meaningful questions for a knowledge point?**  
  System flags the knowledge point as "manual review needed" in the preparation log and uses generic fallback questions (e.g., "Can you explain this concept in your own words?")

- **How does the system handle multiple students using the same installation?**  
  MVP: Single-user mode only. Each student needs a separate installation or workspace directory. Future: Add user profiles with `--user` flag.

- **What if internet connection fails during a lesson (AI API call)?**  
  System displays error message, saves current session state, and suggests offline review of chapter materials until connection is restored. Retries API call with exponential backoff.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST accept textbook files in Markdown (.md) and plain text (.txt) formats
- **FR-002**: System MUST parse textbook content and identify hierarchical structure (chapters, sections, subsections)
- **FR-003**: System MUST generate an outline file in Markdown format with YAML frontmatter containing metadata (title, total chapters, creation date)
- **FR-004**: System MUST extract 5-10 knowledge points per chapter with descriptions, difficulty levels (Beginner/Intermediate/Advanced), and prerequisite knowledge
- **FR-005**: System MUST generate 2-3 Socratic-style guiding questions per knowledge point
- **FR-006**: System MUST provide CLI commands for repository initialization (`teacherkit init`) and prompt commands for teaching workflows (`/teacherkit.parse`, `/teacherkit.prepare`, `/teacherkit.lesson`, etc.)
- **FR-007**: System MUST maintain an interactive dialogue session where AI acts as a Socratic tutor (asks questions, gives hints, avoids direct answers)
- **FR-008**: System MUST evaluate student responses for understanding and adjust follow-up questions accordingly
- **FR-009**: System MUST save lesson progress automatically (current chapter, knowledge point, session state) every 5 minutes and on exit
- **FR-010**: System MUST persist all data (outlines, chapters, notes, progress) as Markdown files in `data/` directory
- **FR-011**: System MUST track student progress (completed chapters, current position) and display it via `/teacherkit.status` command
- **FR-012**: System MUST support text marking/highlighting during lessons with `mark [text]` command
- **FR-013**: System MUST save marked highlights to a notes file with timestamp and chapter context
- **FR-014**: System MUST load and display saved notes via `/teacherkit.notes` command
- **FR-015**: System MUST log all AI prompts, responses, and errors for debugging (sanitize sensitive data)
- **FR-016**: System MUST provide actionable error messages (e.g., "File not found. Please check the path: /path/to/file")
- **FR-017**: System MUST support verbose (`-v`) and debug (`-d`) flags for detailed output
- **FR-018**: System MUST integrate with AI APIs (OpenAI GPT-4 for MVP) for Socratic dialogue generation
- **FR-019**: System MUST use educational prompt templates that enforce Socratic method behaviors
- **FR-020**: System MUST detect and gracefully handle API failures (retry with backoff, save state, inform user)

### Key Entities

- **Textbook**: Represents the source learning material. Attributes: title, file path, format (md/txt), total chapters, creation date. Relationship: One textbook has many chapters.

- **Outline**: Structured representation of textbook content. Attributes: course name, chapters list (with titles and section counts), estimated total study time, generation date. Relationship: One outline per textbook.

- **Chapter**: A major division of learning content. Attributes: chapter number, title, knowledge points list, difficulty level, estimated study time, preparation status (prepared/not prepared). Relationship: Belongs to one textbook, contains multiple knowledge points.

- **Knowledge Point**: A discrete concept or skill to be learned. Attributes: ID, concept name, description, difficulty (Beginner/Intermediate/Advanced), prerequisite knowledge IDs, guiding questions list, mastery status (not started/in progress/mastered). Relationship: Belongs to one chapter.

- **Lesson Session**: An active learning interaction. Attributes: session ID, textbook, current chapter, current knowledge point, start time, duration, dialogue history, progress percentage. Relationship: Associated with one student and one textbook.

- **Progress Record**: Tracks student advancement. Attributes: textbook name, completed chapters list, current chapter/knowledge point, last session date, total study time, overall completion percentage. Relationship: One per student per textbook.

- **Note/Highlight**: Saved snippets from lessons. Attributes: note ID, marked text, source chapter, source knowledge point, timestamp, student comments (optional). Relationship: Many notes per textbook/student.

- **TODO State**: System-level task tracking for AI agent. Attributes: current teaching phase (outline generation/chapter prep/lesson active), pending tasks, last update timestamp. Relationship: Singleton per system instance, loaded with every AI invocation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Students can upload a textbook and receive a structured outline within 2 minutes for files up to 5MB
- **SC-002**: 90% of generated outlines correctly identify chapter boundaries and major sections (validated against manual review of sample textbooks)
- **SC-003**: AI teacher asks at least 2 guiding questions before providing hints or answers in 95% of interactions
- **SC-004**: Students successfully complete at least one chapter lesson session without system errors in 90% of attempts
- **SC-005**: Lesson progress is accurately saved and resumable within 10 seconds of re-opening a session
- **SC-006**: Students can view their learning progress and see completed vs. remaining chapters in under 5 seconds via status command
- **SC-007**: System responds to student messages within 3 seconds for local operations (outline display, status) and within 10 seconds for AI-powered dialogue responses
- **SC-008**: Error messages provide actionable guidance (clear instructions on how to fix) in 100% of common error scenarios (file not found, API failure, invalid format)
- **SC-009**: Students can mark and retrieve notes with 100% accuracy (all marked text is saved and displayed correctly)
- **SC-010**: System maintains educational integrity by redirecting direct answer requests to guiding questions in at least 85% of cases
- **SC-011**: Students report feeling "guided through discovery" rather than "being told answers" in qualitative feedback (target: 80% positive sentiment)
- **SC-012**: Knowledge point extraction covers core concepts from each chapter with 85%+ accuracy compared to expert-reviewed ground truth

## Assumptions

- **Textbook Format**: MVP assumes textbooks are reasonably well-structured with clear chapter headings (# Heading or == Heading == markup). Highly unstructured PDFs or scanned images are out of scope for MVP.
- **Internet Connection**: Required for AI API calls during lesson sessions. Offline mode for outline/progress viewing is supported, but active teaching requires connectivity.
- **Single User**: MVP supports single-user mode only. Multi-user functionality requires separate workspaces or future user profile feature.
- **AI API**: Assumes access to OpenAI GPT-4 API (or equivalent with similar capabilities). Future versions may support local LLMs.
- **Language**: MVP focuses on English-language textbooks. Internationalization (i18n) is deferred to future versions.
- **CLI Proficiency**: Target users are comfortable with basic command-line operations. A GUI is explicitly out of scope for MVP.
- **Study Discipline**: Assumes students are self-motivated learners. The system provides educational guidance but does not enforce study schedules or gamification (deferred to future versions).

