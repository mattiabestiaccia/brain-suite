# Piano: Suite Brainstorming `brain:`

## Context

Framework completo per brainstorming strutturato su idee di prodotto, anche embrionali. La suite permette esplorazione interattiva (Socratica, sfidante, creativa) su molteplici dimensioni, salva artefatti su disco per ripresa tra sessioni, e produce un handoff consumabile da `/gsd:new-project` per passare all'implementazione.

**Flusso complessivo:** `brain:` (esplora, ragiona, valida) → `gsd:` (pianifica, implementa, verifica)

**Modello d'uso:** L'utente apre una cartella di progetto (anche vuota), lancia i comandi `brain:`, e una sottocartella `.brainstorm/` viene creata con tutti gli artefatti. Tool a sé stante, non dipendente da GSD per funzionare.

---

## Repository e distribuzione

### Monorepo: `~/Projects/brain-suite/` (GitHub)

Tutto vive in un unico repository. L'utente clona, lancia `install.sh`, ed è operativo.

```
brain-suite/                         # ← repo GitHub
├── config/                          # Config Claude Code (symlinkata in ~/.claude/)
│   ├── commands/brain/              # → ~/.claude/commands/brain/
│   │   ├── new.md
│   │   ├── explore.md
│   │   ├── product.md ... users.md
│   │   ├── synthesize.md
│   │   ├── status.md, resume.md, handoff.md, add-dimension.md
│   │   ├── transcribe.md           # bridge v1.5
│   │   └── distill.md              # bridge v1.5
│   ├── agents/                      # → brain-*.md symlinked in ~/.claude/agents/
│   │   ├── brain-explorer.md
│   │   ├── brain-researcher.md
│   │   └── brain-synthesizer.md
│   └── brainstorm/                  # → ~/.claude/brainstorm/
│       ├── workflows/
│       ├── templates/
│       └── references/
├── tools/                           # Python CLI toolkit (v1.5+)
│   ├── pyproject.toml
│   ├── uv.lock
│   └── src/brain_tools/
│       ├── __init__.py
│       ├── cli.py
│       ├── transcribe.py
│       ├── trim.py
│       ├── diarize.py
│       ├── distill.py
│       └── mcp_server.py           # v2: entrypoint MCP
├── install.sh                       # Crea symlink + uv sync
├── uninstall.sh                     # Rimuove symlink
├── README.md
├── LICENSE
└── .gitignore
```

### Meccanismo di installazione: symlink

`install.sh` crea symlink da `~/.claude/` ai file nel repo:

```bash
# install.sh (schema)
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Commands
ln -sfn "$REPO_DIR/config/commands/brain" "$HOME/.claude/commands/brain"

# Agents (singoli file, non directory — ~/.claude/agents/ contiene anche altri agenti)
for f in "$REPO_DIR"/config/agents/brain-*.md; do
  ln -sf "$f" "$HOME/.claude/agents/$(basename "$f")"
done

# Brainstorm framework
ln -sfn "$REPO_DIR/config/brainstorm" "$HOME/.claude/brainstorm"

# Tools (v1.5+)
if [ -f "$REPO_DIR/tools/pyproject.toml" ]; then
  cd "$REPO_DIR/tools" && uv sync
fi
```

I file restano nel repo (git-tracked). Le modifiche si riflettono immediatamente in Claude Code.

`uninstall.sh` rimuove i symlink senza toccare il repo.

### Vantaggi

- **Un `git clone` + `./install.sh`** per avere tutto
- **`git pull` + `./install.sh`** per aggiornare (symlink, nessuna copia)
- Il repo è condivisibile su GitHub
- `~/.claude/` non contiene file diretti — solo symlink al repo
- Il toolkit Python vive nello stesso repo ma come sottoprogetto `uv` indipendente

---

## Architettura a due livelli

### Livello 1: Sessione interattiva (config Claude Code)

