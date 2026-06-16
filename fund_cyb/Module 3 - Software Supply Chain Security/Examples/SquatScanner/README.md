# 🐍 Typosquatting Scanner for PyPI

This Python program generates typo variants of a given Python package name and analyzes them for suspicious metadata patterns on [PyPI](https://pypi.org). Its goal is to help identify potential [typosquatting](https://en.wikipedia.org/wiki/Typosquatting) packages that may impersonate popular ones.

## 🔍 Features

- Generates typo variants (edit distance 1) via:
  - Single-character deletion
  - Single-character substitution
  - Single-character insertion
- Optionally attempts to install each variant with `pip`
- Analyzes each existing package's PyPI metadata for **red flags**, such as:
  - Missing/placeholder descriptions
  - Suspicious author email or homepage URLs
  - Use of obscure or suspicious top-level domains (e.g., `.xyz`, `.ru`)
  - Very recent creation or only one release
  - Unexpected or excessive dependencies

## 📦 Example Target

By default, the program mutates and analyzes the package:

```
pandas
```

## 🛠️ Installation

### Prerequisites

- Python 3.7+

### Install dependencies

```bash
pip install -r requirements.txt
```

## ▶️ Usage

Run the program directly:

```bash
python typosquat_scanner.py
```

It will:
1. Generate typo variants of the `pandas` package.
2. Query PyPI to check if each variant exists.
3. Analyze its metadata and print any red flags.

## 🧠 Red Flag Heuristics

The analysis reports potential issues such as:

- Missing or placeholder description/summary
- Malformed or generic author emails
- Suspicious domains (e.g., `.ru`, `.xyz`, shorteners like `bit.ly`)
- Homepage/project URLs missing or malformed
- Only one release or uploaded very recently
- Suspicious dependencies (e.g., `cryptography`, `pyinstaller`)

These heuristics are commonly found in packages used for supply chain attacks.

## ⚠️ Disclaimer

- This tool does not conclusively identify malware or malicious packages.
- It is meant for research, auditing, or educational purposes.
- Use responsibly and report suspicious packages to [PyPI security](https://pypi.org/security/).

## 📄 License

MIT License. See `LICENSE` file (if provided).
