#!/usr/bin/env bash
set -euo pipefail

MODEL_DEFAULT="gemma3:4b"
ENDPOINT_FILE="${HOME}/.pyaid-endpoint"

prompt_yes_no() {
  local prompt="$1"
  local default_answer="${2:-N}"
  local reply
  while true; do
    if [[ "$default_answer" == "Y" ]]; then
      read -r -p "$prompt [Y/n]: " reply || true
      reply="${reply:-Y}"
    else
      read -r -p "$prompt [y/N]: " reply || true
      reply="${reply:-N}"
    fi
    case "${reply}" in
      Y|y|yes|YES) return 0 ;;
      N|n|no|NO) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

check_command() {
  command -v "$1" >/dev/null 2>&1
}

install_ollama_unix() {
  echo "Installing Ollama..."
  curl -fsSL https://ollama.com/install.sh | sh
}

wait_for_ollama() {
  local retries=20
  local i
  for i in $(seq 1 "$retries"); do
    if ollama list >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done
  return 1
}

ensure_ollama_running() {
  if ollama list >/dev/null 2>&1; then
    echo "Ollama is already running."
    return 0
  fi

  echo "Ollama is installed but not currently responding."
  if prompt_yes_no "Start Ollama now (background 'ollama serve')?" "Y"; then
    nohup ollama serve >/tmp/pyaid-ollama.log 2>&1 &
    if wait_for_ollama; then
      echo "Ollama started successfully."
      return 0
    fi
    echo "Could not verify Ollama startup. See /tmp/pyaid-ollama.log"
    return 1
  fi

  echo "Skipping Ollama startup by user choice."
  return 1
}

pick_endpoint() {
  if curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "http://127.0.0.1:11434"
    return 0
  fi
  if curl -fsS http://localhost:11434/api/tags >/dev/null 2>&1; then
    echo "http://localhost:11434"
    return 0
  fi
  echo "http://127.0.0.1:11434"
}

create_or_update_endpoint_file() {
  local endpoint
  endpoint="$(pick_endpoint)"

  if [[ -f "$ENDPOINT_FILE" ]]; then
    echo "Found existing endpoint file: $ENDPOINT_FILE"
    if prompt_yes_no "Update it to '$endpoint'?" "N"; then
      printf "%s\n" "$endpoint" > "$ENDPOINT_FILE"
      echo "Updated $ENDPOINT_FILE"
    else
      echo "Kept existing $ENDPOINT_FILE"
    fi
  else
    if prompt_yes_no "Create $ENDPOINT_FILE with '$endpoint'?" "Y"; then
      printf "%s\n" "$endpoint" > "$ENDPOINT_FILE"
      echo "Created $ENDPOINT_FILE"
    else
      echo "Skipped endpoint file creation."
    fi
  fi
}

pull_model() {
  local model="$1"
  if prompt_yes_no "Pull model '$model' now?" "Y"; then
    ollama pull "$model"
  else
    echo "Skipped model pull."
  fi
}

main() {
  local os_name
  os_name="$(uname -s)"

  case "$os_name" in
    Darwin|Linux) ;;
    *)
      echo "This script supports macOS and Linux only."
      echo "For Windows, run: scripts/pyaid-beta-onboarding.ps1"
      exit 1
      ;;
  esac

  echo "PyAid beta onboarding (macOS/Linux)"
  echo "This script will prompt before every change."

  if check_command ollama; then
    echo "Ollama is already installed."
  else
    echo "Ollama is not installed."
    if prompt_yes_no "Install Ollama now using curl installer?" "Y"; then
      install_ollama_unix
    else
      echo "Cannot continue without Ollama."
      exit 1
    fi
  fi

  if ! check_command ollama; then
    echo "Ollama command is still unavailable after install attempt."
    echo "Please open a new terminal and rerun this script."
    exit 1
  fi

  ensure_ollama_running || true
  create_or_update_endpoint_file

  if ollama list >/dev/null 2>&1; then
    pull_model "$MODEL_DEFAULT"
  else
    echo "Skipping model pull because Ollama is not responding."
  fi

  echo ""
  echo "Setup complete."
  echo "Endpoint file: $ENDPOINT_FILE"
  echo "Recommended VS Code settings:"
  echo "- pyaid.ollamaEndpoint = $(cat "$ENDPOINT_FILE" 2>/dev/null || echo "http://127.0.0.1:11434")"
  echo "- pyaid.model = $MODEL_DEFAULT"
}

main "$@"
