#!/usr/bin/env python3
"""Esporta il corpus da bolle.db (produzione) a data/corpus.jsonl (versionabile).

Anonimizza file_path -> doc_id sintetico; per default non porta numero_bolla
né data_bolla (riattivabili con --include-metadata-bolla dopo revisione
manuale sui dati reali, vedi data/README.md).

Uso:
    python src/export_corpus.py /percorso/a/bolle.db [--include-metadata-bolla]
"""

import argparse
import json
import sqlite3
from pathlib import Path

OUT_PATH = Path(__file__).resolve().parent.parent / "data" / "corpus.jsonl"


def esporta(db_path: str, include_metadata_bolla: bool) -> int:
    con = sqlite3.connect(db_path)
    doc_ids = {}
    n = 0
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        for riga_id, doc_id_reale, pagina, codice, descrizione in con.execute(
            "SELECT id, doc_id, pagina, codice, descrizione FROM righe ORDER BY id"
        ):
            if doc_id_reale not in doc_ids:
                doc_ids[doc_id_reale] = f"doc_{len(doc_ids) + 1:04d}"
            record = {
                "riga_id": riga_id,
                "doc_id": doc_ids[doc_id_reale],
                "pagina": pagina,
                "codice": codice,
                "descrizione": descrizione,
            }
            if include_metadata_bolla:
                numero, data = con.execute(
                    "SELECT numero_bolla, data_bolla FROM documenti WHERE id = ?",
                    (doc_id_reale,),
                ).fetchone()
                record["numero_bolla"] = numero
                record["data_bolla"] = data
            f.write(json.dumps(record, ensure_ascii=False) + "\n")
            n += 1
    con.close()
    return n


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("db_path", help="Percorso di bolle.db (produzione)")
    parser.add_argument(
        "--include-metadata-bolla",
        action="store_true",
        help="Include numero_bolla/data_bolla nell'export (default: omessi)",
    )
    args = parser.parse_args()
    n = esporta(args.db_path, args.include_metadata_bolla)
    print(f"Esportate {n} righe in {OUT_PATH}")
