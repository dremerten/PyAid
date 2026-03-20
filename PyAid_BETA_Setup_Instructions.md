# PyAid Beta Tester Setup Instructions

This package is for testers only. You only need the files included in this bundle:
- `pyaid-<version>.vsix`
- `PyAid_BETA_Setup_Instructions.md`
- `pyaid-beta-onboarding.sh`
- `pyaid-beta-onboarding.ps1`

## 1) Install the extension from VSIX

### VS Code UI
1. Open VS Code
2. Open Extensions panel
3. Click `...` (top-right)
4. Click **Install from VSIX...**
5. Select `pyaid-<version>.vsix`

### VS Code CLI
```bash
code --install-extension /absolute/path/to/pyaid-<version>.vsix --force
```

## 2) Run local Ollama onboarding (recommended)

The onboarding script prompts for permission before each change. It can:
- install Ollama if missing
- ensure Ollama is running
- create/update `~/.pyaid-endpoint`
- pull `gemma3:4b`

### macOS / Linux
```bash
chmod +x ./pyaid-beta-onboarding.sh
./pyaid-beta-onboarding.sh
```

### Windows (PowerShell)
```powershell
Set-ExecutionPolicy -Scope Process Bypass
./pyaid-beta-onboarding.ps1
```

## 3) Configure PyAid in VS Code

Recommended values:
- `pyaid.ollamaEndpoint`: value from `~/.pyaid-endpoint`
- `pyaid.model`: `gemma3:4b`

## 4) Smoke test

1. Open a Python file
2. Open the PyAid panel
3. Ask a question
4. Click **Explain this function/method definition**
5. Verify the response appears in the same session

## 5) Troubleshooting

- If no response appears, ensure Ollama is running locally.
- If model is missing, run `ollama pull gemma3:4b`.
- If VSIX install does not update, reinstall with `--force`.
