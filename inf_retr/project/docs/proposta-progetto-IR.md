# Proposta: Archivio Bolle come progetto di Information Retrieval

> Documento di preparazione per una sessione separata (tesi/progetto per la
> magistrale in Computer Engineering). Non contiene implementazione — solo
> inquadramento, obiettivi e linee guida operative da seguire quando si
> apre la sessione dedicata.

## 1. Punto di partenza

Esiste già un sistema funzionante e in uso reale (non un giocattolo):
ricerca di articoli su bolle/DDT scansionati, indicizzati via OCR
(Tesseract), con:

- **Indice esatto**: SQLite FTS5 con tokenizer `trigram` (n-grammi di
  caratteri, non parole — sceglie di essere robusto a errori OCR a
  livello di carattere).
- **Fallback fuzzy**: coefficiente di similarità tipo Jaccard/Dice su
  trigrammi di caratteri, calcolato in Python (non è tf-idf, non è
  BM25 — è un puro matching per overlap di n-grammi).
- **Corpus reale**: ~157 documenti, ~936 righe indicizzate (bolle di un
  solo fornitore, GAER), in crescita nell'uso quotidiano.
- Ranking oggi affidato a `rank` nativo di FTS5 (BM25 interno di SQLite)
  per i match esatti, e a un punteggio di similarità ad hoc per i fuzzy.

Questo è già un caso di studio legittimo di IR applicata: retrieval su
testo **rumoroso** (errori OCR sistematici, non solo typo umani), non un
dataset da manuale.

## 2. Cosa manca perché sia un progetto accademico, non solo un tool

Un tool che "funziona" non è di per sé un progetto di IR valutabile.
Serve aggiungere il pezzo che oggi non c'è: **una valutazione
sperimentale formale**. Senza quella, non c'è nulla da discutere in sede
di tesi al di là di "ho scritto del codice che sembra funzionare".

Tre cose da costruire, in ordine di priorità:

1. **Una test collection** (query + giudizi di rilevanza)
2. **Almeno un modello di confronto** oltre a quello attuale
3. **Metriche standard di IR**, non "sembra trovare la cosa giusta"

## 3. Modelli da confrontare

| Modello | Cosa rappresenta | Note implementative |
|---|---|---|
| **Baseline attuale** | trigram exact match (FTS5) + fallback Jaccard/Dice su trigrammi | già implementato, va solo isolato/documentato come baseline |
| **BM25 "vero"** | ranking probabilistico su token lessicali (parole, non trigrammi di caratteri) | FTS5 supporta `tokenize='porter'` o `unicode61`; oppure Whoosh/rank_bm25 in Python per isolarlo dal resto del sistema |
| **TF-IDF classico** | vector space model | scikit-learn (`TfidfVectorizer` + cosine similarity) — utile come termine di paragone "da manuale" |
| **(estensione) Embedding semantici** | matching non solo lessicale | `sentence-transformers` multilingue (es. `paraphrase-multilingual-MiniLM`), utile a mostrare cosa il trigram matching NON cattura (sinonimi commerciali, es. "friggitrice ad aria" vs "air fryer") |

Il confronto interessante da tesi non è "quale vince in assoluto", ma
**perché** un modello lessicale/n-gram (trigram) si comporta meglio o
peggio di BM25/TF-IDF **specificamente in presenza di rumore OCR** — è
quello il contributo originale, non il benchmark generico.

## 4. Costruzione della test collection

Il corpus esiste già (bolle indicizzate); manca la parte di valutazione:

1. **Query set**: 30–50 query realistiche, costruite in tre fasce:
   - query pulite (descrizione corretta di un articolo esistente)
   - query con typo umano intenzionale
   - query costruite a partire da testo OCR realmente sporco (prendere
     righe OCR imperfette dal corpus stesso come query)
2. **Relevance judgments**: per ogni query, quali righe/documenti sono
   "corretti". Dato il dominio (ricerca per articolo), spesso c'è
   **una sola risposta corretta per query** → questo rende naturali
   metriche come **MRR** (Mean Reciprocal Rank) più che Precision/Recall
   puri, che assumono più documenti rilevanti per query.
