param(
  [string]$Workspace = ".",
  [string]$Model = "gemma4:latest",
  [string]$ProviderBaseUrl = "http://localhost:11434/v1",
  [string]$OutputDir = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputDir = Join-Path $PSScriptRoot "..\tmp\hf-benchmark-$stamp"
}

$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$hLog = Join-Path $OutputDir "h.jsonl"
$fLog = Join-Path $OutputDir "f.jsonl"
$summaryPath = Join-Path $OutputDir "summary.json"

$hToken = "H_GEMMA4_OK"
$fToken = "F_GEMMA4_OK"

$hPrompt = "Prueba H: Ejecuta primero iq fsm state --json y responde exactamente $hToken"
$fPrompt = "Prueba F: Ejecuta primero iq fsm state --json y responde exactamente $fToken"

function Invoke-CopilotRun {
  param(
    [string]$ModeName,
    [string]$Prompt,
    [string]$Token,
    [string]$LogPath,
    [switch]$UseInquiryAgent
  )

  $env:COPILOT_PROVIDER_BASE_URL = $ProviderBaseUrl
  $env:COPILOT_MODEL = $Model
  $env:COPILOT_OFFLINE = "true"

  $args = @(
    "-C", $Workspace,
    "--name", "benchmark-$ModeName",
    "--model", $Model,
    "--allow-all-tools",
    "-p", $Prompt,
    "--output-format", "json",
    "-s"
  )

  if ($UseInquiryAgent) {
    $args = @("-C", $Workspace, "--agent", "inquiry") + $args[2..($args.Count - 1)]
  }

  & copilot @args | Tee-Object -FilePath $LogPath | Out-Null
  $exitCode = $LASTEXITCODE

  $text = Get-Content -Raw -Path $LogPath
  $tokenPattern = [regex]::Escape($Token)
  $modelPattern = [regex]::Escape('"model":"' + $Model + '"')

  $hasToken = $text -match $tokenPattern
  $hasExactMessage = $text -match ('"content":"' + $tokenPattern + '"')
  $hasStateCommand = $text -match [regex]::Escape("iq fsm state --json")
  $hasModel = $text -match $modelPattern

  $resultObj = [pscustomobject]@{
    mode = $ModeName
    exitCode = $exitCode
    modelSeen = $hasModel
    stateCommandSeen = $hasStateCommand
    tokenSeen = $hasToken
    exactTokenMessageSeen = $hasExactMessage
    passed = ($exitCode -eq 0 -and $hasModel -and $hasStateCommand -and $hasToken)
    strictLiteralPassed = ($exitCode -eq 0 -and $hasExactMessage)
    logPath = $LogPath
  }

  return $resultObj
}

Write-Host "Running H benchmark (Inquiry methodology)..."
$hResult = Invoke-CopilotRun -ModeName "h" -Prompt $hPrompt -Token $hToken -LogPath $hLog -UseInquiryAgent

Write-Host "Running F benchmark (freestyle)..."
$fResult = Invoke-CopilotRun -ModeName "f" -Prompt $fPrompt -Token $fToken -LogPath $fLog

$summary = [pscustomobject]@{
  generatedAt = (Get-Date).ToString("o")
  workspace = (Resolve-Path $Workspace).Path
  model = $Model
  providerBaseUrl = $ProviderBaseUrl
  results = @($hResult, $fResult)
}

$summary | ConvertTo-Json -Depth 6 | Set-Content -Path $summaryPath -Encoding UTF8

Write-Host ""
Write-Host "Benchmark summary"
$summary.results | Format-Table mode, exitCode, modelSeen, stateCommandSeen, tokenSeen, exactTokenMessageSeen, passed, strictLiteralPassed -AutoSize
Write-Host ""
Write-Host "Summary JSON: $summaryPath"
Write-Host "H log: $hLog"
Write-Host "F log: $fLog"
