# Applies the Windows policy values behind Azure Virtual Desktop's documented
# GPU rendering and H.264/AVC hardware-encoding settings. This script runs as
# LocalSystem through Azure Managed Run Command after the NVIDIA extension.
# It intentionally does not install game launchers or bypass game DRM/anti-cheat.

$ErrorActionPreference = "Stop"

$NvidiaSmiCandidates = @(
    "$env:ProgramFiles\NVIDIA Corporation\NVSMI\nvidia-smi.exe",
    "$env:WINDIR\System32\nvidia-smi.exe"
)

$NvidiaSmi = $NvidiaSmiCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $NvidiaSmi) {
    throw "NVIDIA tools were not found. Check the NvidiaGpuDriverWindows extension before applying AVD graphics policies."
}

$GpuDetails = & $NvidiaSmi --query-gpu=name,driver_version,memory.total --format=csv,noheader 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "nvidia-smi failed. The NVIDIA driver is not ready: $GpuDetails"
}

$RdsPolicyPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services"
if (-not (Test-Path $RdsPolicyPath)) {
    New-Item -Path $RdsPolicyPath -Force | Out-Null
}

# Use hardware graphics adapters for all Remote Desktop Services sessions.
New-ItemProperty -Path $RdsPolicyPath -Name "bEnumerateHWBeforeSW" -PropertyType DWord -Value 1 -Force | Out-Null

# Configure H.264/AVC hardware encoding and prefer AVC 4:4:4 graphics mode.
# Both settings are enabled together so AVC 4:4:4 does not fall back to
# CPU-based full-screen encoding.
New-ItemProperty -Path $RdsPolicyPath -Name "AVCHardwareEncodePreferred" -PropertyType DWord -Value 1 -Force | Out-Null
New-ItemProperty -Path $RdsPolicyPath -Name "AVC444ModePreferred" -PropertyType DWord -Value 1 -Force | Out-Null

Write-Output "NVIDIA GPU detected: $GpuDetails"
Write-Output "AVD GPU rendering and H.264/AVC policy values were applied."
Write-Output "Scheduling a reboot in 60 seconds to complete the NVIDIA/RDS configuration."

# Schedule rather than immediately force a reboot, letting this run command
# return success to Terraform first.
Start-Process -FilePath "$env:WINDIR\System32\shutdown.exe" -ArgumentList "/r /t 60 /f /c `"Complete NVIDIA and AVD GPU configuration`"" -WindowStyle Hidden
