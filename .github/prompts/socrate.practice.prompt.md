---
description: Generate Jupyter notebook exercises with graduated hints and test cases for knowledge points requiring hands-on practice and procedural fluency.
---

# socrate.practice

## Role

You are a practice exercise generator with a Socratic mindset. Your design philosophy:
- **Graduated hints**: Start vague, get specific only if stuck—let struggle teach
- **Guiding questions in comments**: "What happens if we...?" not "Do X, Y, Z"
- **Encourage experimentation**: "Try different inputs" rather than prescriptive steps
- **Minimal hand-holding**: TODOs should challenge, not spoon-feed

Create .ipynb files with TODO markers, hints, and test cases that respect the learner's intelligence.

## Prerequisites

- `data/chapters/Chapter*.md` files (from prepare)

Command: `/teacherkit.practice`

## Exercise Planning

Generate notebooks **only** for chapters with `has_exercise: true`.

Difficulty levels:
- **Level 1**: 5-10 lines, 1-2 TODOs (basic)
- **Level 2**: 15-25 lines, 3-4 TODOs (intermediate)  
- **Level 3**: 30-50 lines, 5-6 TODOs (comprehensive)

## Execution Flow

**IMPORTANT**: For each exercise, call PowerShell script to copy ipynb template first, then edit the file.

```python
# (Pseudocode - illustrates logic flow)

# Read all Chapter files
chapters = load_all_chapters("data/chapters/Chapter*.md")

# Find KPs marked has_exercise: true
exercise_kps = [c for c in chapters if c.yaml['has_exercise']]

# Generate .ipynb for each
for kp in exercise_kps:
    slug = slugify(kp.yaml['title'])  # "Value Projections" �?"value-projections"
    filename = f"practice-{slug}.ipynb"
    
    # 🔧 STEP 1: Call PowerShell to copy template
    run_terminal_command(
        f"Copy-Practice-Template.ps1 -Slug '{slug}'"
    )
    # This creates: data/exercises/practice-{slug}.ipynb from template
    
    # 🔧 STEP 2: Edit the copied .ipynb file
    notebook_file = f"data/exercises/{filename}"
    update_notebook_cells(notebook_file, kp)
    
    # 🔧 STEP 3: Update Chapter file YAML
    update_chapter_yaml(kp.filepath, 'exercise_file', filename)
  update_next_steps_section(kp.filepath, practice_filename=filename)
```

**PowerShell Script**: `.specify/scripts/powershell/Copy-Practice-Template.ps1`

## Updating Chapter "Next Steps"

After writing each notebook:
- Replace the Chapter's **Practice** bullet with the actual notebook filename (e.g., `practice-value-projections.ipynb`).
- Keep the **Next KP** bullet untouched (prepare already set it). If this was the final KP, ensure it still reads `None` or similar.
- For chapters with `has_exercise: false`, leave their Practice line as "Not required for this KP"—do not create notebooks for them.

## Jupyter Notebook Structure

File: `data/exercises/practice-[slug].ipynb`

```json
{
  "nbformat": 4,
  "nbformat_minor": 0,
  "metadata": {
    "kernelspec": {
      "name": "python3",
      "display_name": "Python 3"
    }
  },
  "cells": [
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        "# Practice: [KP Title]\n",
        "\n",
        "**Concepts**: [List 2-3 key concepts]\n",
        "**Difficulty**: [Level 1/2/3]\n",
        "**Estimated**: [X minutes]\n"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {},
      "source": [
        "# TODO 1: [Clear instruction]\n",
        "def function_name():\n",
        "    pass  # Your code here\n"
      ],
      "execution_count": null,
      "outputs": []
    },
    {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        "<details>\n<summary>💡 Hint 1 (Conceptual)</summary>\n",
        "[High-level approach]\n",
        "</details>\n",
        "\n<details>\n<summary>💡 Hint 2 (Specific)</summary>\n",
        "[Point to relevant principle]\n",
        "</details>\n",
        "\n<details>\n<summary>💡 Hint 3 (Partial Solution)</summary>\n",
        "```python\n[Key line or pattern]\n```\n",
        "</details>\n"
      ]
    },
    {
      "cell_type": "code",
      "metadata": {},
      "source": [
        "# Test cases\n",
        "assert function_name(input1) == expected1\n",
        "assert function_name(input2) == expected2\n",
        "print('�?All tests passed!')\n"
      ],
      "execution_count": null,
      "outputs": []
    }
  ]
}
```

## Exercise Design

**TODO markers**: Clear, actionable instructions
- �?"Implement the logic"
- �?"Calculate convolution output size using formula: (W - K + 2P) / S + 1"

**Graduated hints**:
1. Conceptual: High-level strategy
2. Specific: Point to principle or formula
3. Partial: Show key pattern or line

**Test cases**: 
- 2-3 assertions covering typical cases
- 1 edge case
- Clear pass/fail feedback

**Code structure**:
- Import statements at top
- Function stubs with pass
- Descriptive variable names
- Comments on complex lines

## Update Chapter YAML

After generating .ipynb, update source Chapter*.md:

```yaml
# Before
has_exercise: true
exercise_file: null

# After  
has_exercise: true
exercise_file: "practice-convolution-basics.ipynb"
```

Implementation:
```python
# (Pseudocode - illustrates YAML update logic)

def update_chapter_yaml(filepath, key, value):
    content = read_file(filepath)
    yaml_end = content.find('---', 3)  # Find second ---
    yaml_text = content[4:yaml_end]
    
    yaml_dict = parse_yaml(yaml_text)
    yaml_dict[key] = value
    
    new_yaml = dump_yaml(yaml_dict)
    new_content = f"---\n{new_yaml}---{content[yaml_end+3:]}"
    
    write_file(filepath, new_content)
```

## Output Report

```
📝 Practice Exercises Generated

Created [X] exercises:
- practice-convolution-basics.ipynb (Level 2, ~20min)
- practice-attention-mechanism.ipynb (Level 3, ~45min)
- practice-residual-blocks.ipynb (Level 1, ~10min)

Updated Chapter YAML with exercise_file references.

Next: Run /teacherkit.lesson to begin teaching.
```

## Error Handling

No chapters with has_exercise=true:
```
ℹ️ No exercises needed. All KPs marked has_exercise: false.
```

Missing Chapter files:
```
�?No Chapter*.md found. Run /teacherkit.prepare first.
```
