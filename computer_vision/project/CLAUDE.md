# CLAUDE.md — histreg

Registrazione di mappe catastali storiche su cartografia moderna.
Costituzione del progetto. Se una richiesta contraddice un invariante, fermati e segnalalo invece di procedere.

---

## 1. Contesto

Progetto d'esame per **Computer Vision**, Università di Pavia (ING-INF/05, 6 CFU, prof. Luca Lombardi).
Traccia scelta: *"More complex problems... the solution of a computer vision problem. In this case standard librery or tools may be used (opencv, mathlab, Image magick)"*.

Proposta inviata al docente, **risposta non ancora ricevuta**. Due approcci sottoposti:

- **A — Core-Vision (classico)**: preprocessing + SIFT/ORB + RANSAC, con l'obiettivo di massimizzare l'efficacia dei metodi classici tramite pulizia ottimale del segnale su mappe storiche degradate.
- **B — Comparative (ibrido)**: A, più un confronto quantitativo (RMSE, inlier ratio) con un matcher detector-free deep learning (LoFTR), per valutare la gestione del cambio di dominio visivo.

**Il progetto si costruisce come A. B è un modulo opzionale dietro interfaccia.** Se il docente approva solo A, si toglie un flag CLI e non si tocca altro. Se approva B, si abilita il modulo. Nessuna architettura che assuma B come dato.

Caso di studio: **Comune di Varazze, foglio 49**. Originale di Impianto scaricato dal servizio "Consultazione dei fogli di mappa catastale" dell'Agenzia delle Entrate.

---

## 2. Invarianti (non negoziabili)

**I1 — La ground truth viene dal JGW, non da annotazione manuale.**
Vedi §5. Nessun picking di GCP a mano. Se emerge la tentazione di annotare punti in QGIS, è il segnale che si è sbagliato qualcosa.

**I2 — Il modulo deep learning è isolato.**
Interfaccia `Matcher` con implementazioni `SiftMatcher`, `OrbMatcher`, `LoftrMatcher`. Il resto della pipeline non sa quale sta usando. `--matcher loftr` è l'unico punto in cui B esiste. Nessun `import torch` fuori da `matchers/loftr.py`, e quell'import è lazy.

**I3 — Il JGW non entra mai nell'algoritmo.**
Viene usato *solo* per calcolare la trasformazione di riferimento e valutare l'errore. Se un pixel di informazione di georeferenziazione filtra nel matching o nella stima, il risultato è privo di significato. Separazione fisica: `groundtruth.py` è importato da `evaluate.py`, mai da `pipeline.py`.

**I4 — Ogni esperimento produce numeri, non impressioni.**
Nessun "sembra funzionare meglio". RMSE in metri, inlier ratio, numero di match, success rate, tempo. Su file CSV.

**I5 — Il fallimento è un risultato.**
È probabile che i descrittori classici falliscano sul cross-domain (§7.2). Se succede, si misura e si spiega perché — non si truccano i parametri finché non esce un numero presentabile. Vedi §8: l'esperimento E1 esiste apposta per garantire che il progetto abbia comunque risultati validi.

**I6 — Metodo del bisturi.**
Ogni milestone è un programma che gira e produce un artefatto guardabile. Un commit per milestone. Niente refactoring speculativo.

**I7 — Determinismo.**
Seed fisso per RANSAC e per ogni generazione sintetica. Stesso input + stessi parametri = stesso CSV, cifra per cifra.

**I8 — Lavorare su ritagli, non su fogli interi.**
Il foglio 49 è 8000×5322 px. Tiling e gestione memoria non aggiungono nulla al tema d'esame. Ritagli di ~1000-1500 px per lato.

---

## 3. Stack

- **Python 3.12**, WSL2/Ubuntu
- `opencv-python` (SIFT, ORB, RANSAC, warp), `numpy`, `pandas` (CSV), `matplotlib` (figure per la relazione)
- `shapely` + `pyproj` o `geopandas` per leggere il vettoriale e rasterizzarlo — solo in `data_prep/`, mai nella pipeline
- **Modulo B soltanto**: `kornia` + `torch` (LoFTR). Import lazy, isolato (I2).
- `requirements.txt` con versioni pinnate. La traccia impone *"if external package are used they should be present in the final version of the project"*: pesi LoFTR (~90 MB) vendorati in `weights/`, non scaricati a runtime. Se troppo pesanti per il repo, documentare lo script di download e la checksum.

---

## 4. Struttura del repository