La sessione Claude Code è il **direttore d'orchestra**: gestisce la conversazione, prende decisioni, guida il brainstorming. Non esegue mai operazioni pesanti direttamente.

Sorgente: `brain-suite/config/` → symlinkata in `~/.claude/`

### Livello 2: Processing pipeline (software Python)

Operazioni pesanti (trascrizione audio, taglio, diarization, distillazione) vengono delegate a un toolkit Python separato. La sessione li lancia e ne consuma i risultati.

Sorgente: `brain-suite/tools/` → installato con `uv sync`

### Separazione delle responsabilità

| Cosa | Nel repo | Runtime (dove Claude Code lo trova) | Natura |
|------|----------|--------------------------------------|--------|
| Comandi `/brain:*` | `config/commands/brain/` | `~/.claude/commands/brain/` (symlink) | Prompt markdown |
| Agenti brain-* | `config/agents/` | `~/.claude/agents/brain-*.md` (symlink) | Prompt markdown |
| Workflows, templates, references | `config/brainstorm/` | `~/.claude/brainstorm/` (symlink) | Prompt markdown |
| Processing toolkit | `tools/` | `~/Projects/brain-suite/tools/` (uv project) | Codice Python |
| Artefatti di progetto | — (non nel repo) | `<cartella-progetto>/.brainstorm/` | Dati generati |

### Comunicazione tra i due livelli

```
┌─────────────────────────────────────┐
│   Claude Code Session (brain:)      │
│   ~/.claude/ → symlink al repo     │
│   = conversazione + decisioni       │
│                                     │
│   "Trascrivi questa registrazione"  │
│           │                         │
│           ▼                         │
│   Dispatch:                         │
│   uv run --project                  │
│     ~/Projects/brain-suite/tools    │
│     brain-tools transcribe file.webm│
│           │                         │
│   ← Risultato in .brainstorm/      │
│                                     │
│   "Ok, dal transcript emergono      │
│    questi temi. Approfondiamo..."   │
└─────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────┐
│   ~/Projects/brain-suite/tools/     │
│   Processing Layer (software)       │
│                                     │
│   • ffmpeg → trim/normalizza audio  │
│   • faster-whisper → trascrizione   │
│   • pyannote → diarization          │
│   • LLM API → distillazione        │
│                                     │
│   Scrive risultati in .brainstorm/  │
└─────────────────────────────────────┘
```

### Evoluzione progressiva del processing layer

| Fase | Approccio | Cosa cambia nel repo | Descrizione |
|------|-----------|----------------------|-------------|
| **v1 (ora)** | Nessun processing | Solo `config/` | Brainstorming puramente interattivo. `tools/` non serve ancora. |
| **v1.5** | CLI toolkit Python | + `tools/` con CLI | Comandi CLI. La sessione li lancia con `uv run --project ~/Projects/brain-suite/tools brain-tools <cmd>`. |
| **v2** | MCP Server | + `mcp_server.py` in `tools/` | Il toolkit aggiunge entrypoint MCP. Registrato in `~/.claude.json`. |

---

## Voice & Transcription: Landscape tecnologico

### Per dettatura in tempo reale (voce → terminale)

Tool desktop che scrivono nel campo attivo. Nessuno ha API — sono "tastiere vocali".

| Tool | Note |
|------|------|
| **Wispr Flow** | macOS, cloud-based, $144/anno, cattura screenshot per contesto |
| **Superwhisper** | macOS, context-aware |
| **VoiceInk** | Open-source, 100+ lingue |
| **FluidVox** | macOS, $39 lifetime, per-app style control |
| **Voibe** | 100% offline, privacy-first |

### Per trascrizione programmatica (audio file → testo)

