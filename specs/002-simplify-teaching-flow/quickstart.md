# Quick Start Guide: Simplified Teaching Flow

**Version**: 2.0.0  
**Last Updated**: 2025-10-22  
**Target User**: Students using AI chat tools (Copilot, Cursor, Claude Code)

---

## What's New in Version 2.0?

🚀 **Major Simplification**:
- **No more CLI commands** for teaching (only `teacherkit init` for setup)
- **No more file uploads** to directories
- **No more multi-step workflow** (parse → prepare → lesson)

✨ **One Command to Start**:
- Attach a file **OR** describe a topic → Type `/teacherkit.start` → Begin learning!

🎯 **New Feature: Practice Exercises**:
- Get hands-on coding practice with fill-in-the-blank exercises
- AI reviews your code using Socratic method (guides, doesn't give answers)

---

## Prerequisites

✅ **One of these AI platforms**:
- GitHub Copilot in VS Code
- Cursor
- Claude Code (or similar with file attachment support)

✅ **Optional: TeacherKit CLI** (for project initialization only):
- Python 3.11+
- uv package manager

---

## Two Ways to Get Started

### Option 1: Quick Start (No Installation)

**If you already have Copilot/Cursor/Claude:**

Just start chatting! No installation needed.

```
[In AI chat]
Attach a textbook file (or describe what you want to learn)
Type: /teacherkit.start
```

That's it! 🎉

---

### Option 2: Full Setup (With Project Structure)

**If you want organized learning materials:**

1. **Install TeacherKit CLI** (optional):
   ```powershell
   uv tool install teacherkit --from git+https://github.com/<org>/teacherkit
   ```

2. **Initialize a learning project**:
   ```powershell
   teacherkit init my-learning
   cd my-learning
   ```

3. **Start learning** (same as Option 1):
   ```
   [In AI chat]
   /teacherkit.start "Python for beginners"
   ```

---

## Your First Learning Session

### Scenario 1: I Have a Textbook File

**Step 1**: Attach your file to the AI chat
- Drag-drop the file into chat window
- Or use `@file` command (Copilot) / equivalent in other platforms

**Supported formats**: Markdown (.md), Text (.txt), PDF (text extraction)

**Step 2**: Start learning
```
/teacherkit.start
```

**Step 3**: Confirm the learning plan
```
AI shows: "Here's what we'll cover... Ready to start? (A/B/C/D)"
You type: A
```

**Step 4**: Engage in Socratic dialogue
```
AI asks: "What do you think happens when...?"
You respond with your thinking
AI guides you to discover the answer
```

**Example**:
```
You: [attach python-basics.md]
     /teacherkit.start

AI:  📘 I've read your textbook!
     
     Title: Python Basics
     Chapters: 5
     Estimated Time: 6 hours
     
     Learning Plan:
     1. Variables and Types
        - KP-1.1: What is a variable?
        - KP-1.2: Numbers vs. Text
     2. Control Flow
        ...
     
     Does this look good? (A/B/C/D)

You: A

AI:  ✨ Let's Begin!
     
     📍 KP-1.1: What is a variable?
     
     💭 "Think of a variable like a labeled box. 
         What would you put in a box labeled 'age'?"

You: A number representing someone's age?

AI:  "Exactly! And if the box is labeled 'name', what might go there?"
     ...
```

---

### Scenario 2: I Don't Have a File, Just a Topic

**Step 1**: Describe what you want to learn
```
/teacherkit.start "Python loops for beginners"
```

**Step 2**: Answer clarifying questions (if needed)
```
AI: "A few quick questions:
     1. Are you a complete beginner? (A) Yes (B) No
     2. Goal: (A) Understand concepts (B) Build things (C) Both"

You: A, C
```

**Step 3**: Confirm the generated plan
```
AI: "Here's your customized plan... (A/B/C/D)"
You: A
```

**Step 4**: Start learning!

**Example**:
```
You: /teacherkit.start "machine learning basics"

AI:  🤔 That's a broad topic! Let me narrow it down.
     
     Questions:
     1. Experience level? (A) Beginner (B) Some background
     2. Math comfort? (A) Rusty (B) Comfortable with algebra
     3. Focus? (A) Theory (B) Hands-on (C) Both

You: A, A, C

AI:  Perfect! 📘 Here's your plan:
     
     Title: ML Fundamentals (Beginner-Friendly)
     Difficulty: Beginner
     Time: 5 hours
     
     What We'll Cover:
     1. What is Machine Learning?
        - KP-1.1: AI vs. ML
        - KP-1.2: Types of Learning
     2. Simple Algorithms
        ...
     
     Ready? (A/B/C/D)

You: A

AI:  ✨ Let's go!
     
     💭 "Have you ever noticed how Netflix recommends shows?
         What do you think it's doing behind the scenes?"
```

---

## Getting Hands-On Practice (Programming Topics)

### When Does Practice Happen?

After you've learned 2-3 related concepts, the AI offers practice:

```
AI: "You've learned about loops! Ready to try coding this yourself?"
You: "yes"
```

### What You Get

A **code exercise file** with:
- Clear function structure
- `### START CODE HERE ###` markers showing where to write code
- Hints in comments
- Test cases to verify your work

**Example**:

```python
# practice-loops-01.py
"""
Practice Exercise: For Loops

Complete the TODO to make the tests pass.
"""

def count_to_n(n):
    """
    Print numbers from 1 to n
    
    Args:
        n: The number to count to
    
    Example:
        >>> count_to_n(5)
        1
        2
        3
        4
        5
    """
    
    ### START CODE HERE ### (≈ 2 lines of code)
    # Hint: Use a for loop with range()
    
    ### END CODE HERE ###


# Test Cases
if __name__ == "__main__":
    print("Testing count_to_n(5):")
    count_to_n(5)
    # Expected output: 1, 2, 3, 4, 5
```

### How to Submit

**Option 1**: Paste your code in chat
```
You: Here's my solution:
     [paste code]
```

**Option 2**: Attach the file
```
You: [attach practice-loops-01.py]
     Done! Check my code?
```

### AI Reviews Your Code (Socratically!)

**AI won't just tell you if it's right or wrong**. It asks questions:

```
You: [submit code with a bug]

AI:  I see your code! Before I comment, can you walk me through:
     - What's happening on line 5?
     - What value does 'i' have on the last iteration?

You: [explain your thinking]

AI:  Interesting! So if i goes from 0 to 4, but n is 5...
     What's missing? 🤔

You: Oh! It doesn't print 5!

AI:  Exactly! How can you fix the range to include 5?
     ...
```

---

## During a Learning Session

### Special Commands

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `hint` | Get a clue (graduated hints) | Stuck on a question or exercise |
| `example` | See a real-world scenario | Need concrete context |
| `skip` | Move to next question | Really stuck (not recommended) |
| `pause` | Save progress and exit | Need a break |
| `too easy` / `too hard` | Adjust difficulty | Exercise doesn't match your level |

**Example**:
```
You: hint

AI:  💡 Hint 1: Think about what happens when the loop starts.
     What's the first value of i?

You: hint

AI:  💡 Hint 2: range(n) gives you 0 to n-1.
     To get 1 to n, what should the parameters be?

You: hint

AI:  💡 Hint 3: Try range(1, n+1)
     The first number is start, second is stop (exclusive)
```

---

## Pausing & Resuming

### To Pause

Just close the chat! Your progress is saved in the conversation history.

Or type:
```
pause
```

### To Resume

Reopen the same chat conversation. The AI detects you're returning:

```
You: Hi

AI:  👋 Welcome back!
     
     Last time we were on:
     - Topic: Python Loops
     - Progress: 3/8 knowledge points
     - Last KP: KP-2.1 - While Loops
     
     Would you like to:
     A) Continue from where we left off
     B) Quick recap (5 min review)
     C) Start a new topic
     
     Your choice:

You: B

AI:  📝 Quick Recap:
     
     What You've Learned:
     - For loops: Use when you know # of iterations
     - Range function: Generates sequences
     - Loop variables: Change each iteration
     
     Last Question: "How is a while loop different from a for loop?"
     
     Ready to continue?

You: yes
```

---

## Checking Your Progress

At any time, ask:

```
You: "What have we covered so far?"
```

Or:

```
You: "How much progress have I made?"
```

AI responds:

```
📊 Progress Summary

Topic: Python Programming
Time Spent: ~2 hours
Progress: 40% (8/20 knowledge points)

✓ Completed:
  - Variables and Types (3 KPs)
  - Basic Operators (2 KPs)
  - For Loops (3 KPs)

~ In Progress:
  - While Loops (KP-2.1 active)

⏳ Upcoming:
  - Functions
  - Lists
  - Dictionaries
```

---

## Tips for Effective Learning

### 1. **Don't Skip the Questions**

Even if you think you know, explaining it to the AI helps solidify understanding.

```
❌ "I know this, can we skip?"
✅ "Let me explain: I think it works like..."
```

### 2. **Use Your Own Words**

The AI wants to hear YOUR thinking, not textbook definitions.

```
❌ "A variable is a memory location identifier"
✅ "It's like a label on a box where you store stuff"
```

### 3. **Try the Practice First**

Before asking for hints, give it a real attempt. Mistakes are learning opportunities!

```
Better: Write code → Run it → See error → Think → THEN ask hint
```

### 4. **Ask "Why?"**

The AI loves when you dig deeper:

```
You: "Why do we use loops instead of writing the same line 10 times?"
AI: "Great question! Let's explore..."
```

---

## Troubleshooting

### Problem: "I don't see /teacherkit.start command"

**Solution**: 
- Make sure you're using GitHub Copilot, Cursor, or Claude Code
- In VS Code with Copilot: Just type it in the chat (no special installation)
- If still not working: The prompts might not be installed. See "Full Setup" above.

---

### Problem: "AI isn't reading my attached file"

**Solution**:
- Check file format (MD, TXT, PDF supported)
- Try smaller file (< 10MB works best)
- PDF might have issues: Convert to plain text if possible
- Make sure file is attached BEFORE typing /teacherkit.start

---

### Problem: "The learning plan doesn't match my file"

**Solution**:
After AI shows the plan, choose option B (Adjust focus):

```
AI: Does this look good? (A/B/C/D)
You: B

AI: What would you like to adjust?
You: Focus only on Chapter 3, skip the intro stuff
```

---

### Problem: "Practice exercises are too hard"

**Solution**:
Just say so!

```
You: too hard

AI: Let me create an easier version...
     [Generates simpler exercise with more hints]
```

---

### Problem: "I lost my progress (closed conversation)"

**Solution**:
- **If conversation still exists**: Reopen it, AI remembers
- **If conversation deleted**: Start fresh (ephemeral storage limitation)
- **Future**: Export/import commands coming in v0.3

---

## What's Next?

### After Your First Session:

1. ✅ **Try a different topic**: `/teacherkit.start "JavaScript basics"`
2. ✅ **Explore practice exercises**: Focus on programming topics
3. ✅ **Experiment with difficulty**: Request "beginner-friendly" or "advanced"

### Advanced Features (Coming Soon):

- 📊 Export progress reports
- 🔄 Resume across sessions (persistent storage)
- 🌐 Multi-language practice (JavaScript, Java, C++)
- 👥 Group learning (multiple students)

---

## Getting Help

### In-Chat Help

```
You: "help"
AI: [Shows available commands and usage tips]
```

### Documentation

- **Feature Spec**: `specs/002-simplify-teaching-flow/spec.md`
- **Implementation Plan**: `specs/002-simplify-teaching-flow/plan.md`
- **Contracts**: `specs/002-simplify-teaching-flow/contracts/`

### Common Questions

**Q: Do I need to install anything?**  
A: Only if you want project structure (`teacherkit init`). Otherwise, just use your AI chat!

**Q: Can I use this without internet?**  
A: No, requires AI platform connection.

**Q: What languages can I practice?**  
A: MVP supports Python only. JavaScript/Java coming in future versions.

**Q: How long are typical sessions?**  
A: 30min-2hrs. AI suggests breaks every ~1 hour.

**Q: Can I save my progress permanently?**  
A: Currently saved in conversation history. Persistent export coming in v0.3.

---

## Happy Learning! 🎓

**Remember**: Learning is a conversation, not a lecture. The AI is here to guide you to discovery, not just give you answers. Be curious, ask questions, and enjoy the journey!

**Questions or feedback?** Just ask in the chat! The AI adapts to your learning style.

---

**Version Notes**:
- v2.0.0: Complete redesign - prompt-first architecture, practice exercises
- v1.0.0: CLI-driven workflow (deprecated)
