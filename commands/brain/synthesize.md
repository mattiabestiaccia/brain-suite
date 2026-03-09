# /brain:synthesize

Generate narrative synthesis from cross-dimensional analysis. Produces `.brainstorm/SYNTHESIS.md`.

---

## Setup

1. **Validate session exists:**
   - Read `.brainstorm/SESSION.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.
   - Read `.brainstorm/IDEA.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora un'idea. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

2. **Validate ANALYSIS.md exists:**
   - Check if `.brainstorm/ANALYSIS.md` exists.
   - If it does not exist, tell the user: "Lancia prima `/brain:analyze` per generare l'analisi cross-dimensionale." and STOP. Do not continue.

3. **Load all context:**
   - Read `.brainstorm/IDEA.md`
   - Read `.brainstorm/SESSION.md`
   - Read ALL dimension files found by Glob in `.brainstorm/dimensions/*.md`
   - Read `.brainstorm/ANALYSIS.md`

---

## Generate

4. **Execute brain-synthesizer in synthesize mode:**

   Execute brain-synthesizer behavior in synthesize mode. Load all brainstorming artifacts (including ANALYSIS.md) and produce `.brainstorm/SYNTHESIS.md` — a cohesive narrative document that tells the story of the idea. Follow ALL instructions in the brain-synthesizer agent spec for synthesize mode.

5. **Update SESSION.md:**
   - Read the current `.brainstorm/SESSION.md`
   - Add a new entry to the Session Notes section: `- Sintesi narrativa generata (YYYY-MM-DD)` using today's date
   - Write the updated SESSION.md

6. **Show result summary and suggest next command:**
   - Display the synthesize mode output summary (word count, narrative arc summary, gaps noted) as specified in the brain-synthesizer agent spec.
   - Then suggest the next step:
     ```
     Ora puoi lanciare `/brain:handoff` per generare il documento di handoff per GSD.
     ```