| Strumento | Tipo | Costo | Punto di forza |
|-----------|------|-------|----------------|
| **faster-whisper** | Locale, Python | Gratis | 4x più veloce di Whisper, CPU/GPU, diarization con pyannote |
| **OpenAI Whisper API** | Cloud | $0.006/min | Semplicissimo, batch, molto accurato |
| **Deepgram Nova-2** | Cloud | ~$0.0043/min | Streaming real-time, velocissimo |
| **AssemblyAI** | Cloud | $0.15/h | Diarization nativa, sentiment, summarization built-in |
| **Aqua Voice Avalon** | Cloud | $0.39/h | Addestrato su parlato developer (capisce nomi di tool, CLI, modelli) |

**Scelta raccomandata per v1.5/v2:** `faster-whisper` locale + `pyannote` per diarization. Zero costo, privacy totale, qualità eccellente. Fallback su Whisper API per file lunghi.

### Per orchestrazione pipeline

| Approccio | Pro | Contro | Quando |
|-----------|-----|--------|--------|
| **Python CLI toolkit** (`uv run brain-tools ...`) | Semplice, zero dipendenze extra, tutto locale | Nessun retry/parallelizzazione built-in | v1.5 |
| **Custom MCP Server** | Integrazione nativa Claude Code, processo separato | Più complesso, MCP sincrono | v2 |
| **n8n / workflow esterno** | UI visuale, retry/error gratis, estensibile | Overkill per singolo developer, dipendenza | Solo se necessario |

---

## Design dell'interazione

### Principio chiave

La sessione ragiona **INSIEME** all'utente, non genera documenti da sola. Ogni dimensione viene esplorata con ciclo interattivo.

### Voice-First (interaction design)

L'utente parla tramite voice-to-text (Wispr Flow o simili) che trascrive nel terminale. L'impatto è sul **design dell'interazione**, non sull'architettura.

**Risposte di Claude:**
- Brevi e scannable: paragrafi corti, bullet points, niente muri di testo
- Una domanda alla volta: mai blocchi di 3-4 domande insieme
- Riepilogo prima della domanda: prima riassumi, poi chiedi

**Input dell'utente (parlato):**
- Tolleranza al parlato informale: frasi interrotte, riformulazioni, tono colloquiale
- AskUserQuestion con opzioni chiare: label brevi e distinguibili vocalmente
- Non richiedere mai input strutturato: accettare flusso di coscienza

**Flusso conversazionale:**
- Suggerimento proattivo del passo successivo
- Transizioni naturali senza richiedere slash commands tra passi
- Ritmo da conversazione: alternare sfida e costruzione

---

## Storage per progetto: `.brainstorm/`

Creato nella cartella corrente quando si lancia `/brain:new`.

```
.brainstorm/
├── IDEA.md                  # Definizione core (cosa, perché, chi, visione)
├── SESSION.md               # Stato sessione (dimensioni esplorate, date, note, timestamp)
├── dimensions/
│   ├── product.md           # Visione prodotto, funzionalità, UX
│   ├── tech.md              # Stack, architettura, fattibilità
│   ├── market.md            # Promozione, canali, messaging
│   ├── business.md          # Revenue, pricing, unit economics
│   ├── competitors.md       # Landscape competitivo, differenziazione
│   ├── users.md             # Personas, journey, pain points
│   └── custom-*.md          # Dimensioni custom
├── sessions/                # Log conversazionali
│   ├── product-2026-03-04.md
│   └── ...
├── transcripts/             # Trascrizioni processate (v1.5+)
│   └── ...
├── recordings/              # Audio grezzi (v2+)
│   └── ...
├── SYNTHESIS.md             # Sintesi cross-dimensionale
└── HANDOFF.md               # Documento per /gsd:new-project
```

### Framework: `~/.claude/brainstorm/`

```
brainstorm/
├── workflows/
│   ├── new-session.md
│   ├── explore-dimension.md
│   ├── synthesize.md
│   ├── resume-session.md
│   └── handoff.md
├── templates/
│   ├── idea.md
│   ├── session.md
│   ├── dimension-product.md
│   ├── dimension-tech.md
│   ├── dimension-market.md
│   ├── dimension-business.md
│   ├── dimension-competitors.md
│   ├── dimension-users.md
│   ├── synthesis.md
│   └── handoff.md
└── references/
    ├── questioning.md
    ├── frameworks.md
    └── dimensions-guide.md
```

