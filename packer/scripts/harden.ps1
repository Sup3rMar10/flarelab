# Disable Defender, Windows Update, telemetry (analysis VM only)
$ErrorActionPreference = 'Continue'

function Set-Reg($p, $n, $v) {
  New-Item -Path $p -Force | Out-Null
  New-ItemProperty -Path $p -Name $n -Value $v -PropertyType DWord -Force | Out-Null
}

# Defender (Tamper Protection must be off in the base image, else policies are ignored)
Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true `
  -DisableIOAVProtection $true -DisableScriptScanning $true -MAPSReporting 0 -SubmitSamplesConsent 2
$wd = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender'
Set-Reg $wd 'DisableAntiSpyware' 1
Set-Reg "$wd\Real-Time Protection" 'DisableRealtimeMonitoring' 1
Set-Reg "$wd\Spynet" 'SpynetReporting' 0
Set-Reg "$wd\Spynet" 'SubmitSamplesConsent' 2
Get-ScheduledTask -TaskPath '\Microsoft\Windows\Windows Defender\' -ErrorAction SilentlyContinue |
  Disable-ScheduledTask | Out-Null

# SmartScreen
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System' 'EnableSmartScreen' 0

# Windows Update
$wu = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
Set-Reg $wu 'NoAutoUpdate' 1
foreach ($s in 'wuauserv', 'UsoSvc', 'WaaSMedicSvc') {
  Stop-Service $s -Force -ErrorAction SilentlyContinue
  Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue
}

# Telemetry
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 0
foreach ($s in 'DiagTrack', 'dmwappushservice') {
  Stop-Service $s -Force -ErrorAction SilentlyContinue
  Set-Service $s -StartupType Disabled -ErrorAction SilentlyContinue
}

# No sleep / lock
powercfg /h off
powercfg /change standby-timeout-ac 0
powercfg /change monitor-timeout-ac 0
