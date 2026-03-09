# /brain:handoff

Generate GSD-ready handoff document from brainstorming artifacts. Produces `.brainstorm/HANDOFF.md`.

---

## Setup

1. **Validate session exists:**
   - Read `.brainstorm/SESSION.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.
   - Read `.brainstorm/IDEA.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora un'idea. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

2. **Validate dimension count:**
   - Glob `.brainstorm/dimensions/*.md` and count the files found.
   - If fewer than 2 files found: tell the user "Servono almeno 2 dimensioni esplorate per il handoff. Usa `/brain:explore` per esplorarne altre." and STOP. Do not continue.

3. **Load all context:**
   - Read `.brainstorm/IDEA.md`
   - Read `.brainstorm/SESSION.md`
   - Read ALL dimension files found by Glob in `.brainstorm/dimensions/*.md`
   - Read `.brainstorm/SYNTHESIS.md` if it exists (for richer output). If SYNTHESIS.md does not exist, Read `.brainstorm/ANALYSIS.md` if it exists. If neither exists, proceed with dimensions alone.

---

## Generate

4. **Execute brain-synthesizer in handoff mode:**

   Execute brain-synthesizer behavior in handoff mode. Load all brainstorming artifacts and produce `.brainstorm/HANDOFF.md` — a structured, production-ready brief designed for `/gsd:new-project --auto` or human implementation start. Follow ALL instructions in the brain-synthesizer agent spec for handoff mode.

5. **Update SESSION.md:**
   - Read the current `.brainstorm/SESSION.md`
   - Add a new entry to the Session Notes section: `- Documento di handoff generato (YYYY-MM-DD)` using today's date
   - Update the Status field from its current value to `handoff-complete`
   - Write the updated SESSION.md

6. **Show result summary and suggest next command:**
   - Display the handoff mode output summary (section summaries, decisions needed count, coverage notes) as specified in the brain-synthesizer agent spec.
   - Then show the final message:
     ```
     HANDOFF.md e pronto! Puoi usarlo come input per `/gsd:new-project` per avviare la pianificazione.
     ```
   - Do NOT suggest any further `/brain:` commands. Handoff is the terminal step of the pipeline.
