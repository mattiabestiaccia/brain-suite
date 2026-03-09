# /brain:status

Show brainstorming session progress dashboard. A compact, scannable compass for your idea exploration.

---

## Setup

1. **Resolve the reference path** (tilde may not expand in Read tool):
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   ```
   Use the resolved absolute path for subsequent Read calls.

2. **Read `.brainstorm/SESSION.md`** -- REQUIRED.
   If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

3. **Read `.brainstorm/IDEA.md`** -- REQUIRED.
   Extract the first heading (idea title) and the first blockquote (one-liner description).

---

## Parse Session Data

From SESSION.md, extract:

1. **Dimension table:** Parse the "Explored Dimensions" table. For each row, extract: dimension name, status, date, notes.
2. **Counts:** Count total dimensions (including any custom rows) and how many have status "explored" (or any status other than "not started").
3. **Custom dimensions:** Rows with "custom" in the notes column or a 5th column marker are custom dimensions. Track them separately for display ordering.

---

## Display the Dashboard

Format and display the dashboard using this structure. Output everything in a single response.

### Header

```
# [Idea Title]
> [One-liner from IDEA.md]
```

### Progress Bar

```
Progresso: [======----] N/M dimensioni
```

- `=` characters proportional to explored/total (use 10-character bar width).
- N = explored count, M = total count.
- If 0 explored: `[----------] 0/M dimensioni`
- If all explored: `[==========] M/M dimensioni`

### Dimension Grid

Display as a table:

```
| Dimensione | Status | Data | Note |
|------------|--------|------|------|
| product | [marker] | YYYY-MM-DD | brief note |
| tech | [marker] | - | - |
| ... | ... | ... | ... |
```

**Status markers:**
- Explored: use a checkmark (e.g., a tick mark or similar terminal-safe indicator)
- Not started: use an empty circle or dash indicator

**Ordering:**
- Built-in dimensions first (product, tech, market, business, competitors, users) in their standard order
- Custom dimensions after the built-ins, with "(custom)" appended to the dimension name

**Notes column:** Display the brief note from SESSION.md as-is. Show "-" if no note.

---

## Next-Dimension Suggestion

This section is CONDITIONAL based on how many dimensions have been explored.

### Case 1: Zero dimensions explored (all "not started")

Do NOT show any next-dimension suggestion. The grid alone is the output. The suggestion already came from `/brain:new`.

### Case 2: One or more dimensions explored (but not all)

1. Read the dimensions guide:
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   ```
   Read `$BRAIN_REF/dimensions-guide.md` via Read tool.

2. From the dimensions guide, identify relationships between dimensions (which dimensions inform or build upon others).

3. Check which dimensions are still "not started" in SESSION.md.

4. Among the unexplored dimensions, pick the most relevant one based on:
   - What dimensions have already been explored (leverage relationships/dependencies)
   - Any notes or connections flagged in the explored dimensions
   - The natural flow suggested by the dimensions guide

5. Display the suggestion conversationally at the bottom:
   ```
   Prossima: **[dimension]** -- [reason based on what was explored and noted connections].
   ```
   The reason must reference what was already explored, not be generic.

### Case 3: All dimensions explored

Show a completion message:
```
Tutte le dimensioni sono state esplorate! Puoi lanciare `/brain:analyze` per generare l'analisi cross-dimensionale.
```

---

## Important Constraints

- Status is a **compact compass**, NOT a report. Do not load or display full dimension content.
- Only display what is available in SESSION.md (status, date, notes) plus the title from IDEA.md.
- **No artifacts** produced by this command. Display only.
- Do not modify any files. This is a read-only command.
- Follow the same runtime reference loading pattern as other commands (Bash echo $HOME, then Read).
