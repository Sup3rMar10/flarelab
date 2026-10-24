# Headless FLARE-VM install with custom config (build-time internet required)
$ErrorActionPreference = 'Stop'
Set-ExecutionPolicy Unrestricted -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$d = 'C:\flare'
New-Item -ItemType Directory -Path $d -Force | Out-Null
Invoke-WebRequest 'https://raw.githubusercontent.com/mandiant/flare-vm/main/install.ps1' -OutFile "$d\install.ps1"
Unblock-File "$d\install.ps1"

& "$d\install.ps1" -password vagrant -noWait -noGui -noReboots -customConfig 'C:\Windows\Temp\config.xml'