---

## Comandi: `~/.claude/commands/brain/`

| Comando | Descrizione | Agent | Note |
|---------|-------------|-------|------|
| `new.md` | Inizia sessione brainstorming | — (orchestratore) | Crea `.brainstorm/`, questioning iniziale |
| `explore.md` | Esplora una dimensione | brain-explorer | Argomento: nome dimensione |
| `product.md` | Shortcut → explore product | brain-explorer | Thin wrapper |
| `tech.md` | Shortcut → explore tech | brain-explorer | Thin wrapper |
| `market.md` | Shortcut → explore market | brain-explorer | Thin wrapper |
| `business.md` | Shortcut → explore business | brain-explorer | Thin wrapper |
| `competitors.md` | Shortcut → explore competitors | brain-explorer | + brain-researcher per dati reali |
| `users.md` | Shortcut → explore users | brain-explorer | Thin wrapper |
| `synthesize.md` | Sintesi cross-dimensionale | brain-synthesizer | Richiede 2+ dimensioni |
| `status.md` | Overview sessione | — (orchestratore) | Legge SESSION.md |
| `resume.md` | Riprendi sessione | — (orchestratore) | Ricarica contesto da `.brainstorm/` |
| `handoff.md` | Genera documento GSD | brain-synthesizer | Produce HANDOFF.md |
| `add-dimension.md` | Aggiungi dimensione custom | — (orchestratore) | Crea template e registra |

---

## Agenti: `~/.claude/agents/`

| Agente | Ruolo | Tools chiave |
|--------|-------|-------------|
| `brain-explorer.md` | Esplorazione interattiva Socratica. Guida con domande probing, sfida assunzioni, suggerisce angoli non considerati. Ragiona INSIEME all'utente. | Read, Write, Edit, Bash, Glob, Grep, AskUserQuestion, mcp__exa__web_search_exa |
| `brain-researcher.md` | Ricerca web fattuale: dati di mercato, competitor, trend, sizing. Spawnable dall'explorer quando servono dati reali. | Read, Write, Bash, mcp__exa__web_search_exa, mcp__exa__get_code_context_exa, WebFetch |
| `brain-synthesizer.md` | Sintesi cross-dimensionale: legge dimensioni, identifica pattern, conflitti, opportunità, gap. Genera SYNTHESIS.md e HANDOFF.md. | Read, Write, Bash, Glob, Grep |

---

## Flusso tipico

```
1. cd ~/Projects/my-new-idea
2. /brain:new          → Questioning interattivo → IDEA.md + SESSION.md
3. /brain:product      → Esplorazione prodotto interattiva → dimensions/product.md
4. /brain:users        → User research interattiva → dimensions/users.md
5. /brain:competitors  → Ricerca + analisi competitiva → dimensions/competitors.md
6. /brain:tech         → Esplorazione tecnica → dimensions/tech.md
7. /brain:business     → Business model → dimensions/business.md
8. /brain:market       → Strategia marketing → dimensions/market.md
9. /brain:synthesize   → Sintesi di tutto → SYNTHESIS.md
10. /brain:handoff     → Documento GSD-ready → HANDOFF.md
11. /gsd:new-project --from-brainstorm → Consuma HANDOFF.md
```

L'ordine è libero. L'utente può esplorare le dimensioni che vuole, nell'ordine che vuole, e tornare su dimensioni già esplorate.

---

## Integrazione GSD

`/brain:handoff` produce `HANDOFF.md` con sezioni mappate a ciò che `/gsd:new-project` chiede:

- Cosa si costruisce → `## Product Vision`
- Perché → `## Problem & Opportunity`
- Per chi → `## Target Users`
- Stack/vincoli tecnici → `## Technical Constraints`
- Differenziazione → `## Competitive Edge`
- Business model → `## Revenue Model`

