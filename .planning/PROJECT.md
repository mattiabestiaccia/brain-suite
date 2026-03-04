# Brain Suite

## What This Is

Framework completo per brainstorming strutturato su idee di prodotto in Claude Code. La suite permette esplorazione interattiva (Socratica, sfidante, creativa) su molteplici dimensioni (product, tech, market, business, competitors, users), salva artefatti su disco per ripresa tra sessioni, e produce un handoff document consumabile da `/gsd:new-project` per passare all'implementazione.

Flusso complessivo: `brain:` (esplora, ragiona, valida) → `gsd:` (pianifica, implementa, verifica).

## Core Value

L'utente può esplorare un'idea di prodotto in modo strutturato e interattivo, dimensione per dimensione, con artefatti persistenti che sopravvivono tra sessioni e producono un output azionabile per l'implementazione.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Comandi `/brain:*` registrati e funzionanti in Claude Code (13 comandi)
- [ ] 3 agenti specializzati (explorer, researcher, synthesizer) con ruoli distinti
- [ ] 5 workflow che orchestrano il flusso (new-session, explore-dimension, synthesize, resume-session, handoff)
- [ ] 10 template per artefatti strutturati (idea, session, 6 dimensioni, synthesis, handoff)
- [ ] 4 reference file (questioning, frameworks, dimensions-guide, voice-interaction)
- [ ] Storage per progetto in `.brainstorm/` con struttura definita
- [ ] Esplorazione interattiva voice-first: risposte brevi, una domanda alla volta, tolleranza parlato informale
- [ ] Session log puliti (rumore conversazionale rimosso, contenuto intatto) per ripresa contesto
- [ ] Re-explore di dimensioni già esplorate con scelta utente (approfondire o ripartire)
- [ ] Resume sessione con caricamento completo (IDEA + SESSION + tutte le dimensioni)
- [ ] Sintesi cross-dimensionale (richiede 2+ dimensioni esplorate)
- [ ] Handoff document strutturato per passaggio a GSD
- [ ] Explorer con gate ibrido: suggerisce quando i punti chiave sono coperti, utente decide
- [ ] Researcher spawned su suggerimento explorer + conferma utente per dati reali
- [ ] Install/uninstall script funzionanti (symlink in `~/.claude/`)
- [ ] README.md con istruzioni di installazione e uso

### Out of Scope

- Python processing toolkit (tools/) — v1.5, milestone separato
- MCP Server — v2
- Flag `--from-brainstorm` per `/gsd:new-project` — modifica separata a GSD
- App Android — v4
- Conversation intelligence — v3
- Supporto Windows nativo — post-v1
- Registrazione/importazione audio — v2

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
| Monorepo config + tools | Un solo clone per avere tutto, tools Python come sottoprogetto uv indipendente | — Pending |
| Symlink per distribuzione | Zero copia, modifiche immediate, git-tracked | — Pending |
| Reference file per voice-first | Pattern GSD: fonte di verità centralizzata, workflow la consumano | — Pending |
| Session log = transcript pulito | Rimuovere rumore conversazionale, mantenere contenuto intatto per ripresa contesto | — Pending |
| Explorer depth ibrido | Suggerisce quando coperto ma lascia controllo all'utente — non blocca il flusso | — Pending |
| Researcher spawn = suggerimento + conferma | Explorer identifica bisogno dati reali, utente conferma prima dello spawn | — Pending |
| v1 solo config, v1.5 Python | Consegnare valore subito senza dipendenze pesanti (faster-whisper, pyannote) | — Pending |
| GSD bridge fuori scope v1 | HANDOFF.md prodotto, passaggio manuale — la modifica a GSD è separata | — Pending |

---
*Last updated: 2026-03-04 after initialization*
