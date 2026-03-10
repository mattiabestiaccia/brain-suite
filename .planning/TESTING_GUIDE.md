# Testing Guide — Brain Suite v1.0

## Pre-requisiti

```bash
# 1. Installa se non ancora fatto
git clone https://github.com/mattiabestiaccia/brain-suite.git
cd brain-suite && ./install.sh

# 2. Crea una cartella di test (non inside il repo)
mkdir ~/test-idea && cd ~/test-idea
code .   # o apri in qualsiasi altro IDE con Claude Code
```

---

## Sessione 1 — Flusso base completo

**Obiettivo:** Verificare il ciclo completo dall'idea al handoff in un'unica sessione.

### Step 1 — Avvia

```
/brain:new
```

Atteso: Claude fa UNA sola domanda casual (tipo "Cosa stai costruendo?"). Niente preamble, niente "benvenuto".

Cosa osservare:
- Risponde in ≤8 righe prima della domanda?
- Fa davvero UNA sola domanda, mai due?
- Tollera risposta vocale frammentata senza correggerti?
- Non dice mai "ottimo punto!" o simili?

### Step 2 — Brainstorma per 5-10 minuti

Parla dell'idea liberamente. Testa:
- Dai una risposta breve ("non lo so"): Claude dovrebbe espandere, non solo annuire
- Menziona spontaneamente competitor o tech: Claude dovrebbe seguire il filo, non "ci arriveremo dopo"
- Rallenta e dai risposte circolari: Claude dovrebbe percepire il wind-down e proporre di salvare

Atteso a chiusura: Claude propone di salvare, mostra un recap, chiede conferma, poi genera `IDEA.md` + `SESSION.md` e suggerisce UNA dimensione specifica con motivazione legata alla conversazione.

```bash
cat .brainstorm/IDEA.md
cat .brainstorm/SESSION.md
```

### Step 3 — Prima dimensione

```
/brain:explore product
# oppure shortcut
/brain:product
```

Atteso: Apre con 2-3 righe da IDEA.md, annuncia la modalità (creative per product), fa la prima domanda. Tutto in ≤8 righe.

Cosa osservare:
- Segue la modalità annunciata (creative = espande possibilità, non sfida)?
- Quando dici qualcosa di non verificato ("il mercato vale miliardi"), chiede se cercare dati? → **test researcher**
- Alla chiusura: crea `dimensions/product.md` + `sessions/product-*.md`?
- Aggiorna `SESSION.md` con product=explored?

```bash
cat .brainstorm/dimensions/product.md
ls .brainstorm/sessions/
```

### Step 4 — Seconda dimensione con shortcut + cross-dimensional

```
/brain:competitors
```

Atteso: In apertura cita qualcosa da `product.md`. Durante l'esplorazione, se dici qualcosa che contraddice product, Claude lo segnala.

### Step 5 — Break tra sessioni

Chiudi Claude Code. Riaprilo nella stessa cartella.

```
/brain:resume
```

Atteso: Racconto in prosa (NON tabella/griglia) di dove eri rimasto, con UN insight per dimensione esplorata. Suggerisce la prossima dimensione con motivazione. Sotto 10 righe totali.

Poi rispondi "partiamo" → dovrebbe avviare `/brain:explore` sulla dimensione suggerita senza chiederti quale.

### Step 6 — Esplora 2-3 dimensioni in più

Almeno 2 dimensioni totali servono per la sintesi. Consiglio:

```
/brain:tech
/brain:users
```

### Step 7 — Status

```
/brain:status
```

Atteso: Dashboard con progress bar ASCII, tabella dimensioni (explored / not started), date. Non è narrative come resume — è un cruscotto.

### Step 8 — Sintesi

```
/brain:analyze
```

Atteso: Carica tutte le dimensioni, produce `ANALYSIS.md` con temi cross-dimensionali (sinergie, tensioni, contraddizioni, opportunità).

```
/brain:synthesize
```

Atteso: Espande ANALYSIS.md in `SYNTHESIS.md` con narrativa più profonda.

```
/brain:handoff
```

Atteso: Genera `HANDOFF.md` con 6 sezioni strutturate (Product Vision, Problem & Opportunity, Target Users, Technical Constraints, Competitive Edge, Revenue Model). Deve essere direttamente leggibile da `/gsd:new-project`.

```bash
cat .brainstorm/HANDOFF.md
```

---

## Sessione 2 — Edge cases

### Re-explore di una dimensione già esplorata

```
/brain:explore product
```

Atteso: chiede "approfondire o ricominciare da zero?". Testa entrambe le opzioni.

### Dimensione personalizzata

```
/brain:add-dimension
```

Segui il flusso → poi `/brain:explore [nome-custom]`.

### Explore senza /brain:new

Crea una cartella nuova e prova `/brain:explore product` senza aver mai fatto `/brain:new`.
Atteso: messaggio di errore chiaro.

### Researcher Exa

Durante un'esplorazione, fai un'affermazione quantitativa ("il mercato italiano vale 2 miliardi").
Atteso: Claude chiede "posso cercare dati su questo in background?". Di' sì → continua a parlarti mentre cerca → integra il risultato in 1-2 righe quando arriva.

---

## Cosa annotare

Tieni un file di note con:

- Cosa ha funzionato bene?
- Quando le risposte erano troppo lunghe o formali?
- Il researcher è stato suggerito nei momenti giusti?
- La sintesi è stata utile o generica?
- Il HANDOFF.md è direttamente usabile per GSD?
- Dimensioni mancanti? Template da migliorare?
- Qualcosa che ti aspettavi e non è successo?

Queste note alimenteranno il prossimo `/gsd:new-milestone` insieme a `.planning/NEXT_MILESTONE_NOTES.md`.
