# Phase 3: Dimension Exploration - Context

**Gathered:** 2026-03-07
**Status:** Ready for planning

<domain>

## Phase Boundary

User can interactively explore any of 6 dimensions via `/brain:explore <dimension>` (or shortcut commands like `/brain:product`), producing structured dimension artifacts and cleaned session logs. Exploration supports 3 modes (Socratic, Challenger, Creative), cross-dimensional awareness, and hybrid depth gating. Session management (resume, status, custom dimensions) belongs to Phase 4. Research integration belongs to Phase 5.

</domain>

<decisions>

## Implementation Decisions

### Apertura e flusso dell'esplorazione
- L'explorer apre con un riepilogo di ciò che IDEA.md dice sulla dimensione corrente, poi parte con la prima domanda mirata
- Flusso di conversazione libero iniziale; dopo qualche passaggio, l'explorer copre esplicitamente le sezioni del template non ancora toccate
- L'explorer suggerisce la chiusura quando i punti chiave sono coperti (hybrid depth gating), ma l'utente decide se continuare o chiudere
- Prima del salvataggio: l'explorer presenta un riepilogo finale e chiede conferma ("Va bene così o vuoi aggiustare qualcosa?"), poi salva

### Formato degli artefatti dimensionali
- Il documento dimensionale (`dimensions/<dimension>.md`) usa il template completo con tutte le sezioni sempre presenti
- Sezioni discusse: popolate con il contenuto emerso dal dialogo
- Sezioni non discusse: placeholder con 1-2 domande-spunto dal template per ricordare cosa andrebbe coperto
- Il session log (`sessions/<dimension>-<date>.md`) è un transcript distillato in formato Q&A — rimuove cortesie, ripetizioni e rumore, mantiene tutti i contenuti sostanziali
- Le correzioni fatte dall'utente nel riepilogo pre-salvataggio si riflettono solo nel documento dimensionale; il session log resta fedele alla conversazione originale

### Esperienza cross-dimensionale
- L'explorer carica tutto il contesto disponibile prima di iniziare: IDEA.md + tutti i documenti dimensionali già completati
- Connessioni e contraddizioni tra dimensioni vengono fatte emergere in modo reattivo, quando è naturale nel flusso della conversazione (non forzate)
- Quando una contraddizione viene identificata: l'explorer la segnala, la annota, e suggerisce una possibile risoluzione o quale dimensione rivisitare
- Le note cross-dimensionali compaiono sia inline (dove emergono) sia raccolte in una sezione dedicata "Cross-dimensional notes" a fine documento

### Selezione e switch delle modalità
- All'inizio dell'esplorazione, l'explorer menziona brevemente la modalità default (es. "Per Product partiamo in modalità creativa — ci stai?")
- L'explorer può proporre uno switch di modalità quando lo ritiene utile (es. "Stai dando molto per scontato — vuoi che faccia il challenger per un momento?")
- Gli switch sono temporanei per default: 2-3 scambi nella modalità alternativa, poi ritorno al default
- La modalità usata non viene tracciata negli artefatti — conta il contenuto, non il processo

### Claude's Discretion
- Quanti scambi di dialogo libero prima di passare alla copertura esplicita delle sezioni mancanti
- Formulazione esatta dei placeholder per sezioni non esplorate
- Quando e come far emergere le connessioni cross-dimensionali (judgment call contestuale)
- Formato esatto del riepilogo pre-salvataggio

</decisions>

<specifics>

## Specific Ideas

- Il flusso deve essere un ibrido: conversazione naturale che diventa strutturata verso la fine, non una checklist dall'inizio
- I placeholder nelle sezioni non esplorate devono essere utili (domande-spunto), non solo marker vuoti
- Le contraddizioni cross-dimensionali vanno gestite come opportunità di approfondimento, non come errori da correggere
- Gli switch di modalità sono micro-interventi contestuali (2-3 scambi), non cambi permanenti di registro

</specifics>

<deferred>

## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-dimension-exploration*
*Context gathered: 2026-03-07*
