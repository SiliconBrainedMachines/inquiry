param(
  [string]$Workspace = ".",
  [string]$Model = "gemma4:latest",
  [string]$ProviderBaseUrl = "http://localhost:11434/v1",
  [int]$IssueNumber = 242,
  [string]$BranchName = "",
  [string]$OutputDir = "",
  [int]$RunTimeoutSec = 600,
  [int]$RunTimeoutSecH = 0,
  [int]$RunTimeoutSecF = 0,
  [switch]$NonInteractiveBenchmark,
  [switch]$GradeTests
)

$ErrorActionPreference = "Stop"

# --- Verifiable-artifact grading (#246) -------------------------------------
# These grade what the cycle PRODUCED (reopenable evidence, executable plan
# checks, a green suite) rather than only that the flow moved. Same handle
# definitions as the ANALYZE/PLAN gates (#244/#245).

function Test-EvidenceVerifiable {
  param([string]$DiagnosisPath)
  if (-not (Test-Path $DiagnosisPath)) { return $false }
  $inEvidence = $false
  $bullets = @()
  foreach ($line in (Get-Content -Path $DiagnosisPath)) {
    if ($line -match '^##?\s+Evidence\b') { $inEvidence = $true; continue }
    if ($inEvidence -and $line -match '^#{1,6}\s') { break }
    if ($inEvidence) {
      $t = $line.Trim()
      if ($t -match '^[-*]\s+') { $bullets += ($t -replace '^[-*]\s+', '') }
    }
  }
  if ($bullets.Count -eq 0) { return $false }
  $handle = '(https?://|[\w./\\-]+\.[A-Za-z0-9]+:\d+|`[^`]+`)'
  foreach ($b in $bullets) { if ($b -notmatch $handle) { return $false } }
  return $true
}

function Test-PlanExecutable {
  param([string]$PlanPath)
  if (-not (Test-Path $PlanPath)) { return $false }
  $lines = Get-Content -Path $PlanPath
  $phaseCount = ($lines | Where-Object { $_ -match '^#{2,4}\s+.*\bphase\b' }).Count
  $runner = '`[^`]*\b(dart test|flutter test|npm (test|run)|pytest|go test|cargo test|mocha|jest)\b[^`]*`'
  $testFile = '(_test\.\w+|\.test\.\w+|_spec\.\w+|(^|[\s/`])test/)'
  $handleCount = ($lines | Where-Object { $_ -match $runner -or $_ -match $testFile }).Count
  if ($handleCount -eq 0) { return $false }
  return ($handleCount -ge $phaseCount)
}

function Test-SuiteGreen {
  param([string]$CliRoot)
  try {
    Push-Location $CliRoot
    $out = & dart test 2>&1 | Out-String
    return ($out -match 'All tests passed!')
  } catch { return $false }
  finally { Pop-Location }
}

function Invoke-GhJson {
  param(
    [string[]]$Arguments
  )

  $raw = & gh @Arguments
  if ($LASTEXITCODE -ne 0) {
    throw "gh $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
  }

  return $raw | ConvertFrom-Json
}

function Get-Slug {
  param([string]$Text)

  $slug = $Text.ToLowerInvariant()
  $slug = $slug -replace '[^a-z0-9]+', '-'
  $slug = $slug -replace '-{2,}', '-'
  $slug = $slug.Trim('-')
  if ($slug.Length -gt 50) {
    $slug = $slug.Substring(0, 50).Trim('-')
  }

  return $slug
}

function Count-LinesMatching {
  param(
    [string]$Path,
    [string]$Pattern
  )

  return (Get-Content -Path $Path | Where-Object { $_ -match $Pattern }).Count
}

function Get-LastJsonLine {
  param(
    [string]$Path,
    [string]$Pattern
  )

  $line = Get-Content -Path $Path | Where-Object { $_ -match $Pattern } | Select-Object -Last 1
  if ($null -eq $line) {
    return $null
  }

  return $line | ConvertFrom-Json
}

