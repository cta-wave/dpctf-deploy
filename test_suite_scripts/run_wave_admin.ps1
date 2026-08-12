param(
    [string]$WinUser = $env:USERNAME
)

$toolsDir = "C:\Users\$WinUser\test_suite_scripts"
$repoWin  = "C:\Users\$WinUser\dpctf-deploy"
$config   = "$repoWin\config.json"
$repoWsl  = "/mnt/c/Users/$WinUser/dpctf-deploy"

$singleTemplate = Join-Path $toolsDir "1_Device_Test.md"
$twoTemplate    = Join-Path $toolsDir "2_Device_Test.md"

$singleOutput   = Join-Path $toolsDir "1_Device_Test_CURRENT.md"
$twoOutput      = Join-Path $toolsDir "2_Device_Test_CURRENT.md"

$observationConfigWin = Join-Path $repoWin "observation-config.ini"

function Write-Section {
    param([string]$Text)
    Write-Host ""
    Write-Host $Text
}

function Fail-Script {
    param([string]$Message)
    Write-Host ""
    Write-Host "ERROR: $Message"
    exit 1
}

function Confirm-Admin {
    $currentIdentity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin) {
        Fail-Script "This script must be run as Administrator."
    }
}

function Get-ComposeCommand {
    $cmd = "if docker compose version >/dev/null 2>&1; then echo 'docker compose'; elif command -v docker-compose >/dev/null 2>&1; then echo 'docker-compose'; else echo ''; fi"
    $result = (wsl bash -lc $cmd).Trim()

    if (-not $result) {
        Fail-Script "Docker Compose was not found inside WSL."
    }

    return $result
}

function Get-FirstWslIp {
    $ipOutput = (wsl hostname -I).Trim()
    if (-not $ipOutput) {
        Fail-Script "Unable to determine WSL IP address."
    }

    return ($ipOutput -split '\s+')[0]
}

function Get-ActiveHostIp {
    param(
        [bool]$RequireWifi
    )

    $adapters = Get-NetIPConfiguration | Where-Object {
        $_.IPv4Address -and $_.NetAdapter.Status -eq "Up"
    }

    $wifi = $adapters | Where-Object {
        $_.NetAdapter.Name -match "Wi-?Fi" -or $_.NetAdapter.InterfaceDescription -match "Wi-?Fi"
    } | Select-Object -First 1

    if ($wifi) {
        return [string]($wifi.IPv4Address.IPAddress | Select-Object -First 1)
    }

    if ($RequireWifi) {
        Fail-Script "Wi-Fi is required for 2-device testing, but no active Wi-Fi adapter was found."
    }

    $firstAdapter = $adapters | Select-Object -First 1
    if (-not $firstAdapter) {
        Fail-Script "No active IPv4 network adapter found."
    }

    return [string]($firstAdapter.IPv4Address.IPAddress | Select-Object -First 1)
}

function Get-DofConfigUrl {
    $imageTags = (wsl bash -lc "docker images dpctf-dof --format '{{.Tag}}' 2>/dev/null" | Where-Object { $_ -and $_.Trim() -ne "" }) |
        ForEach-Object { $_.Trim() } |
        Select-Object -Unique

    $versionTag = $imageTags | Where-Object { $_ -match '^\d+\.\d+\.\d+$' } | Select-Object -First 1

    if ($versionTag) {
        return "https://raw.githubusercontent.com/cta-wave/device-observation-framework/$versionTag/config.ini"
    }

    return "https://raw.githubusercontent.com/cta-wave/device-observation-framework/main/config.ini"
}

