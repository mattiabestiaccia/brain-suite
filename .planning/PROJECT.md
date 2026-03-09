# Brain Suite

## What This Is

Framework completo per brainstorming strutturato su idee di prodotto in Claude Code. La suite permette esplorazione interattiva (Socratica, sfidante, creativa) su molteplici dimensioni (product, tech, market, business, competitors, users), salva artefatti su disco per ripresa tra sessioni, e produce un handoff document consumabile da `/gsd:new-project` per passare all'implementazione.

Flusso complessivo: `brain:` (esplora, ragiona, valida) → `gsd:` (pianifica, implementa, verifica).

## Core Value

L'utente può esplorare un'idea di prodotto in modo strutturato e interattivo, dimensione per dimensione, con artefatti persistenti che sopravvivono tra sessioni e producono un output azionabile per l'implementazione.

## Requirements

### Validated

- ✓ Comandi `/brain:*` registrati e funzionanti in Claude Code (13 comandi) — v1.0
- ✓ 3 agenti specializzati (explorer, researcher, synthesizer) con ruoli distinti — v1.0
- ✓ 5 workflow che orchestrano il flusso (new-session, explore-dimension, synthesize, resume-session, handoff) — v1.0
- ✓ 10 template per artefatti strutturati (idea, session, 6 dimensioni, synthesis, handoff) — v1.0
- ✓ 4 reference file (questioning, frameworks, dimensions-guide, voice-interaction) — v1.0
- ✓ Storage per progetto in `.brainstorm/` con struttura definita — v1.0
- ✓ Esplorazione interattiva voice-first: risposte brevi, una domanda alla volta, tolleranza parlato informale — v1.0
- ✓ Session log puliti (rumore conversazionale rimosso, contenuto intatto) per ripresa contesto — v1.0
- ✓ Re-explore di dimensioni già esplorate con scelta utente (approfondire o ripartire) — v1.0
- ✓ Resume sessione con caricamento completo (IDEA + SESSION + tutte le dimensioni) — v1.0
- ✓ Sintesi cross-dimensionale (richiede 2+ dimensioni esplorate) — v1.0
- ✓ Handoff document strutturato per passaggio a GSD — v1.0
- ✓ Explorer con gate ibrido: suggerisce quando i punti chiave sono coperti, utente decide — v1.0
- ✓ Researcher spawned su suggerimento explorer + conferma utente per dati reali — v1.0
- ✓ Install/uninstall script funzionanti (symlink in `~/.claude/`) — v1.0
- ✓ README.md con istruzioni di installazione e uso — v1.0

### Active

(Nessun requisito attivo — in attesa di v1.5 o nuovo milestone)

### Out of Scope

### Out of Scope

- Python processing toolkit (tools/) — v1.5, milestone separato
- MCP Server — v2
- Flag `--from-brainstorm` per `/gsd:new-project` — modifica separata a GSD
- App Android — v4
- Conversation intelligence — v3
- Supporto Windows nativo — post-v1
- Registrazione/importazione audio — v2

## Context

**Shipped v1.0** — Brain Suite MVP completo e funzionante (2026-03-09).

Tech stack: Markdown-as-prompt + Claude Code slash commands + 3 specialized agents + Exa MCP.
90 file nel repo, ~15,400 inserzioni in 5 giorni di sviluppo (2026-03-04 → 2026-03-09), 7 fasi, 14 piani.

Il flusso E2E è stato verificato e tutti i gap critici dell'audit sono stati chiusi (templates/ symlink, pipeline references, frameworks.md runtime loading).

Prossimo milestone: v1.5 Python processing toolkit — faster-whisper + pyannote per trascrizione, taglio, diarization, distillazione conversazionale.

## Context

**Modello d'uso:** L'utente apre una cartella di progetto (anche vuota), lancia `/brain:new`, e una sottocartella `.brainstorm/` viene creata con tutti gli artefatti. Tool a sé stante, non dipendente da GSD per funzionare.

**Architettura a due livelli:**
- Livello 1 (v1): Config Claude Code — comandi, agenti, workflow, template, reference. Tutto vive nel repo come prompt markdown, symlinked in `~/.claude/`.
- Livello 2 (v1.5+): Processing pipeline Python — trascrizione, taglio, diarization, distillazione. Separato ma nello stesso monorepo.

**Design voice-first:** L'utente interagisce primariamente via voice-to-text. Le risposte di Claude devono essere brevi e scannable, con una domanda alla volta. Le regole vivono in un reference file centralizzato (`voice-interaction.md`) referenziato dai workflow.

**Distribuzione:** Monorepo GitHub. `git clone` + `./install.sh` crea symlink da `~/.claude/` ai file nel repo. Aggiornamenti con `git pull` (symlink, nessuna copia).

**Artefatti per progetto:**
```
.brainstorm/
├── IDEA.md                  # Definizione core
├── SESSION.md               # Stato sessione
├── dimensions/              # Output strutturati per dimensione
├── sessions/                # Log conversazionali puliti
├── SYNTHESIS.md             # Sintesi cross-dimensionale
└── HANDOFF.md               # Documento per GSD
```

**Pattern di riferimento:** L'architettura segue il pattern GSD (workflow orchestrano, reference file centralizzano regole, template definiscono struttura output, agenti eseguono).

## Constraints

- **Piattaforma**: Linux (WSL2) — symlink POSIX. macOS compatibile senza modifiche, Windows nativo differito
- **Runtime**: Claude Code — i comandi sono prompt markdown, non software eseguibile
- **Distribuzione**: Symlink da `~/.claude/` al repo — nessun file copiato, modifiche riflesse immediatamente
- **Coesistenza**: `~/.claude/agents/` contiene anche agenti di altri tool (GSD) — symlink singoli file, non directory
- **Indipendenza**: Brain Suite funziona senza GSD installato. Il bridge è opzionale
- **TDD**: Ogni componente software (Python toolkit, MCP server, CLI) deve seguire Test-Driven Development. Non si applica ai file markdown/prompt del v1

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Monorepo config + tools | Un solo clone per avere tutto, tools Python come sottoprogetto uv indipendente | ✓ Good — struttura confermata funzionante |
| Symlink per distribuzione | Zero copia, modifiche immediate, git-tracked | ✓ Good — install.sh + manifest funzionano, `git pull` propaga aggiornamenti |
| Reference file per voice-first | Pattern GSD: fonte di verità centralizzata, workflow la consumano | ✓ Good — voice-interaction.md referenziato da tutti i comandi |
| Session log = transcript pulito | Rimuovere rumore conversazionale, mantenere contenuto intatto per ripresa contesto | ✓ Good — pattern implementato in explore.md |
| Explorer depth ibrido | Suggerisce quando coperto ma lascia controllo all'utente — non blocca il flusso | ✓ Good — implementato in explore.md con suggestion trigger |
| Researcher spawn = suggerimento + conferma | Explorer identifica bisogno dati reali, utente conferma prima dello spawn | ✓ Good — permission flow esplicito prima dello spawn |
| v1 solo config, v1.5 Python | Consegnare valore subito senza dipendenze pesanti (faster-whisper, pyannote) | ✓ Good — v1.0 shipped pulito, v1.5 rimane scope separato |
| GSD bridge fuori scope v1 | HANDOFF.md prodotto, passaggio manuale — la modifica a GSD è separata | ✓ Good — handoff funziona, integrazione GSD differita correttamente |
| templates/ symlink aggiunto post-audit | Audit ha trovato gap critico in install.sh (Phase 7) | ✓ Good — gap chiuso, install ora completo |

---
*Last updated: 2026-03-09 after v1.0 milestone*