function Test-StateSeen {
  param(
    [string]$Text,
    [string]$StateName
  )

  $rawPattern = '"state"\s*:\s*"' + [regex]::Escape($StateName) + '"'
  $escapedPattern = '\\"state\\"\s*:\s*\\"' + [regex]::Escape($StateName) + '\\"'
  return (($Text -match $rawPattern) -or ($Text -match $escapedPattern))
}

function Get-RegexMatchCount {
  param(
    [string]$Text,
    [string]$Pattern
  )

  if ([string]::IsNullOrEmpty($Text)) {
    return 0
  }

  return ([regex]::Matches($Text, $Pattern)).Count
}

function Get-StateEvidenceFromText {
  param(
    [string]$Text
  )

  $stateNames = @('IDLE', 'ANALYZE', 'PLAN', 'EXECUTE', 'END', 'EVOLUTION')
  $evidence = @{}

  foreach ($stateName in $stateNames) {
    $escapedState = [regex]::Escape($stateName)

    $stateRaw = '"state"\s*:\s*"' + $escapedState + '"'
    $stateEscaped = '\\"state\\"\s*:\s*\\"' + $escapedState + '\\"'
    $stateYaml = '\bstate\s*:\s*' + $escapedState + '\b'
    $phaseRaw = '"phase"\s*:\s*"' + $escapedState + '"'
    $phaseEscaped = '\\"phase\\"\s*:\s*\\"' + $escapedState + '\\"'
    $phaseYaml = '\bphase\s*:\s*' + $escapedState + '\b'
    $fromStateRaw = '"from_state"\s*:\s*"' + $escapedState + '"'
    $fromStateEscaped = '\\"from_state\\"\s*:\s*\\"' + $escapedState + '\\"'
    $fromStateYaml = '\bfrom_state\s*:\s*' + $escapedState + '\b'

    $stateFieldMatches = (Get-RegexMatchCount -Text $Text -Pattern $stateRaw) + (Get-RegexMatchCount -Text $Text -Pattern $stateEscaped) + (Get-RegexMatchCount -Text $Text -Pattern $stateYaml)
    $phaseFieldMatches = (Get-RegexMatchCount -Text $Text -Pattern $phaseRaw) + (Get-RegexMatchCount -Text $Text -Pattern $phaseEscaped) + (Get-RegexMatchCount -Text $Text -Pattern $phaseYaml)
    $fromStateFieldMatches = (Get-RegexMatchCount -Text $Text -Pattern $fromStateRaw) + (Get-RegexMatchCount -Text $Text -Pattern $fromStateEscaped) + (Get-RegexMatchCount -Text $Text -Pattern $fromStateYaml)

    $evidence[$stateName] = [pscustomobject]@{
      reached = (($stateFieldMatches + $phaseFieldMatches + $fromStateFieldMatches) -gt 0)
      stateFieldMatches = $stateFieldMatches
      phaseFieldMatches = $phaseFieldMatches
      fromStateFieldMatches = $fromStateFieldMatches
    }
  }

  return $evidence
}

function Get-TargetEventsForState {
  param(
    [string]$StateName
  )

  switch ($StateName) {
    'IDLE' { return @('close_issue') }
    'ANALYZE' { return @('start_analyze') }
    'PLAN' { return @('complete_analysis') }
    'EXECUTE' { return @('complete_plan') }
    'END' { return @('complete_execution') }
    'EVOLUTION' { return @('block') }
    default { return @() }
  }
}