```
histreg/
├── CLAUDE.md
├── README.md
├── requirements.txt
├── data/
│   ├── raw/              L675_004900.jpg/.jgw/.txt, vettoriale moderno
│   ├── crops/            ritagli generati
│   └── README.md          provenienza, data di scarico, licenza
├── weights/              pesi LoFTR (solo modulo B)
├── src/
│   ├── main.py           CLI
│   ├── io_geo.py         lettura JGW, TXT, vettoriale
│   ├── groundtruth.py    trasformazione di riferimento (I3: solo per evaluate)
│   ├── prep/
│   │   ├── crop.py       ritagli dal foglio intero
│   │   ├── rasterize.py  vettoriale moderno → raster allineato
│   │   └── synth.py      generazione dataset sintetico (E1)
│   ├── preprocess.py     grayscale, denoise, Otsu/Sauvola, morfologia
│   ├── matchers/
│   │   ├── base.py       interfaccia Matcher
│   │   ├── classic.py    SiftMatcher, OrbMatcher
│   │   └── loftr.py      LoftrMatcher (modulo B, import lazy)
│   ├── estimate.py       RANSAC + modelli di trasformazione
│   ├── pipeline.py       orchestrazione (non conosce il JGW)
│   ├── evaluate.py       RMSE, inlier ratio, success rate
│   └── report.py         figure e tabelle
├── experiments/          script per E1, E2, E3
├── results/              CSV, figure
└── relazione/
```

---

## 5. Dati e ground truth — **la chiave del progetto**

Il file `L675_004900.jgw` è un world file: definisce la trasformazione **affine da pixel a coordinate** nel sistema Originario Catastale.

```
0.254453        A  → dimensione pixel in x (m)
0.0             D  → rotazione
0.0             B  → rotazione
-0.254453       E  → dimensione pixel in y (negativa: y cresce verso l'alto)
-31480.044315   C  → x del centro del pixel (0,0)
-11278.758056   F  → y del centro del pixel (0,0)
```

Quindi: `X = A·col + B·row + C`, `Y = D·col + E·row + F`. Risoluzione 0.254453 m/px, scala 1:2000.

**Conseguenza**: se il vettoriale moderno viene rasterizzato nello **stesso CRS** con una trasformazione pixel→CRS nota, allora la trasformazione vera pixel_storico → pixel_moderno si ottiene per **composizione analitica**:

```
H_true = W_moderno⁻¹ ∘ W_storico          (entrambe affini note)
```

Cioè: **la ground truth è gratis, esatta e senza un solo GCP annotato a mano.** L'algoritmo stima `H_est` guardando solo i pixel; `evaluate.py` confronta `H_est` con `H_true` e produce l'RMSE direttamente **in metri**, moltiplicando l'errore in pixel per 0.254453.

**Limite da dichiarare nella relazione, non nascondere.** Il TXT dice che il foglio è ricampionato su 76 coppie omologhe, con scarto massimo 1.28 m, scarto medio 0.56 m e deviazione standard 0.25 m. Quindi il JGW **non è verità assoluta**: è un riferimento con incertezza ~0.5 m. Un RMSE stimato sotto quella soglia non è misurabile con questo metodo — sotto mezzo metro si sta misurando il rumore del riferimento, non l'errore dell'algoritmo. Va scritto esplicitamente e va usato come pavimento nelle tabelle dei risultati.

**Ritagli** (I8): 3-4 zone dal foglio 49 con caratteristiche diverse. Suggerite: zona fitta a monte (Ribba/Cannei — tratto sottile, particelle piccole, alto rischio di fusione), zona rada (Vedrà/Castagnabuia), fascia costiera edificata (Perno/Cucco — presenza di campiture rosa). Documentare offset e dimensioni di ogni crop in `data/crops/README.md`, così sono riproducibili.

---

## 6. Pipeline

```
storico (raster)  ─┐
                   ├→ preprocess → matcher → correspondenze → RANSAC → H_est → warp
moderno (raster)  ─┘                                                      │
                                                                          ▼
                                              H_true (da JGW)  →  evaluate → RMSE, inlier ratio
```

`pipeline.py` riceve due immagini e restituisce `H_est` + metadati del matching. Non conosce il JGW (I3). `evaluate.py` è l'unico che vede entrambi.

---

## 7. Specifiche algoritmiche

### 7.1 Preprocessing (`preprocess.py`)
È il cuore dell'approccio A: *"massimizzare l'efficacia dei metodi classici tramite una pulizia ottimale del segnale"*. Ogni stadio è attivabile/disattivabile da CLI perché l'ablation è un risultato.

