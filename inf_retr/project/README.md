# Archivio Bolle come progetto di Information Retrieval

Progetto per il corso di Information Retrieval (magistrale Computer
Engineering, Unipavia). Trasforma il sistema di ricerca bolle/DDT in
produzione ([santoromarco74/cerca_bolle](https://github.com/santoromarco74/cerca_bolle))
in un caso di studio valutato: test collection, modelli di confronto
(baseline trigram, BM25, TF-IDF), metriche standard (MRR, P@k, nDCG).

Vedi [docs/proposta-progetto-IR.md](docs/proposta-progetto-IR.md) per
l'inquadramento completo (obiettivi, metodologia, scope).

## Struttura

- `reference/cerca_bolle/` — clone **read-only** del repo di produzione, solo
  come riferimento per la baseline (`bolle_core.py`: `trigrammi()`;
  `cerca_bolle.py`: `cerca_fuzzy()`). Nessun codice di produzione viene
  modificato o eseguito da qui: questo progetto resta separato.
- `docs/` — documento di proposta e note metodologiche.
- `data/` — dataset versionato per la valutazione (corpus estratto/anonimizzato
  da `bolle.db`, query set, relevance judgments). Vedi [data/README.md](data/README.md).
- `src/` — implementazione dei modelli di confronto e script di estrazione/valutazione.
- `eval/` — metriche, risultati sperimentali, analisi qualitativa.

## Stato

In attesa dello snapshot di `bolle.db` (dati reali di produzione) per
popolare `data/`. Nel frattempo sono definiti gli schemi dati e lo scaffolding
di progetto.