`/gsd:new-project` verrà aggiornato per accettare flag `--from-brainstorm` che legge `.brainstorm/HANDOFF.md`.

---

## Visione futura

### v1 — Developer + Claude (implementare ora)

- Brainstorming interattivo via voice-to-text
- L'utente detta, Claude risponde, la conversazione produce artefatti strutturati
- Transcript sessione: ogni esplorazione salva log conversazionale
- Output: `.brainstorm/dimensions/<dim>.md` + `.brainstorm/sessions/<dim>-<timestamp>.md`

### v1.5 — Processing pipeline locale (prossimo step)

Il toolkit vive in `brain-suite/tools/` (stesso repo).

**Uso da terminale (standalone):**
```bash
uv run --project ~/Projects/brain-suite/tools brain-tools transcribe recording.webm -o .brainstorm/transcripts/
uv run --project ~/Projects/brain-suite/tools brain-tools trim recording.webm --silence
uv run --project ~/Projects/brain-suite/tools brain-tools diarize transcript.md
uv run --project ~/Projects/brain-suite/tools brain-tools distill transcript.md
```

**Uso da Claude Code (mediatore):**
La sessione lancia i comandi con `Bash run_in_background`, continua la conversazione, e legge i risultati da disco quando pronti.

**Nuovi comandi bridge** (in `config/commands/brain/`):
- `/brain:transcribe <file>` → dispatcha a `brain-tools transcribe`
- `/brain:distill <file>` → dispatcha a `brain-tools distill`

### v2 — MCP Server + Client recordings

Stessa codebase `brain-suite/tools/`, aggiunge `mcp_server.py`.

Registrato in `~/.claude.json`:
```json
"mcpServers": {
  "brain-tools": {
    "command": "uv",
    "args": ["run", "--project", "<path-to>/brain-suite/tools", "brain-tools-mcp"]
  }
}
```

I comandi CLI restano usabili standalone. La sessione Claude Code li chiama come tool MCP nativi.

**Nuovi artefatti:**
```
.brainstorm/
├── recordings/
│   ├── 2026-03-04-client-call.webm
│   └── 2026-03-04-client-call.txt
├── transcripts/
│   ├── 2026-03-04-client-call.md
│   └── ...
```

**Nuovi comandi:**
- `/brain:record` — avvia registrazione
- `/brain:import <file>` — importa trascrizione esterna e popola dimensioni

### v3 — Conversation Intelligence

- Analisi semantica cross-sessione
- Generazione scope/proposal dal distillato
- Pipeline: registra → pulisci → distilla → struttura → handoff GSD

### v4 — App Android (centralizzazione mobile)

Tutto il flusso brain: accessibile da mobile. L'app Android diventa il punto di ingresso principale:
- **Registrazione audio** diretta dal telefono (meeting, chiamate, note vocali)
- **Trascrizione on-device** o via API cloud
- **Sync con `.brainstorm/`** su desktop (via cloud storage o sync diretto)
- **Consultazione artefatti** (dimensioni, sintesi, handoff) in formato mobile-friendly
- **Input vocale** per sessioni di brainstorming anche lontano dal terminale

Il backend di processing (`tools/`) resterebbe server-side o desktop. L'app sarebbe un client che cattura input e visualizza output.

Impatto architetturale su v1: nessuno, purché i formati degli artefatti (`.brainstorm/*.md`) restino semplici markdown leggibili da qualsiasi client.

---

## Piattaforma

**Target iniziale:** Linux (WSL2). Install script usa `ln -sfn` (symlink POSIX).

Supporto futuro Windows nativo e macOS verrà aggiunto dopo la v1. Le differenze sono minime:
- macOS: symlink funzionano identicamente, nessun cambiamento
- Windows nativo: symlink richiedono privilegi admin o Developer Mode; alternativa: copia con script di sync

---

## File da creare nel repo `brain-suite/`

### v1 — Config Claude Code (`config/`)

#### Comandi — `config/commands/brain/` (13 file)