function Get-TransitionEvidenceFromText {
  param(
    [string]$Text
  )

  $stateNames = @('IDLE', 'ANALYZE', 'PLAN', 'EXECUTE', 'END', 'EVOLUTION')
  $evidence = @{}

  foreach ($stateName in $stateNames) {
    $escapedState = [regex]::Escape($stateName)

    $toStateRaw = '"to_state"\s*:\s*"' + $escapedState + '"'
    $toStateEscaped = '\\"to_state\\"\s*:\s*\\"' + $escapedState + '\\"'
    $toStateYaml = '\bto_state\s*:\s*' + $escapedState + '\b'

    $toStateMatches = (Get-RegexMatchCount -Text $Text -Pattern $toStateRaw) + (Get-RegexMatchCount -Text $Text -Pattern $toStateEscaped) + (Get-RegexMatchCount -Text $Text -Pattern $toStateYaml)

    $eventMatches = 0
    $eventWithOutcomeMatches = 0
    foreach ($eventName in (Get-TargetEventsForState -StateName $stateName)) {
      $escapedEvent = [regex]::Escape($eventName)
      $eventRaw = '"event"\s*:\s*"' + $escapedEvent + '"'
      $eventEscaped = '\\"event\\"\s*:\s*\\"' + $escapedEvent + '\\"'
      $eventCommand = 'iq\s+fsm\s+transition\s+--event\s+' + $escapedEvent + '\b'

      $eventMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventRaw)
      $eventMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventEscaped)
      $eventMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventCommand)

      # Require the transition event and an allowed/success outcome in the same line.
      $eventWithAllowedRaw = '(?m)^.*"event"\s*:\s*"' + $escapedEvent + '".*"outcome"\s*:\s*"(?:allowed|success|succeeded|completed)".*$'
      $eventWithAllowedEscaped = '(?m)^.*\\"event\\"\s*:\s*\\"' + $escapedEvent + '\\".*\\"outcome\\"\s*:\s*\\"(?:allowed|success|succeeded|completed)\\".*$'
      $eventWithAllowedCommand = '(?mi)^.*iq\s+fsm\s+transition\s+--event\s+' + $escapedEvent + '\b.*(?:allowed|success|succeeded|completed).*$'

      $eventWithOutcomeMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventWithAllowedRaw)
      $eventWithOutcomeMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventWithAllowedEscaped)
      $eventWithOutcomeMatches += (Get-RegexMatchCount -Text $Text -Pattern $eventWithAllowedCommand)
    }

    $evidence[$stateName] = [pscustomobject]@{
      reached = (($toStateMatches + $eventMatches + $eventWithOutcomeMatches) -gt 0)
      toStateFieldMatches = $toStateMatches
      transitionEventMatches = $eventMatches
      transitionAllowedOutcomeMatches = $eventWithOutcomeMatches
    }
  }

  return $evidence
}

function Test-StateReachedSemantically {
  param(
    [string]$StateName,
    [bool]$StructuredSeen,
    $TextEvidence,
    $TransitionEvidence
  )

  switch ($StateName) {
    'PLAN' {
      return (($TransitionEvidence.transitionAllowedOutcomeMatches -gt 0) -or
              ($TransitionEvidence.toStateFieldMatches -gt 0) -or
              (($TransitionEvidence.transitionEventMatches -gt 0) -and $StructuredSeen))
    }
    'EXECUTE' {
      return (($TransitionEvidence.transitionAllowedOutcomeMatches -gt 0) -or
              ($TransitionEvidence.toStateFieldMatches -gt 0) -or
              (($TransitionEvidence.transitionEventMatches -gt 0) -and $StructuredSeen))
    }
    'END' {
      return (($TransitionEvidence.transitionAllowedOutcomeMatches -gt 0) -or
              ($TransitionEvidence.toStateFieldMatches -gt 0) -or
              (($TransitionEvidence.transitionEventMatches -gt 0) -and $StructuredSeen))
    }
    default {
      return ($StructuredSeen -or $TextEvidence.reached -or $TransitionEvidence.reached)
    }
  }
}

function Find-StateValues {
  param(
    $Node,
    [hashtable]$Signals
  )

  if ($null -eq $Node) {
    return
  }

  if ($Node -is [System.Collections.IDictionary]) {
    foreach ($key in $Node.Keys) {
      $value = $Node[$key]
      if (($key -eq 'state' -or $key -eq 'phase' -or $key -eq 'from_state' -or $key -eq 'to_state') -and $value -is [string] -and $Signals.ContainsKey($value)) {
        $Signals[$value] = $true
      }
      Find-StateValues -Node $value -Signals $Signals
    }
    return
  }

  if ($Node -is [psobject] -and $Node.PSObject.Properties.Count -gt 0) {
    foreach ($prop in $Node.PSObject.Properties) {
      $name = $prop.Name
      $value = $prop.Value
      if (($name -eq 'state' -or $name -eq 'phase' -or $name -eq 'from_state' -or $name -eq 'to_state') -and $value -is [string] -and $Signals.ContainsKey($value)) {
        $Signals[$value] = $true
      }
      Find-StateValues -Node $value -Signals $Signals
    }
    return
  }

  if ($Node -is [System.Collections.IEnumerable] -and -not ($Node -is [string])) {
    foreach ($item in $Node) {
      Find-StateValues -Node $item -Signals $Signals
    }
  }
}

