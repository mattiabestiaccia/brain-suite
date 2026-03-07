# /brain:add-dimension

Add a custom dimension to explore beyond the 6 built-ins. Custom dimensions let you explore angles not covered by the standard dimensions.

---

## Setup

1. **Read `.brainstorm/SESSION.md`** -- REQUIRED.
   If it does not exist, tell the user: "Non c'e ancora una sessione. Lancia `/brain:new` per iniziare." and STOP. Do not continue.

---

## Collect Dimension Info

### Step 1: Get Dimension Name

Check `$ARGUMENTS` for a dimension name.

- **If `$ARGUMENTS` is not empty:** Use the first argument as the dimension name. If there are additional words, treat the entire argument string as the name.
- **If `$ARGUMENTS` is empty:** Ask the user: "Come vuoi chiamare questa dimensione?" Wait for their response.

### Step 2: Get Description

Ask the user for a brief description (1-2 sentences) of what they want to explore in this dimension:
"Descrivi brevemente cosa vuoi esplorare in questa dimensione (1-2 frasi)."

Wait for their response.

---

## Generate Slug

Generate a filesystem-safe slug from the dimension name:

```bash
SLUG=$(echo "$DIMENSION_NAME" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null || echo "$DIMENSION_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
```

If `iconv` succeeds, also apply the normalization pipeline:
```bash
SLUG=$(echo "$DIMENSION_NAME" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
```

The slug must be:
- All lowercase
- Spaces replaced with hyphens
- Special characters removed (only a-z, 0-9, hyphens)
- No leading/trailing hyphens
- No consecutive hyphens

---

## Check for Duplicates

Search the Explored Dimensions table in SESSION.md for the generated slug.

- If a row with this slug already exists: tell the user "La dimensione **[name]** esiste gia nella sessione." and STOP.
- If not found: proceed.

---

## Create Freeform Template

Create the template file at `.brainstorm/templates/<slug>.md`.

1. Ensure the directory exists:
   ```bash
   mkdir -p .brainstorm/templates
   ```

2. Write the template file using the Write tool:

   ```markdown
   # [Dimension Name]
   > Template for .brainstorm/dimensions/[slug].md
   > Explorer uses these sections as conversation anchors during exploration.

   ## Overview
   [User's description]. What are the key aspects to explore?

   ## Key Considerations
   What factors are most important? What constraints or opportunities exist?

   ## Connections to Other Dimensions
   How does this dimension relate to and influence the other dimensions of the idea?

   ## Open Questions
   What needs further investigation or validation?
   ```

Replace `[Dimension Name]` with the actual name, `[slug]` with the generated slug, and `[User's description]` with the description provided by the user.

**Important:** The template goes in `.brainstorm/templates/` (the project-local directory), NOT in the installed reference templates directory. Custom templates live alongside the brainstorming session, not in the Brain Suite installation.

---

## Register in SESSION.md

1. Read the current `.brainstorm/SESSION.md`.

2. Find the Explored Dimensions table (the markdown table after the `## Explored Dimensions` heading).

3. Append a new row at the end of the table:
   ```
   | [slug] | not started | - | - | custom |
   ```

4. Update the "Last updated" date in the header to today's date.

5. Write the updated SESSION.md using the Write tool.

---

## Confirmation

Confirm to the user:

```
Dimensione **[name]** aggiunta. Puoi esplorarla con `/brain:explore [slug]`.
```

---

## Important Constraints

- Custom dimensions do **NOT** get shortcut commands. Shortcuts are reserved for the 6 built-in dimensions. The user explores custom dimensions via `/brain:explore [slug]`.
- Custom templates are **freeform** -- few generic headings, not the rigid 5-6 section structure of built-in templates. Custom dimensions exist because the user wants to go off-script.
- Multiple words are allowed in the dimension name, in any language. The slug handles normalization.
- Template is created in `.brainstorm/templates/` (project-local), not in `~/.claude/brain-suite/templates/` (installation directory).
- This command does NOT launch exploration. It only creates the template and registers the dimension. The user must run `/brain:explore [slug]` separately.
- Follow the same patterns established in Phase 2-3 commands for consistency.