1. `new.md` — orchestratore sessione
2. `explore.md` — esplorazione generica con argomento dimensione
3. `product.md` — shortcut product
4. `tech.md` — shortcut tech
5. `market.md` — shortcut market
6. `business.md` — shortcut business
7. `competitors.md` — shortcut competitors
8. `users.md` — shortcut users
9. `synthesize.md` — sintesi cross-dimensionale
10. `status.md` — overview sessione
11. `resume.md` — ripresa sessione
12. `handoff.md` — generazione documento GSD
13. `add-dimension.md` — aggiunta dimensione custom

#### Agenti — `config/agents/` (3 file)

14. `brain-explorer.md`
15. `brain-researcher.md`
16. `brain-synthesizer.md`

#### Workflow — `config/brainstorm/workflows/` (5 file)

17. `new-session.md`
18. `explore-dimension.md`
19. `synthesize.md`
20. `resume-session.md`
21. `handoff.md`

#### Template — `config/brainstorm/templates/` (10 file)

22. `idea.md`
23. `session.md`
24. `dimension-product.md`
25. `dimension-tech.md`
26. `dimension-market.md`
27. `dimension-business.md`
28. `dimension-competitors.md`
29. `dimension-users.md`
30. `synthesis.md`
31. `handoff.md`

#### Reference — `config/brainstorm/references/` (3 file)

32. `questioning.md`
33. `frameworks.md`
34. `dimensions-guide.md`

### Repo root (3 file)

35. `install.sh` — crea symlink + uv sync
36. `uninstall.sh` — rimuove symlink
37. `README.md`

### v1.5 — Processing toolkit (`tools/`)

38. `tools/pyproject.toml` — progetto uv con dipendenze
39. `tools/src/brain_tools/__init__.py`
40. `tools/src/brain_tools/cli.py` — entrypoint CLI (click)
41. `tools/src/brain_tools/transcribe.py` — faster-whisper wrapper
42. `tools/src/brain_tools/trim.py` — ffmpeg wrapper
43. `tools/src/brain_tools/diarize.py` — pyannote wrapper
44. `tools/src/brain_tools/distill.py` — LLM API distillazione
45. `tools/tests/test_cli.py` — test base

Comandi bridge aggiuntivi in `config/commands/brain/`:
46. `transcribe.md` — bridge → brain-tools transcribe
47. `distill.md` — bridge → brain-tools distill

---

## Ordine di implementazione

**Fase 1 — Fondamenta** (file 32-34, 22-23, 17, 1)
- Reference files (questioning, frameworks, dimensions guide)
- Template base (idea.md, session.md)
- Workflow new-session.md
- Comando `/brain:new`

**Fase 2 — Agenti** (file 14-16)
- brain-explorer.md, brain-researcher.md, brain-synthesizer.md

**Fase 3 — Esplorazione dimensioni** (file 24-29, 18, 2-8)
- Template per ogni dimensione
- Workflow explore-dimension.md
- Comando explore.md + 6 shortcut

**Fase 4 — Sintesi e handoff** (file 30-31, 19, 21, 9, 12)
- Template synthesis e handoff
- Workflow synthesize.md e handoff.md
- Comandi synthesize.md e handoff.md

**Fase 5 — Utilities** (file 20, 10, 11, 13)
- Workflow resume-session.md
- Comandi status.md, resume.md, add-dimension.md

---

## Verifica

1. `/brain:new` appare nella lista skill di Claude Code
2. `/brain:new` su un'idea di esempio → crea `.brainstorm/` con IDEA.md e SESSION.md
3. `/brain:product` → esplorazione interattiva → salvataggio in `dimensions/product.md`
4. `/brain:status` → mostra stato corretto
5. `/brain:synthesize` dopo 2+ dimensioni → SYNTHESIS.md
6. `/brain:handoff` → HANDOFF.md leggibile e strutturato per GSD
7. `/brain:resume` in nuova sessione → ripresa contesto