function Get-StateSignalsFromJsonl {
  param(
    [string]$Path
  )

  $signals = @{
    IDLE = $false
    ANALYZE = $false
    PLAN = $false
    EXECUTE = $false
    END = $false
    EVOLUTION = $false
  }

  if (-not (Test-Path $Path)) {
    return $signals
  }

  foreach ($line in Get-Content -Path $Path) {
    if ([string]::IsNullOrWhiteSpace($line)) {
      continue
    }

    try {
      $obj = $line | ConvertFrom-Json -ErrorAction Stop
      Find-StateValues -Node $obj -Signals $signals
    } catch {
      # Ignore non-JSON or partial lines.
    }
  }

  return $signals
}

if ([string]::IsNullOrWhiteSpace($BranchName)) {
  $BranchName = (git -C $Workspace branch --show-current).Trim()
}

$issue = Invoke-GhJson -Arguments @('issue', 'view', "$IssueNumber", '--json', 'number,title,state,url')
if ($issue.state -ne 'OPEN') {
  throw "Issue #$IssueNumber must be OPEN for the benchmark"
}

$issueSlug = Get-Slug -Text $issue.title

if ([string]::IsNullOrWhiteSpace($OutputDir)) {
  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $OutputDir = Join-Path $PSScriptRoot "..\tmp\fullflow-hf-$stamp"
}

$OutputDir = [System.IO.Path]::GetFullPath($OutputDir)
New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null

$cleanroomDir = Join-Path (Resolve-Path $Workspace).Path ("cleanrooms/{0}/analyze" -f $BranchName)
New-Item -ItemType Directory -Path $cleanroomDir -Force | Out-Null

function Ensure-BenchmarkDiagnosisEvidence {
  param(
    [string]$DiagnosisPath,
    [int]$Issue,
    [string]$Branch,
    [string]$StateName
  )

  if (-not (Test-Path $DiagnosisPath)) {
    return
  }

  $content = Get-Content -Path $DiagnosisPath -Raw
  if ($content -match 'Record observed repo, artifact, test, runtime, or research evidence here\.') {
    $evidenceLine = "- Observed benchmark context in repository: issue #$Issue on branch $Branch with FSM state $StateName at $(Get-Date -Format o)."
    $updated = $content -replace '(-\s*Record observed repo, artifact, test, runtime, or research evidence here\.)', $evidenceLine
    Set-Content -Path $DiagnosisPath -Value $updated -Encoding UTF8
  }
}

$indexPath = Join-Path $cleanroomDir "index.md"
if (-not (Test-Path $indexPath)) {
  @"
# Analyze Phase - Index

**Issue:** #$IssueNumber - $($issue.title)
**Branch:** $BranchName
**Phase:** ANALYZE
**Status:** In progress

---

## Documents

| # | File | Description |
|---|------|-------------|
"@
| Set-Content -Path $indexPath -Encoding UTF8
}

$stateJson = & iq fsm state --json
if ($LASTEXITCODE -ne 0) {
  throw "iq fsm state --json failed with exit code $LASTEXITCODE"
}

$currentState = $stateJson | ConvertFrom-Json
if ($currentState.state -ne 'ANALYZE' -or $currentState.issue -ne $IssueNumber) {
  Write-Host "Seeding inquiry-start context for issue #$IssueNumber..."
  & iq fsm transition --event start_analyze --issue $IssueNumber
  if ($LASTEXITCODE -ne 0) {
    throw "iq fsm transition --event start_analyze --issue $IssueNumber failed with exit code $LASTEXITCODE"
  }

  $stateJson = & iq fsm state --json
  if ($LASTEXITCODE -ne 0) {
    throw "iq fsm state --json failed with exit code $LASTEXITCODE"
  }
  $currentState = $stateJson | ConvertFrom-Json
}

