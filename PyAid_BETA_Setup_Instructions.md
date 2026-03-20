# PyAid Beta Setup Instructions

This guide explains how to package PyAid as a `.vsix`, share it, install it in VS Code, and run a guided local Ollama setup quickly.

## 1) Create the beta package (`.vsix`)

From the repository root:

```bash
./scripts/package-beta-vsix.sh
```

The script will:
- install extension dependencies (if needed)
- build the extension
- create a `.vsix` package
- print the output file path

Expected output location:

```text
extension/pyaid-<version>.vsix
```

## 2) Share the package

Share the generated `.vsix` file with testers (Drive, Slack, email, etc.).

## 3) Install the package in VS Code (tester steps)

### Option A: VS Code UI
1. Open VS Code
2. Open Extensions panel
3. Click `...` (top-right)
4. Click **Install from VSIX...**
5. Select the `pyaid-<version>.vsix` file

### Option B: VS Code CLI

```bash
code --install-extension /absolute/path/to/pyaid-<version>.vsix
```

If updating an existing beta install:

```bash
code --install-extension /absolute/path/to/pyaid-<version>.vsix --force
```

## 4) Run the guided Ollama setup (recommended)

These scripts prompt for permission at every step and can:
- install Ollama if missing
- start Ollama if not running
- create/update `~/.pyaid-endpoint`
- pull `gemma3:4b`

### macOS / Linux

```bash
chmod +x ./scripts/pyaid-beta-onboarding.sh
./scripts/pyaid-beta-onboarding.sh
```

### Windows (PowerShell)

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./scripts/pyaid-beta-onboarding.ps1
```

## 5) What the onboarding scripts do

1. Check whether Ollama is installed
2. If missing, ask permission to install:
   - macOS/Linux: `curl -fsSL https://ollama.com/install.sh | sh`
   - Windows: `irm https://ollama.com/install.ps1 | iex`
3. Ensure Ollama is running
4. Check/create `~/.pyaid-endpoint` using `http://127.0.0.1:11434` or `http://localhost:11434`
5. Ask permission to pull `gemma3:4b`

## 6) Recommended VS Code settings after setup

- `pyaid.ollamaEndpoint`: value from `~/.pyaid-endpoint`
- `pyaid.model`: `gemma3:4b`

## 7) Quick smoke test after install

1. Open a Python file
2. Click the PyAid status bar button
3. Ask a question in the PyAid panel
4. Click "Explain this function/method definition" on a function
5. Confirm responses appear in the same PyAid session

## 8) Troubleshooting

- If no response appears, ensure Ollama is running locally.
- If model not found, run `ollama list` and update `pyaid.model`.
- If a new beta version does not replace the old one, reinstall with `--force`.
