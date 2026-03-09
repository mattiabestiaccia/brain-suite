# Next Milestone Notes

*Scritto dopo v1.0 — da rileggere prima di /gsd:new-milestone*

## Stato al momento della scrittura

v1.0 shipped. Da testare sul campo prima di pianificare il prossimo milestone.

---

## Traiettorie possibili

### Traiettoria A — Completare il flusso audio (consigliata)

```
v1.5  Python toolkit       trascrizione + diarization (faster-whisper + pyannote)
v1.6  GSD bridge           /gsd:new-project --from-brainstorm legge HANDOFF.md
v2.0  MCP Server           portabilità fuori Claude Code
```

Ogni step ha valore autonomo. Non serve aspettare il successivo per usarlo.

### Traiettoria B — MCP Server subito (architetturale)

Reimplementare Brain Suite come MCP server nativo, abbandonare il layer slash-command.
Ha senso solo per distribuzione beyond Claude Code. Molto più complesso.

---

## Priorità per traiettoria A

### v1.5 — Python Toolkit (primo bottleneck reale)

Il collo di bottiglia attuale nel flusso voice-first: l'utente deve fare manualmente audio → testo.

Componenti:
- `faster-whisper` — trascrizione audio
- `pyannote` — diarization (chi parla quando)
- Taglio silenzi automatico
- Distillazione: trascritto grezzo → session log pulito in formato Brain Suite

Struttura prevista: sottoprogetto `tools/` nel monorepo, uv, TDD.

### GSD bridge (small win, alto impatto)

Modifica a GSD (repo separato): `/gsd:new-project --from-brainstorm`
legge automaticamente `.brainstorm/HANDOFF.md` invece di chiedere context all'utente.

Oggi il passaggio è manuale — funziona ma rompe la fluidità.

### v2.0 — MCP Server

Espone Brain Suite via MCP: accessibile da Cursor, Windsurf, app web custom.
**Dipende da:** capire dopo il testing se il limite "solo Claude Code" è un problema reale.

---

## Cose da osservare durante il testing

- Il flusso `/brain:new` → `/brain:explore` → `/brain:synthesize` → `/brain:handoff` funziona come atteso?
- Il voice-first funziona davvero? Le risposte sono abbastanza brevi e scannable?
- Il researcher Exa viene suggerito nei momenti giusti?
- La sintesi cross-dimensionale produce output utile o è troppo generica?
- Il HANDOFF.md è abbastanza strutturato da essere usato direttamente con GSD?
- Quali dimensioni mancano? Quali template andrebbero migliorati?
- Quanto spesso serve `/brain:resume`? Funziona bene?
- Cosa manca che non era nei requirements?

---

## Considerazioni architetturali emerse

- Oggi tutto è file-system flat in `.brainstorm/` — per conversation intelligence (v3) servirà un indice o DB
- Windows nativo richiede revisione di install.sh (symlink POSIX) — non urgente
- La coesistenza con GSD via symlink singoli funziona bene — da mantenere per v1.5+

---

*Da aggiornare con osservazioni dal testing prima di iniziare la pianificazione del prossimo milestone.*
