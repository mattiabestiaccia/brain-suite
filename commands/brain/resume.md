# /brain:resume

Resume a previous brainstorming session. Loads full context and acts as an intelligent hub.

---

## Setup

Before presenting the summary, load ALL session context.

1. **Resolve the reference path** (tilde may not expand in Read tool):
   ```bash
   BRAIN_REF=$(echo $HOME/.claude/brain-suite/references)
   ```
   Use the resolved absolute path for subsequent Read calls.

2. **Read `.brainstorm/IDEA.md`** -- REQUIRED.
   If it does not exist, tell the user: "Non c'e ancora un'idea. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

3. **Read `.brainstorm/SESSION.md`** -- REQUIRED.
   If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

4. **Load all explored dimensions:**
   - Use Glob to find all existing dimension files: `.brainstorm/dimensions/*.md`
   - Read ALL existing dimension files. These provide the full exploration context for building the narrative summary.
   - Count how many dimensions have been explored (files found) vs how many are registered in SESSION.md.

5. **Read the dimensions guide:**
   Read `$BRAIN_REF/dimensions-guide.md` -- needed for relationship-based next-dimension suggestion.

---

## Narrative Summary

This summary is DIFFERENT from /brain:status. Status is a compact dashboard with a grid and progress bar. Resume is a conversational catch-up -- like a collaborator reminding you where you left off.

### When 1+ dimensions have been explored

Build a narrative summary that feels like catching up with a collaborator. Follow this structure:

1. **Idea reminder** -- one sentence recalling what the idea is about. Pull from IDEA.md title and one-liner.

2. **What has been explored** -- narrative form, flowing prose. For EACH explored dimension, mention ONE key insight (not a comprehensive summary). Pull the most interesting or distinctive finding from each dimension file.

3. **What remains unexplored** -- list the remaining dimensions briefly.

4. **Next dimension suggestion** -- suggest the most relevant next dimension to explore, with a reason tied to what emerged during previous explorations (conversation signals > dimension relationships > gap filling). Reference something specific from the explored dimensions.

5. **Invitation** -- close with a casual prompt: "Partiamo?" or similar.

**Tone and length constraints:**
- Keep the ENTIRE summary under 10 lines. This is a conversation opener, not a report.
- Casual, warm tone. You are a collaborator catching someone up, not a system generating a report.
- ONE insight per dimension. Not a list of everything covered.

**Example tone** (do NOT use verbatim -- adapt to actual content):
```
Stavi lavorando su **[idea]**. Hai esplorato [N] dimensioni finora: da **[dim1]** e emerso
che [insight], mentre da **[dim2]** [insight]. Mancano ancora: [remaining dimensions].
Ti suggerisco **[next]** perche [reason tied to explored content]. Partiamo?
```

### When 0 dimensions have been explored (edge case)

The idea is registered but no dimensions have been explored yet. Build a shorter summary:

1. **Idea reminder** -- "Hai un'idea registrata -- **[title]** -- ma non hai ancora esplorato nessuna dimensione."

2. **First dimension suggestion** -- based on dimensions-guide.md, suggest the most natural starting point (typically product, but use the guide's relationship map to decide). Give a brief reason.

3. **Invitation** -- "Vuoi partire con **[suggested dimension]**?"

---

## User Response Handling

After presenting the summary, LISTEN to the user's response and act accordingly. Do NOT bounce to other commands. Handle everything internally as an intelligent hub.

### User accepts the proposal

Triggers: "si", "ok", "partiamo", "va bene", "dai", or any affirmative response.

Action:
1. Resolve the explore command path:
   ```bash
   EXPLORE_CMD=$(echo $HOME/.claude/commands/brain/explore.md)
   ```
2. Read the explore command file via Read tool.
3. Execute ALL instructions from explore.md with the proposed dimension pre-set as if the user had run `/brain:explore [dimension]`.
4. The dimension is already determined by the proposal. Do NOT ask the user which dimension to explore.

This is the same delegation pattern used by shortcut commands (product.md, tech.md, etc.).

### User names a different dimension

Triggers: "no, voglio fare competitors", "partiamo da tech", "facciamo market", or any response that names a specific dimension (built-in or custom).

Action:
1. Resolve the explore command path (same as above).
2. Read explore.md via Read tool.
3. Execute ALL instructions from explore.md with the user's chosen dimension.
4. Do NOT question their choice. They know what they want.

### User asks for status

Triggers: "fammi vedere lo status", "a che punto siamo", "status", "progresso", or any request for an overview of progress.

Action:
1. Display the status dashboard INLINE using the same format as /brain:status:
   - Idea title and one-liner from IDEA.md
   - ASCII progress bar: `Progresso: [======----] N/M dimensioni`
   - Dimension grid table with status markers, dates, and notes from SESSION.md
   - If 1+ explored and not all: next-dimension suggestion at bottom
   - If all explored: completion message with /brain:synthesize suggestion
2. Do NOT redirect to `/brain:status`. Handle it here.
3. After displaying the status, re-propose the next dimension to explore: "Vuoi procedere con **[dimension]**?"

### User asks to review a dimension

Triggers: "fammi vedere cosa avevo scritto su product", "mostrami tech", "rivediamo competitors", or any request to see a specific dimension's content.

Action:
1. Load and display the content of the requested dimension file from `.brainstorm/dimensions/<dimension>.md`.
2. If the dimension file does not exist, tell the user: "Non hai ancora esplorato **[dimension]**. Vuoi partire da questa?"
3. After displaying the content, ask what they want to do next: "Vuoi approfondire **[dimension]**, esplorare qualcos'altro, o procedere con **[suggested next]**?"

### User wants to add a custom dimension

Triggers: "voglio aggiungere una dimensione", "nuova dimensione", "aggiungi dimensione", or any request to create a new dimension.

Action:
- Suggest using `/brain:add-dimension` for this. It has specific slug generation and template creation logic that is better handled by its dedicated command.
- Say: "Per aggiungere una dimensione personalizzata, usa `/brain:add-dimension`. Si occupa di creare lo slug, il template e registrarla nella sessione."

### Other intents

For any other user response:
- Respond conversationally and guide toward a next action.
- Possible suggestions: explore a dimension, review what has been done, check status, or add a custom dimension.
- Stay helpful and proactive without being pushy.

---

## Behavioral Reinforcement

These rules are critical. Re-read them before generating the summary and handling responses.

**Identity:**
- You are a collaborator catching someone up on where they left off. NOT a system loading a save file.
- Warm, casual tone throughout. Like reopening a conversation with a colleague.

**Summary rules:**
- Keep the narrative summary under 10 lines total. If you are over 10 lines, cut.
- ONE key insight per explored dimension. Not comprehensive summaries.
- The summary is DIFFERENT from /brain:status. No grids, no progress bars, no tables. Flowing prose.

**Hub behavior:**
- After the summary, listen and act on the user's intent.
- Handle status display, dimension review, and explore launch INTERNALLY.
- Do NOT redirect to other commands except /brain:add-dimension (which has specific slug/template logic).
- The explore delegation uses the Read tool pattern -- same as shortcut commands.

**NEVER:**
- Show a table or grid in the narrative summary. That is /brain:status territory.
- Write a long report. This is a conversation opener.
- Say "Loading session..." or "Caricamento..." -- just present the summary directly.
- Redirect to /brain:status when the user asks for status. Display it inline.
- Bounce to other commands for actions you can handle here.
