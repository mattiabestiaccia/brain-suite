---
status: testing
phase: 06-synthesis-handoff
source: [06-01-SUMMARY.md, 06-02-SUMMARY.md]
started: 2026-03-09T10:15:00Z
updated: 2026-03-09T10:15:00Z
---

## Current Test
<!-- OVERWRITE each test - shows where we are -->

number: 1
name: /brain:analyze - validazione prerequisiti
expected: |
  Eseguire /brain:analyze senza una sessione attiva con 2+ dimensioni esplorate.
  Dovrebbe mostrare un messaggio di errore in italiano che spiega la necessità di almeno 2 dimensioni esplorate.
awaiting: user response

## Tests

### 1. /brain:analyze - validazione prerequisiti
expected: Eseguire /brain:analyze senza sessione con 2+ dimensioni esplorate. Mostra errore italiano spiegando che servono almeno 2 dimensioni.
result: [pending]

### 2. /brain:synthesize - validazione prerequisiti
expected: Eseguire /brain:synthesize senza ANALYSIS.md presente. Mostra errore italiano spiegando che serve prima /brain:analyze.
result: [pending]

### 3. /brain:analyze - esecuzione completa
expected: Con una sessione con 2+ dimensioni esplorate, /brain:analyze produce ANALYSIS.md con temi emergenti e gap analysis. Al termine suggerisce /brain:synthesize come prossimo passo.
result: [pending]

### 4. /brain:synthesize - esecuzione completa
expected: Con ANALYSIS.md presente, /brain:synthesize produce SYNTHESIS.md come prosa narrativa (non un riassunto/elenco). Al termine suggerisce /brain:handoff come prossimo passo.
result: [pending]

### 5. /brain:handoff - esecuzione completa
expected: /brain:handoff produce HANDOFF.md con 6 sezioni mappate a GSD PROJECT.md. Se manca SYNTHESIS.md, fa graceful fallback su ANALYSIS.md o solo dimensioni.
result: [pending]

### 6. /brain:status - suggerimento pipeline corretto
expected: Quando tutte le dimensioni sono esplorate, /brain:status suggerisce /brain:analyze come prossimo passo (NON /brain:synthesize).
result: [pending]

### 7. /brain:new - archiviazione ANALYSIS.md
expected: Avviando una nuova sessione con /brain:new, i file ANALYSIS.md esistenti vengono archiviati insieme agli altri file di sessione.
result: [pending]

## Summary

total: 7
passed: 0
issues: 0
pending: 7
skipped: 0

## Gaps

[none yet]