- Grayscale
- Denoise: mediana e/o bilaterale
- **Binarizzazione**: Otsu globale (baseline, fallirà su carta ingiallita con gradiente di illuminazione — è il risultato atteso, non "aggiustarlo") vs **Sauvola** locale, `T = m·[1 + k·(s/R − 1)]`, R=128, k=0.2, finestra 25, con immagini integrali.
- **Morfologia**: apertura per togliere il pepe, chiusura per saldare le interruzioni del tratto. SE 3×3, iterazioni da CLI.
- Opzionale: skeletonizzazione, rimozione delle componenti troppo piccole (le cifre scritte a mano sono rumore per il matching strutturale).
- CLAHE come alternativa alla binarizzazione: SIFT lavora su grayscale, non su binaria. **Testare entrambe le strade** — binarizzare potrebbe distruggere proprio la texture su cui SIFT si basa. È una delle domande sperimentali.

### 7.2 Matching (`matchers/`)

Interfaccia comune:
```python
class Matcher(Protocol):
    def match(self, img_a: np.ndarray, img_b: np.ndarray) -> tuple[np.ndarray, np.ndarray, dict]:
        """→ (punti_a Nx2, punti_b Nx2, metadati)"""
```

- `SiftMatcher`: SIFT + BFMatcher/FLANN + **ratio test di Lowe** (0.7-0.8, da CLI)
- `OrbMatcher`: ORB + BFMatcher Hamming + cross-check
- `LoftrMatcher` (**modulo B**): kornia, pesi `outdoor`, import lazy

**Rischio da mettere in conto fin da subito.** Il cross-domain qui è brutale: da un lato un disegno a mano su carta invecchiata, dall'altro un raster vettoriale di linee pulite. Entrambi sono *line drawings* quasi privi di texture, ed è esattamente il caso su cui i descrittori a blob/corner rendono peggio. È plausibile che SIFT produca pochissimi match corretti sull'E2. Questo non è un bug: è la risposta alla domanda di ricerca, purché sia **misurata** (inlier ratio, RMSE, distribuzione delle distanze dei descrittori) e non solo constatata. E1 (§8) garantisce che il progetto abbia comunque risultati solidi anche in questo scenario.

### 7.3 Stima (`estimate.py`)
RANSAC (`cv2.findHomography` / `estimateAffinePartial2D`), seed fisso (I7). Modelli selezionabili:
- similarità (4 gdl)
- affine (6 gdl)
- omografia (8 gdl)

Parametri da CLI: soglia reprojection, iterazioni, confidence. Sotto i 4 match l'algoritmo deve fallire in modo pulito, non lanciare eccezioni opache: `success=False` e riga di CSV comunque scritta.

### 7.4 Valutazione (`evaluate.py`)
Su una griglia regolare di **checkpoint** nell'immagine storica (es. 10×10, esclusi i bordi):

- `RMSE_m` = √(media(‖H_est·p − H_true·p‖²)) × 0.254453
- `inlier_ratio` = inlier / match totali
- `n_matches`, `n_inliers`
- `success` = stima riuscita **e** RMSE sotto una soglia dichiarata
- `time_ms` per fase

Una riga CSV per (esperimento, crop, matcher, preprocessing, modello). Le tabelle della relazione sono aggregazioni di questo CSV, non numeri ricopiati a mano.

---

## 8. Design sperimentale

Tre esperimenti, in ordine. **Non saltare E1**: è ciò che rende il progetto presentabile qualunque cosa succeda su E2.

### E1 — Sintetico, stesso dominio (`prep/synth.py`)
Ritaglio storico vs **se stesso trasformato con H nota** (rotazione, scala, traslazione, omografia lieve; opzionalmente degradato con rumore, blur, variazione di contrasto).
Ground truth: esatta per costruzione, zero incertezza.
Isola il matcher dal domain gap. Qui tutto **deve** funzionare: stabilisce il tetto di prestazione e valida che la pipeline sia corretta. Se E1 fallisce, il bug è nel codice, non nei dati.
Variabile indipendente: ampiezza della trasformazione, livello di degradazione. Curva RMSE vs degradazione = prima figura della relazione.

### E2 — Cross-domain reale
Ritaglio storico vs raster del vettoriale moderno, nello stesso CRS.
Ground truth: da JGW (§5), con pavimento a ~0.5 m.
È la domanda di ricerca vera. Griglia: {SIFT, ORB} × {grayscale+CLAHE, binaria Sauvola, binaria+morfologia} × {similarità, affine, omografia} × 3-4 crop.

### E3 — Comparative (**solo modulo B**)
LoFTR su E1 ed E2, stesse metriche, stessi crop.
Domanda: il matcher detector-free regge il cambio di dominio dove i descrittori classici cedono? Confronto anche sul costo computazionale.

---

