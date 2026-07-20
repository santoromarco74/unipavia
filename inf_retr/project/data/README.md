# Dataset di valutazione

Isolato da `bolle.db` di produzione, come da metodologia (sezione 6 della
proposta): nessun mescolamento tra dati sperimentali e dati live.

## Stato attuale

**In attesa di `bolle.db`.** Quando sarà disponibile:

1. Copiarlo (o indicarne il percorso) qui in sessione — non va committato
   direttamente: contiene dati di produzione.
2. Eseguire `src/export_corpus.py` per generare `corpus.jsonl` (anonimizzato,
   vedi sotto) — quello sì versionabile.
3. Costruire `queries.jsonl` e `qrels.tsv` a partire dal corpus esportato
   (sezione 4 della proposta: 30-50 query in tre fasce — pulite, typo umano,
   OCR sporco reale).

## Anonimizzazione

Deciso di anonimizzare prima di versionare (fornitore unico GAER, ma
possibili riferimenti a clienti/reparti nelle descrizioni o nei metadati).
Lo script `export_corpus.py` deve:

- sostituire `file_path` con un id sintetico (`doc_0001`, ...) — mai il path
  reale, che può contenere nomi di cartelle cliente/reparto
- portare `numero_bolla` e `data_bolla` solo se non permettono
  ri-identificazione diretta di una transazione specifica (da valutare sui
  dati reali quando disponibili — per ora lo script li omette di default,
  flag `--include-metadata-bolla` per riattivarli dopo revisione manuale)
- mantenere invariate `codice` e `descrizione` di riga: sono il contenuto su
  cui si valuta il retrieval, non dati identificativi di per sé — ma vanno
  controllati a campione una volta esportati, nel caso compaiano nomi propri
  in descrizioni libere

## Formato file

### `corpus.jsonl`

Una riga articolo (`righe` in `bolle.db`) per riga JSON:

```json
{"riga_id": 1, "doc_id": "doc_0001", "pagina": 1, "codice": "123456", "descrizione": "FRIGGITRICE AD ARIA 4L INOX"}
```

### `queries.jsonl`

```json
{"query_id": "q001", "text": "friggitrice ad aria 4l", "fascia": "pulita", "note": ""}
{"query_id": "q002", "text": "frigg1trice a4 aria 4L", "fascia": "typo_umano", "note": "typo iniettato manualmente"}
{"query_id": "q003", "text": "FRIGG1TRICE AD ARlA 4L IN0X", "fascia": "ocr_sporco", "note": "riga OCR reale da doc_0007, pag.2"}
```

`fascia` ∈ {`pulita`, `typo_umano`, `ocr_sporco`} — coerente con sezione 4.1
della proposta.

### `qrels.tsv` (formato TREC-like: `query_id  0  riga_id  relevance`)

```
q001	0	1	1
q002	0	1	1
q003	0	42	1
```

`relevance`: binaria per ora (0/1, coerente con "una sola risposta corretta
per query", sezione 4.2). Se si passa a nDCG con giudizi graduati, diventa
0/1/2 (sezione 5).