$diagnosisPath = Join-Path $cleanroomDir 'diagnosis.md'
Ensure-BenchmarkDiagnosisEvidence -DiagnosisPath $diagnosisPath -Issue $IssueNumber -Branch $BranchName -StateName $currentState.state

$hLog = Join-Path $OutputDir "h.jsonl"
$fLog = Join-Path $OutputDir "f.jsonl"
$summaryPath = Join-Path $OutputDir "summary.json"

$hPrompt = @"
Full-flow benchmark H with local gemma4.

Current context:
- issue #${IssueNumber}: $($issue.title)
- branch: $BranchName
- cleanroom: cleanrooms/$BranchName/analyze/
- setup-state: ANALYZE already seeded for this issue
- do not triage, create, or select issues; continue the active inquiry flow from ANALYZE

Task:
Execute the complete Inquiry flow from ANALYZE through PLAN, EXECUTE, and END.
Use only `iq` commands and the active repository evidence.
Keep the flow moving until END is reached.
When the run is complete, respond exactly FULLFLOW_H_OK.
"@

$inquiryAgentInstructionsPath = Join-Path $PSScriptRoot "..\assets\agents\inquiry.agent.md"
if (-not (Test-Path $inquiryAgentInstructionsPath)) {
  throw "Missing inquiry agent instructions at: $inquiryAgentInstructionsPath"
}

$inquiryAgentInstructionsRaw = Get-Content -Path $inquiryAgentInstructionsPath -Raw
$inquiryAgentInstructions = [regex]::Replace($inquiryAgentInstructionsRaw, '^---[\s\S]*?---\s*', '', 'Singleline')

$fPrompt = @"
Full-flow benchmark F with local gemma4.

Current context:
- issue #${IssueNumber}: $($issue.title)
- branch: $BranchName
- cleanroom: cleanrooms/$BranchName/analyze/
- setup-state: ANALYZE already seeded for this issue
- do not triage, create, or select issues; continue the active inquiry flow from ANALYZE

Task:
Attempt the same complete workflow as the H run, but without Inquiry methodology routing.
Use only the repository tools you need to finish the flow through END.
When the run is complete, respond exactly FULLFLOW_F_OK.
"@

if ($RunTimeoutSecH -le 0) {
  $RunTimeoutSecH = $RunTimeoutSec
}

if ($RunTimeoutSecF -le 0) {
  $RunTimeoutSecF = $RunTimeoutSec
}

$hAutoApprovalBlock = ""
if ($NonInteractiveBenchmark) {
  $hAutoApprovalBlock = @"

Benchmark override (non-interactive):
- If completion_authority is user during ANALYZE completion gate, treat this benchmark prompt as explicit user approval.
- Do not wait for a yes/no response from chat.
- Continue with the state transition in the same benchmark run.
"@
}