function Ensure-ObservationConfigExists {
    if (Test-Path $observationConfigWin) {
        Write-Host "Using existing observation-config.ini:"
        Write-Host "  $observationConfigWin"
        return
    }

    Write-Host "observation-config.ini not found. Creating it from the DOF template..."

    $configUrl = Get-DofConfigUrl
    Write-Host "Fetching DOF config template:"
    Write-Host "  $configUrl"

    try {
        Invoke-WebRequest -Uri $configUrl -OutFile $observationConfigWin -UseBasicParsing
    }
    catch {
        if ($configUrl -notmatch '/main/config\.ini$') {
            Write-Host "Falling back to DOF main branch config.ini..."
            $fallbackUrl = "https://raw.githubusercontent.com/cta-wave/device-observation-framework/main/config.ini"
            Invoke-WebRequest -Uri $fallbackUrl -OutFile $observationConfigWin -UseBasicParsing
        }
        else {
            throw
        }
    }

    if (!(Test-Path $observationConfigWin)) {
        Fail-Script "observation-config.ini was not created."
    }

    Write-Host "Created: $observationConfigWin"
}

function Update-ObservationConfigTestRunnerUrl {
    param(
        [string]$TestRunnerUrl
    )

    if (!(Test-Path $observationConfigWin)) {
        Fail-Script "observation-config.ini does not exist: $observationConfigWin"
    }

    $content = Get-Content $observationConfigWin -Raw

    if ($content -match '(?m)^\s*test_runner_url\s*=.*$') {
        $content = [regex]::Replace(
            $content,
            '(?m)^\s*test_runner_url\s*=.*$',
            "test_runner_url = $TestRunnerUrl"
        )
    }
    else {
        $content = $content.TrimEnd() + "`r`n`r`ntest_runner_url = $TestRunnerUrl`r`n"
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($observationConfigWin, $content, $utf8NoBom)

    Write-Host "Updated observation-config.ini:"
    Write-Host "  test_runner_url = $TestRunnerUrl"
    Write-Host ""
    Write-Host "All other user customizations in observation-config.ini were preserved."
}

function Apply-TemplateReplacements {
    param(
        [string]$TemplateText,
        [hashtable]$Values
    )

    $result = $TemplateText

    foreach ($key in $Values.Keys) {
        $escapedPattern = [regex]::Escape($key)
        $replacement = [string]$Values[$key]
        $result = [regex]::Replace($result, $escapedPattern, [System.Text.RegularExpressions.MatchEvaluator]{
            param($m)
            return $replacement
        })
    }

    return $result
}

Confirm-Admin

Write-Host ""
Write-Host "==== WAVE Test Runner ===="
Write-Host ""
Write-Host "NOTE: The WAVE Test Suite requires EULA acceptance before the test runner will function."
Write-Host "If you have not yet accepted the EULA during the build step, the test runner will not work."
Write-Host "EULA: https://github.com/cta-wave/dpctf-deploy/?tab=readme-ov-file#agree-to-the-eula"
Write-Host ""

if (!(Test-Path $repoWin)) {
    Fail-Script "Repository not found: $repoWin"
}

if (!(Test-Path $config)) {
    Fail-Script "config.json not found: $config"
}

if (!(Test-Path $singleTemplate)) {
    Fail-Script "Single-device instructions not found: $singleTemplate"
}

if (!(Test-Path $twoTemplate)) {
    Fail-Script "Two-device instructions not found: $twoTemplate"
}

$testType = Read-Host "Enter test type: 1=Single Device, 2=Two Device"

if ($testType -eq "2") {
    Write-Section "IMPORTANT FOR 2-DEVICE TESTS:"
    Write-Host "Use HTTP / host_ip unless BOTH devices are configured for HTTPS."
    Write-Host ""
    Write-Host "Select HTTPS / domain only if BOTH the Host and DUT:"
    Write-Host "  - can resolve the domain to the CURRENT Host IP"
    Write-Host "  - trust the same root CA certificate"
    Write-Host ""
    Write-Host "For most 2-device tests, select:"
    Write-Host "  1 = HTTP (recommended)"
}

$requireWifi = ($testType -eq "2")

$connectionMode = Read-Host "Connection mode: 1=HTTP (host IP), 2=HTTPS (domain)"
$useHttps = ($connectionMode -eq "2")

$httpsDomain = "dpctf.local"
if ($useHttps) {
    $enteredDomain = Read-Host "Enter HTTPS domain [dpctf.local]"
    if ($enteredDomain) {
        $httpsDomain = $enteredDomain
    }
}

$hostIp = Get-ActiveHostIp -RequireWifi:$requireWifi
$wslIp = Get-FirstWslIp
$composeCmd = Get-ComposeCommand

Write-Section "Detected network information"
Write-Host "Host IP: $hostIp"
Write-Host "WSL IP:  $wslIp"

$configJson = Get-Content $config -Raw | ConvertFrom-Json
$previousHostOverride = [string]$configJson.wave.host_override
$configJson.wave.host_override = $hostIp

$jsonText = $configJson | ConvertTo-Json -Depth 30
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($config, $jsonText, $utf8NoBom)

Write-Section "Updated config.json host_override"
Write-Host "config.json host_override was set to: $hostIp"

$protocol = if ($useHttps) { "HTTPS" } else { "HTTP" }
$addressType = if ($useHttps) { "Domain" } else { "Host IP" }
$selectedHost = if ($useHttps) { $httpsDomain } else { $hostIp }
$selectedModeText = if ($testType -eq "2") {
    "Two Device / $protocol / $addressType"
} else {
    "Single Device / $protocol / $addressType"
}

$testRunnerBaseUrl = if ($useHttps) {
    "https://${httpsDomain}:8443"
} else {
    "http://${hostIp}:8000"
}

$testRunnerWaveUrl = "$testRunnerBaseUrl/_wave/"
$indexUrl = "$testRunnerBaseUrl/_wave/index.html"
$configPageUrl = "$testRunnerBaseUrl/_wave/configuration.html"

$dofPort         = if ($useHttps) { "8443" } else { "8000" }
$dofTestRunnerUrl = "$(if ($useHttps) { 'https' } else { 'http' })://localhost:${dofPort}/_wave/"

if ($testType -eq "2") {
    Write-Section "Preparing Observation Framework configuration for 2-device testing"
    Ensure-ObservationConfigExists
    Update-ObservationConfigTestRunnerUrl -TestRunnerUrl $dofTestRunnerUrl
}
else {
    Write-Section "Single-device test selected"
    if (Test-Path $observationConfigWin) {
        Write-Host "Existing observation-config.ini detected and left unchanged:"
        Write-Host "  $observationConfigWin"
        Write-Host ""
        Write-Host "This file is not required for 1-device testing."
    }
    else {
        Write-Host "No observation-config.ini is required for 1-device testing."
    }
}

Write-Section "Configuring Windows port forwarding"
netsh interface portproxy delete v4tov4 listenport=8000 listenaddress=0.0.0.0 2>$null | Out-Null
netsh interface portproxy delete v4tov4 listenport=8443 listenaddress=0.0.0.0 2>$null | Out-Null
netsh interface portproxy delete v4tov4 listenport=8000 listenaddress=$hostIp 2>$null | Out-Null
netsh interface portproxy delete v4tov4 listenport=8443 listenaddress=$hostIp 2>$null | Out-Null

netsh interface portproxy add v4tov4 listenport=8000 listenaddress=0.0.0.0 connectport=8000 connectaddress=$wslIp
netsh interface portproxy add v4tov4 listenport=8443 listenaddress=0.0.0.0 connectport=8443 connectaddress=$wslIp

Write-Host "Port forwarding configured"

Write-Section "Starting docker services in WSL..."
if ($previousHostOverride -ne $hostIp) {
    Write-Host "Host IP changed ($previousHostOverride -> $hostIp). Restarting containers to apply new IP..."
    wsl bash -lc "cd '$repoWsl' && $composeCmd down --timeout 10 && $composeCmd up -d"
} else {
    Write-Host "Host IP unchanged ($hostIp). Starting containers without restart to preserve session data..."
    wsl bash -lc "cd '$repoWsl' && $composeCmd up -d"
}

if ($LASTEXITCODE -ne 0) {
    Fail-Script "Docker Compose failed inside WSL."
}

$logCommand = "cd '$repoWsl' && echo 'Showing live logs for dpctf. Press Ctrl+C to stop viewing logs.' && docker logs -f dpctf"

Write-Host "Opening WSL log window..."
try {
    Start-Process "wt.exe" -ArgumentList @(
        "wsl.exe",
        "bash",
        "-lc",
        $logCommand
    )
}
catch {
    Start-Process "wsl.exe" -ArgumentList @(
        "bash",
        "-lc",
        $logCommand
    )
}

$singleText = Get-Content $singleTemplate -Raw
$twoText    = Get-Content $twoTemplate -Raw

$replacementValues = @{
    '<selected_mode>'            = $selectedModeText
    '<protocol>'                 = $protocol
    '<address_type>'             = $addressType
    '<selected_host>'            = $selectedHost
    '<host_ip>'                  = $hostIp
    '<domain>'                   = $httpsDomain
    '<test_runner_base_url>'     = $testRunnerBaseUrl
    '<test_runner_wave_url>'     = $testRunnerWaveUrl
    '<dof_test_runner_url>'      = $dofTestRunnerUrl
    '<test_runner_index_url>'    = $indexUrl
    '<test_runner_config_url>'   = $configPageUrl
    '<observation_config_path>'  = $observationConfigWin
    '<your_username>'            = $WinUser
}

$singleText = Apply-TemplateReplacements -TemplateText $singleText -Values $replacementValues
$twoText    = Apply-TemplateReplacements -TemplateText $twoText -Values $replacementValues

[System.IO.File]::WriteAllText($singleOutput, $singleText, $utf8NoBom)
[System.IO.File]::WriteAllText($twoOutput, $twoText, $utf8NoBom)

Write-Section "NOTE: A TEXT DOCUMENT WILL OPEN WITH INSTRUCTIONS ON RUNNING A TEST."

if ($useHttps) {
    Write-Host "HTTPS PRE-CHECK"
    Write-Host "Before running the test, verify the following on the DUT if applicable:"
    Write-Host ""
    Write-Host "1. Domain resolves to Host IP:"
    Write-Host "   ping $httpsDomain"
    Write-Host ""
    Write-Host "2. Port 8443 is reachable:"
    Write-Host "   Test-NetConnection $hostIp -Port 8443"
    Write-Host ""
    Write-Host "3. Browser opens:"
    Write-Host "   $indexUrl"
    Write-Host ""

    if ($testType -eq "2") {
        Write-Host "If using a second device, make sure it also has:"
        Write-Host "  - a hosts entry for $httpsDomain"
        Write-Host "  - the trusted root CA certificate"
        Write-Host ""
        Write-Host "Suggested hosts entry for the DUT:"
        Write-Host "  $hostIp $httpsDomain"
        Write-Host ""
        Write-Host "Observation Framework will post results to:"
        Write-Host "  $testRunnerWaveUrl"
        Write-Host ""
    }
}

if ($testType -eq "1") {
    Write-Host "Single-device instructions prepared:"
    Write-Host "  $singleOutput"
    Write-Host ""

    Write-Host "Open on Host:"
    Write-Host "  $indexUrl"

    Start-Process notepad.exe $singleOutput
}
elseif ($testType -eq "2") {
    Write-Host "Two-device instructions prepared:"
    Write-Host "  $twoOutput"
    Write-Host ""
    Write-Host "observation-config.ini prepared:"
    Write-Host "  $observationConfigWin"
    Write-Host ""
    Write-Host "DOF test_runner_url:"
    Write-Host "  $testRunnerWaveUrl"
    Write-Host ""

    Write-Host "Open on DUT first:"
    Write-Host "  $indexUrl"
    Write-Host ""
    Write-Host "Then open on Host:"
    Write-Host "  $configPageUrl"

    Start-Process notepad.exe $twoOutput
}
else {
    Write-Host "Unknown test type. Opening both instruction files."
    Start-Process notepad.exe $singleOutput
    Start-Process notepad.exe $twoOutput
}