## 9. Contratto CLI

```
python -m src.main --hist <crop.png> --modern <raster.png> [opzioni]

  --hist <path>             immagine storica (obbligatorio)
  --modern <path>           immagine di riferimento (obbligatorio)
  --matcher <sift|orb|loftr>    default: sift    (loftr = modulo B)
  --preprocess <none|clahe|otsu|sauvola>   default: sauvola
  --morph-close <n>         iterazioni chiusura, default 0
  --morph-open <n>          iterazioni apertura, default 0
  --model <similarity|affine|homography>   default: homography
  --ratio <float>           ratio test di Lowe, default 0.75
  --ransac-thresh <float>   px, default 3.0
  --seed <int>              default 42
  --jgw-hist <path>         world file storico   (solo evaluate)
  --jgw-modern <path>       world file moderno   (solo evaluate)
  --out-csv <path>          default: results/runs.csv (append)
  --out-figure <path>       overlay warp + match visualizzati
  --verbose
```

Se `--jgw-*` non sono forniti, la pipeline gira comunque e produce `H_est`: semplicemente non calcola RMSE. È la prova architetturale di I3.

---

## 10. Milestone

| # | Obiettivo | Criterio di accettazione |
|---|---|---|
| **M1** | I/O + crop | Legge JPG e JGW, genera 3-4 ritagli, li salva. `io_geo.py` ritorna la matrice affine corretta — verificata a mano su un pixel noto. |
| **M2** | Ground truth | `groundtruth.py` compone le due affini. Test: un punto trasformato avanti e indietro torna a se stesso entro 1e-9. |
| **M3** | E1 sintetico | `synth.py` genera coppie con H nota. La pipeline SIFT recupera H con RMSE ≈ 0. **Se qui non torna, si ferma tutto.** |
| **M4** | Preprocessing | Otsu vs Sauvola vs CLAHE, morfologia. Figure affiancate sui crop reali. |
| **M5** | E1 completo | Curva RMSE vs degradazione, SIFT vs ORB. Primo CSV vero. |
| **M6** | Rasterizzazione moderno | Vettoriale → raster allineato nel CRS. Sovrapposizione visiva con lo storico via JGW: devono coincidere a occhio. |
| **M7** | E2 cross-domain | Griglia completa. Qualunque sia il risultato, è il risultato. |
| **M8** | E3 (solo se B approvato) | LoFTR su E1 ed E2. |
| **M9** | Relazione | Tabelle e figure generate da `report.py` a partire dal CSV. |

M6 è il punto di rischio tecnico: se la rasterizzazione del vettoriale non si allinea, tutto E2 è compromesso. Verificare visivamente prima di procedere.

---

## 11. Fuori scope

- Persistenza su PostGIS/PostgreSQL, API, GUI, viewer, Foliarium
- OCR dei numeri di particella
- Linking particella ↔ partita
- Mosaicatura di più fogli, tiling, gestione di immagini oltre i ~2000 px per lato
- Fine-tuning o training di modelli deep (LoFTR si usa pretrained o non si usa)
- Studi con utenti, misura del tempo risparmiato all'operatore
- Docker, CI, packaging

Materiale interessante ma da tesi: annotare in `IDEE_TESI.md` e proseguire.

---

## 12. Relazione

La traccia chiede: *"a relation is requested with the modality of use of the application"*.

1. Problema: cos'è un Originale di Impianto, perché registrarlo è difficile (dominio visivo, degrado, deformazione della carta)
2. Dati: foglio 49 Varazze, ritagli, vettoriale moderno
3. **Ground truth dal world file**: la composizione analitica, e la sua incertezza dichiarata (0.56 m medi, 1.28 m max, 76 coppie omologhe)
4. Pipeline
5. Preprocessing: Otsu vs Sauvola vs CLAHE, effetto della morfologia — con immagini
6. Matching: SIFT, ORB, ratio test; RANSAC e modelli di trasformazione
7. E1: risultati sintetici, curva RMSE vs degradazione
8. E2: risultati cross-domain — **incluso il fallimento, se c'è, con l'analisi del perché** (line drawings privi di texture, descrittori a blob)
9. E3: confronto con LoFTR (solo se modulo B)
10. **Modalità d'uso**: tutte le opzioni CLI con esempi eseguibili. La traccia lo chiede esplicitamente, non è un'appendice
11. Limiti e sviluppi

Un progetto che misura e spiega perché i descrittori classici cedono sul cross-domain vale più di uno che mostra solo il caso riuscito. Ma serve E1 a dimostrare che la pipeline è corretta, altrimenti "non funziona" è indistinguibile da "è scritto male".
