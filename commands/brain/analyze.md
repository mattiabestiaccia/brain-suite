# /brain:analyze

Generate cross-dimensional analysis from explored dimensions. Produces `.brainstorm/ANALYSIS.md`.

---

## Setup

1. **Validate session exists:**
   - Read `.brainstorm/SESSION.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.
   - Read `.brainstorm/IDEA.md` -- REQUIRED.
     If it does not exist, tell the user: "Non c'e ancora un'idea. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

2. **Validate dimension count:**
   - Glob `.brainstorm/dimensions/*.md` and count the files found.
   - If fewer than 2 files found: tell the user "Servono almeno 2 dimensioni esplorate per l'analisi. Usa `/brain:explore` per esplorarne altre." and STOP. Do not continue.

3. **Load all context:**
   - Read `.brainstorm/IDEA.md`
   - Read `.brainstorm/SESSION.md`
   - Read ALL dimension files found by Glob in `.brainstorm/dimensions/*.md`

---

## Generate

4. **Execute brain-synthesizer in analyze mode:**

   Execute brain-synthesizer behavior in analyze mode. Load all brainstorming artifacts and produce `.brainstorm/ANALYSIS.md` — a cross-dimensional analysis document with emergent themes and gap analysis. Follow ALL instructions in the brain-synthesizer agent spec for analyze mode.

5. **Update SESSION.md:**
   - Read the current `.brainstorm/SESSION.md`
   - Add a new entry to the Session Notes section: `- Analisi cross-dimensionale generata (YYYY-MM-DD)` using today's date
   - Write the updated SESSION.md

6. **Show result summary and suggest next command:**
   - Display the analyze mode output summary (themes identified, gap analysis highlights, confidence rating) as specified in the brain-synthesizer agent spec.
   - Then suggest the next step:
     ```
     Ora puoi lanciare `/brain:synthesize` per generare la sintesi narrativa.
     ```