function Invoke-CopilotRun {
  param(
    [string]$ModeName,
    [string]$Prompt,
    [string]$Token,
    [string]$LogPath,
    [switch]$UseInquiryAgent,
    [string]$InjectedInstructions = "",
    [int]$MaxAttempts = 1,
    [int]$RunTimeoutSec = 600
  )

  $env:COPILOT_PROVIDER_BASE_URL = $ProviderBaseUrl
  $env:COPILOT_MODEL = $Model
  $env:COPILOT_OFFLINE = "true"

  $effectivePrompt = $Prompt
  if ($UseInquiryAgent -and -not [string]::IsNullOrWhiteSpace($InjectedInstructions)) {
    $effectivePrompt = @"
<agent_instructions>
$InjectedInstructions
</agent_instructions>

$Prompt$hAutoApprovalBlock
"@
  }

  $args = @(
    '-C', $Workspace,
    '--name', "fullflow-$ModeName",
    '--model', $Model,
    '--allow-all-tools',
    '-p', $effectivePrompt,
    '--output-format', 'json',
    '-s'
  )

  if ($MaxAttempts -lt 1) {
    $MaxAttempts = 1
  }

  $exitCode = 1
  $text = ""
  $selectedLogPath = $LogPath
  $attempts = @()

  $promptHash = [Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData([System.Text.Encoding]::UTF8.GetBytes($effectivePrompt)))

  for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
    $attemptLogPath = if ($MaxAttempts -eq 1) { $LogPath } else { "$LogPath.attempt$attempt" }
    $attemptCommandPath = "$attemptLogPath.command.txt"
    $attemptStart = Get-Date

    if (Test-Path $attemptLogPath) {
      Remove-Item -Path $attemptLogPath -Force
    }

    @"
mode=$ModeName
attempt=$attempt
workspace=$Workspace
model=$Model
providerBaseUrl=$ProviderBaseUrl
runTimeoutSec=$RunTimeoutSec
promptLength=$($effectivePrompt.Length)
promptSha256=$promptHash
command=copilot -C <workspace> --name fullflow-$ModeName --model <model> --allow-all-tools -p <prompt> --output-format json -s
"@ | Set-Content -Path $attemptCommandPath -Encoding UTF8

    $job = Start-Job -ScriptBlock {
      param($workspaceArg, $modeArg, $modelArg, $providerArg, $promptArg, $logFilePath)

      $env:COPILOT_PROVIDER_BASE_URL = $providerArg
      $env:COPILOT_MODEL = $modelArg
      $env:COPILOT_OFFLINE = 'true'

      & copilot -C $workspaceArg --name "fullflow-$modeArg" --model $modelArg --allow-all-tools -p $promptArg --output-format json -s 2>&1 | Tee-Object -FilePath $logFilePath | Out-Null
      return $LASTEXITCODE
    } -ArgumentList $Workspace, $ModeName, $Model, $ProviderBaseUrl, $effectivePrompt, $attemptLogPath

    $completed = Wait-Job -Job $job -Timeout $RunTimeoutSec
    $timedOut = $false
    if ($null -eq $completed) {
      Stop-Job -Job $job | Out-Null
      Remove-Job -Job $job | Out-Null
      "TIMEOUT: copilot run exceeded ${RunTimeoutSec}s" | Add-Content -Path $attemptLogPath -Encoding UTF8
      $exitCode = 124
      $timedOut = $true
    } else {
      $exitCode = [int](Receive-Job -Job $job)
      Remove-Job -Job $job | Out-Null
    }

    $text = if (Test-Path $attemptLogPath) { (Get-Content -Path $attemptLogPath) -join "`n" } else { "" }
    $attemptEnd = Get-Date

    $selectedLogPath = $attemptLogPath

    $isNilContentTypeError = ($text -match 'invalid message content type:\s*<nil>')
    $shouldRetry = ($attempt -lt $MaxAttempts -and $exitCode -ne 0 -and $isNilContentTypeError)

    $attempts += [pscustomobject]@{
      attempt = $attempt
      start = $attemptStart.ToString('o')
      end = $attemptEnd.ToString('o')
      durationSec = [Math]::Round(($attemptEnd - $attemptStart).TotalSeconds, 2)
      exitCode = $exitCode
      timedOut = $timedOut
      nilContentTypeError = $isNilContentTypeError
      retryTriggered = $shouldRetry
      logPath = $attemptLogPath
      commandPath = $attemptCommandPath
    }

    if (-not $shouldRetry) {
      break
    }

    Write-Host "[$ModeName] Retrying after nil content-type provider error (attempt $attempt/$MaxAttempts)..."
  }

  if ($selectedLogPath -ne $LogPath) {
    Copy-Item -Path $selectedLogPath -Destination $LogPath -Force
  }

  $attemptsMetaPath = "$LogPath.meta.json"
  $attempts | ConvertTo-Json -Depth 6 | Set-Content -Path $attemptsMetaPath -Encoding UTF8

  $resultLine = Get-LastJsonLine -Path $LogPath -Pattern '"type":"result"'

  $structuredSignals = Get-StateSignalsFromJsonl -Path $LogPath

  $textEvidence = Get-StateEvidenceFromText -Text $text
  $transitionEvidence = Get-TransitionEvidenceFromText -Text $text

  $stateSeen = @{
    IDLE = (Test-StateReachedSemantically -StateName 'IDLE' -StructuredSeen $structuredSignals['IDLE'] -TextEvidence $textEvidence['IDLE'] -TransitionEvidence $transitionEvidence['IDLE'])
    ANALYZE = (Test-StateReachedSemantically -StateName 'ANALYZE' -StructuredSeen $structuredSignals['ANALYZE'] -TextEvidence $textEvidence['ANALYZE'] -TransitionEvidence $transitionEvidence['ANALYZE'])
    PLAN = (Test-StateReachedSemantically -StateName 'PLAN' -StructuredSeen $structuredSignals['PLAN'] -TextEvidence $textEvidence['PLAN'] -TransitionEvidence $transitionEvidence['PLAN'])
    EXECUTE = (Test-StateReachedSemantically -StateName 'EXECUTE' -StructuredSeen $structuredSignals['EXECUTE'] -TextEvidence $textEvidence['EXECUTE'] -TransitionEvidence $transitionEvidence['EXECUTE'])
    END = (Test-StateReachedSemantically -StateName 'END' -StructuredSeen $structuredSignals['END'] -TextEvidence $textEvidence['END'] -TransitionEvidence $transitionEvidence['END'])
    EVOLUTION = (Test-StateReachedSemantically -StateName 'EVOLUTION' -StructuredSeen $structuredSignals['EVOLUTION'] -TextEvidence $textEvidence['EVOLUTION'] -TransitionEvidence $transitionEvidence['EVOLUTION'])
  }

  $stateEvidence = [pscustomobject]@{
    IDLE = [pscustomobject]@{
      reached = $stateSeen['IDLE']
      structured = $structuredSignals['IDLE']
      text = $textEvidence['IDLE']
      transition = $transitionEvidence['IDLE']
    }
    ANALYZE = [pscustomobject]@{
      reached = $stateSeen['ANALYZE']
      structured = $structuredSignals['ANALYZE']
      text = $textEvidence['ANALYZE']
      transition = $transitionEvidence['ANALYZE']
    }
    PLAN = [pscustomobject]@{
      reached = $stateSeen['PLAN']
      structured = $structuredSignals['PLAN']
      text = $textEvidence['PLAN']
      transition = $transitionEvidence['PLAN']
    }
    EXECUTE = [pscustomobject]@{
      reached = $stateSeen['EXECUTE']
      structured = $structuredSignals['EXECUTE']
      text = $textEvidence['EXECUTE']
      transition = $transitionEvidence['EXECUTE']
    }
    END = [pscustomobject]@{
      reached = $stateSeen['END']
      structured = $structuredSignals['END']
      text = $textEvidence['END']
      transition = $transitionEvidence['END']
    }
    EVOLUTION = [pscustomobject]@{
      reached = $stateSeen['EVOLUTION']
      structured = $structuredSignals['EVOLUTION']
      text = $textEvidence['EVOLUTION']
      transition = $transitionEvidence['EVOLUTION']
    }
  }

  $toolStarts = Count-LinesMatching -Path $LogPath -Pattern '"type":"tool\.execution_start"'
  $toolCompletes = Count-LinesMatching -Path $LogPath -Pattern '"type":"tool\.execution_complete"'
  $toolCalls = $toolStarts + $toolCompletes

  $resultObject = [pscustomobject]@{
    mode = $ModeName
    exitCode = $exitCode
    modelSeen = ($text -match [regex]::Escape('"model":"' + $Model + '"'))
    stateCommandSeen = ($text -match [regex]::Escape('iq fsm state --json'))
    reachedIDLE = $stateSeen['IDLE']
    reachedANALYZE = $stateSeen['ANALYZE']
    reachedPLAN = $stateSeen['PLAN']
    reachedEXECUTE = $stateSeen['EXECUTE']
    reachedEND = $stateSeen['END']
    reachedEVOLUTION = $stateSeen['EVOLUTION']
    stateEvidence = $stateEvidence
    toolStarts = $toolStarts
    toolCompletes = $toolCompletes
    toolCalls = $toolCalls
    tokenSeen = ($text -match [regex]::Escape($Token))
    exactTokenMessageSeen = ($text -match ('"content":"' + [regex]::Escape($Token) + '"'))
    sessionDurationMs = if ($null -ne $resultLine -and $null -ne $resultLine.usage) { $resultLine.usage.sessionDurationMs } else { $null }
    totalApiDurationMs = if ($null -ne $resultLine -and $null -ne $resultLine.usage) { $resultLine.usage.totalApiDurationMs } else { $null }
    premiumRequests = if ($null -ne $resultLine -and $null -ne $resultLine.usage) { $resultLine.usage.premiumRequests } else { $null }
    logPath = $LogPath
    attemptsMetaPath = $attemptsMetaPath
    attempts = $attempts
  }

  return $resultObject
}

