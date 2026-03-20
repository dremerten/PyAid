# PyAid (VS Code extension)

<p align="center">
  <img src="./extension/media/pyaid.png" alt="PyAid" width="120" />
</p>

AI-powered Python guidance at your fingertips. Local-first VS Code helper that explains code and answers questions using your own Ollama models. It shows results in hovers and a side panel with a single click.

## Screenshot

![PyAid extension screenshot](./extension/media/Screenshot%20from%202026-03-20%2013-32-24.png)

*PyAid running side-by-side with the active file: persistent chat sessions, inline explain flow, and local-model responses in one panel.*

## Quick start (local, Ollama)

1) Install prerequisites: Node 18+, npm, VS Code, and [Ollama](https://ollama.com).  
2) Pull a small model (default the extension expects):  
   ```bash
   ollama pull gemma3:1b
   ```  
   (Swap in your preferred model and update `pyaid.model` in settings if desired.)
3) Use Node 24.14.0 (run `nvm use 24.14.0` if you have nvm; see `.nvmrc`).  
4) Install dependencies and build the extension:  
   ```bash
   npm install
   npm run build
   ```
5) Launch in VS Code for debugging: press `F5` (Run → Start Debugging) to open the Extension Development Host.  
6) Use it: hover or click the status bar “Ask AI” button; the side panel will show the answer from your local model.

## Configuration (VS Code settings)
- `pyaid.ollamaEndpoint`: Ollama URL (default `http://localhost:11434`).  
- `pyaid.model`: Model name to use (default `gemma3:1b`).  
- Other UI toggles live under the `pyaid.prototype.*` settings.