3. **Attenzione al bias**: se le query e i giudizi li scrive la stessa
   persona che ha scritto il sistema, dichiararlo esplicitamente come
   limite metodologico nella tesi (non è invalidante, ma va detto).

## 5. Metriche da usare

- **MRR** (metrica principale, coerente col caso "una risposta giusta")
- **Precision@k / Recall@k** per k piccoli (es. k=1,3,5) — utile per
  discutere l'esperienza utente reale (l'utente guarda i primi risultati)
- **nDCG** solo se si passa a giudizi di rilevanza graduati (es. 0=non
  rilevante, 1=stesso articolo ma bolla sbagliata, 2=match esatto)
- Eventualmente: tempo di risposta / scalabilità (il fallback fuzzy oggi
  fa scansione lineare in Python — punto debole noto, buon materiale per
  una sezione "limiti e possibili ottimizzazioni")

## 6. Metodologia sperimentale suggerita

1. Isolare il corpus e i giudizi in un dataset versionato a parte (non
   mescolare con `bolle.db` di produzione).
2. Eseguire tutti i modelli sulla stessa query set, stesso corpus.
3. Riportare le metriche per modello, **più un'analisi qualitativa**: 3-5
   esempi concreti di query dove un modello vince e un altro perde, con
   spiegazione (è la parte che in genere convince di più in una
   discussione di tesi rispetto alla sola tabella di numeri).
4. Ablation semplice: soglia del fuzzy fallback (0.25 vs 0.35 vs altre),
   con/senza il fallback — per mostrare metodo, non solo risultato.
5. Se il dataset resta piccolo (~1000 righe), dichiararne i limiti
   statistici esplicitamente invece di forzare test di significatività
   poco solidi.

## 7. Possibili estensioni per alzare il livello (opzionali, in ordine di sforzo)

- Query expansion con sinonimi/varianti commerciali di articoli
- Correzione OCR mirata pre-indicizzazione (dizionario di categoria +
  edit distance) e misurare l'impatto diretto sul retrieval
- Se in futuro ci sono log reali di ricerca (query digitate dagli utenti
  + quale risultato hanno aperto/scaricato), usarli come proxy di
  rilevanza al posto di giudizi manuali — più credibile, ma richiede
  raccogliere il log per un periodo prima di poterlo usare

## 8. Cosa portare alla sessione separata

- Questo documento
- Uno **snapshot** di `bolle.db` (o un estratto anonimizzato, se i nomi
  fornitori/clienti nelle descrizioni sono sensibili)
- Il codice attuale (`bolle_core.py` in particolare: `trigrammi()`,
  `cerca_fuzzy`/`cerca_righe`) come riferimento della baseline
- Indicazione se il progetto deve restare **separato** dal repo
  `cerca_bolle` (strumento in produzione) o essere uno **branch/fork**
  dedicato — consigliato tenerli separati per non mescolare codice di
  produzione con codice sperimentale/di valutazione

## 9. Prompt di avvio suggerito per la sessione separata

```
Ho un sistema di ricerca full-text/fuzzy già funzionante (SQLite FTS5
trigram + fallback Jaccard su n-grammi di caratteri), usato in produzione
per cercare articoli su bolle scansionate via OCR. Voglio trasformarlo in
un progetto di Information Retrieval per la magistrale in Computer
Engineering: mi serve costruire una test collection (query + relevance
judgments), implementare almeno BM25 e TF-IDF come confronto, valutare
con MRR/Precision@k/nDCG, e scrivere un'analisi qualitativa dei casi in
cui i modelli divergono, con particolare attenzione a come il rumore OCR
degrada ciascun approccio. Alleghi il documento "proposta-progetto-IR.md"
con le linee guida complete. Iniziamo dalla costruzione della test
collection.
```

## 10. Nota di scope

Questo è lavoro sostanzioso (settimane, non ore): costruire giudizi di
rilevanza a mano e implementare/valutare più modelli non è
un'estensione rapida del tool esistente. Va trattato come un progetto a
sé, con il codice attuale come punto di partenza e non come vincolo.