Write-Host "Preparing full-flow benchmark context..."
Write-Host "Issue #$IssueNumber -> $($issue.title)"
Write-Host "Branch: $BranchName"
Write-Host "Cleanroom: $cleanroomDir"

Write-Host "Running H benchmark (Inquiry methodology)..."
$hResult = Invoke-CopilotRun -ModeName 'h' -Prompt $hPrompt -Token 'FULLFLOW_H_OK' -LogPath $hLog -UseInquiryAgent -InjectedInstructions $inquiryAgentInstructions -MaxAttempts 1 -RunTimeoutSec $RunTimeoutSecH

Write-Host "Running F benchmark (freestyle)..."
$fResult = Invoke-CopilotRun -ModeName 'f' -Prompt $fPrompt -Token 'FULLFLOW_F_OK' -LogPath $fLog -MaxAttempts 2 -RunTimeoutSec $RunTimeoutSecF

# Grade the artifacts the cycle produced — the PRIMARY result (#246).
$diagnosisForGrading = Join-Path $cleanroomDir 'diagnosis.md'
$planForGrading = Join-Path (Split-Path $cleanroomDir -Parent) 'plan.md'
$cliRootForGrading = Split-Path $PSScriptRoot -Parent
$diagnosisVerifiable = Test-EvidenceVerifiable -DiagnosisPath $diagnosisForGrading
$planExecutable = Test-PlanExecutable -PlanPath $planForGrading
$testsGreen = if ($GradeTests) { Test-SuiteGreen -CliRoot $cliRootForGrading } else { $null }
$verifiableArtifacts = [pscustomobject]@{
  diagnosisEvidenceVerifiable = $diagnosisVerifiable
  planHasExecutableChecks = $planExecutable
  testsGreen = $testsGreen
  # "verifiable" requires reopenable evidence + an executable plan, and a green
  # suite when graded. A cycle that only emits its success token is NOT verifiable.
  verifiable = ($diagnosisVerifiable -and $planExecutable -and ($testsGreen -ne $false))
}

$summary = [pscustomobject]@{
  generatedAt = (Get-Date).ToString('o')
  workspace = (Resolve-Path $Workspace).Path
  issue = $issue.number
  issueTitle = $issue.title
  branch = $BranchName
  model = $Model
  providerBaseUrl = $ProviderBaseUrl
  verifiableArtifacts = $verifiableArtifacts
  results = @($hResult, $fResult)
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $summaryPath -Encoding UTF8

Write-Host ""
Write-Host "Verifiable artifacts (primary result):"
$verifiableArtifacts | Format-List diagnosisEvidenceVerifiable, planHasExecutableChecks, testsGreen, verifiable
Write-Host ""
Write-Host "Flow movement (secondary):"
$summary.results | Format-Table mode, exitCode, reachedIDLE, reachedANALYZE, reachedPLAN, reachedEXECUTE, reachedEND, toolCalls, totalApiDurationMs, sessionDurationMs, premiumRequests -AutoSize
Write-Host ""
Write-Host "Summary JSON: $summaryPath"
Write-Host "H log: $hLog"
Write-Host "F log: $fLog"