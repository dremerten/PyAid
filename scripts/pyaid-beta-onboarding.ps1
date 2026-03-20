param(
  [string]$Model = "gemma3:4b"
)

$ErrorActionPreference = "Stop"
$EndpointFile = Join-Path $HOME ".pyaid-endpoint"

function Confirm-Action {
  param(
    [Parameter(Mandatory = $true)][string]$Prompt,
    [bool]$DefaultYes = $false
  )

  while ($true) {
    $suffix = if ($DefaultYes) { "[Y/n]" } else { "[y/N]" }
    $reply = Read-Host "$Prompt $suffix"

    if ([string]::IsNullOrWhiteSpace($reply)) {
      return $DefaultYes
    }

    switch ($reply.ToLowerInvariant()) {
      "y" { return $true }
      "yes" { return $true }
      "n" { return $false }
      "no" { return $false }
      default { Write-Host "Please answer y or n." }
    }
  }
}

function Test-OllamaRunning {
  try {
    ollama list | Out-Null
    return $true
  } catch {
    return $false
  }
}

function Test-Endpoint {
  param([Parameter(Mandatory = $true)][string]$Url)
  try {
    Invoke-WebRequest -Uri "$Url/api/tags" -UseBasicParsing -TimeoutSec 3 | Out-Null
    return $true
  } catch {
    return $false
  }
}

Write-Host "PyAid beta onboarding (Windows)"
Write-Host "This script prompts before each change."

$ollamaInstalled = $null -ne (Get-Command ollama -ErrorAction SilentlyContinue)
if (-not $ollamaInstalled) {
  Write-Host "Ollama is not installed."
  if (Confirm-Action -Prompt "Install Ollama now using PowerShell installer?" -DefaultYes $true) {
    irm https://ollama.com/install.ps1 | iex
  } else {
    Write-Error "Cannot continue without Ollama."
  }
}

$ollamaInstalled = $null -ne (Get-Command ollama -ErrorAction SilentlyContinue)
if (-not $ollamaInstalled) {
  throw "Ollama command is still unavailable after install attempt. Open a new terminal and rerun."
}

if (-not (Test-OllamaRunning)) {
  Write-Host "Ollama is installed but not currently responding."
  if (Confirm-Action -Prompt "Start Ollama now (background 'ollama serve')?" -DefaultYes $true) {
    Start-Process -FilePath "ollama" -ArgumentList "serve" -WindowStyle Hidden | Out-Null
    Start-Sleep -Seconds 2
    if (-not (Test-OllamaRunning)) {
      Write-Warning "Could not verify Ollama startup yet."
    } else {
      Write-Host "Ollama started successfully."
    }
  } else {
    Write-Host "Skipping Ollama startup by user choice."
  }
} else {
  Write-Host "Ollama is already running."
}

$endpoint = "http://127.0.0.1:11434"
if (Test-Endpoint -Url "http://localhost:11434") {
  $endpoint = "http://localhost:11434"
}
if (Test-Endpoint -Url "http://127.0.0.1:11434") {
  $endpoint = "http://127.0.0.1:11434"
}

if (Test-Path $EndpointFile) {
  Write-Host "Found existing endpoint file: $EndpointFile"
  if (Confirm-Action -Prompt "Update it to '$endpoint'?" -DefaultYes $false) {
    Set-Content -Path $EndpointFile -Value $endpoint -NoNewline
    Write-Host "Updated $EndpointFile"
  } else {
    Write-Host "Kept existing $EndpointFile"
  }
} else {
  if (Confirm-Action -Prompt "Create $EndpointFile with '$endpoint'?" -DefaultYes $true) {
    Set-Content -Path $EndpointFile -Value $endpoint -NoNewline
    Write-Host "Created $EndpointFile"
  } else {
    Write-Host "Skipped endpoint file creation."
  }
}

if (Test-OllamaRunning) {
  if (Confirm-Action -Prompt "Pull model '$Model' now?" -DefaultYes $true) {
    ollama pull $Model
  } else {
    Write-Host "Skipped model pull."
  }
} else {
  Write-Host "Skipping model pull because Ollama is not responding."
}

Write-Host ""
Write-Host "Setup complete."
Write-Host "Endpoint file: $EndpointFile"
Write-Host "Recommended VS Code settings:"
Write-Host "- pyaid.ollamaEndpoint = $(if (Test-Path $EndpointFile) { Get-Content $EndpointFile -Raw } else { 'http://127.0.0.1:11434' })"
Write-Host "- pyaid.model = $Model"
