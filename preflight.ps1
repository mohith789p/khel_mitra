# preflight.ps1

Write-Host "1. Detection: Checking for connected Android devices..." -ForegroundColor Cyan
$deviceOutput = flutter devices 2>&1

Write-Host $deviceOutput

if ($deviceOutput -match "No devices found") {
    Write-Error "No connected devices found. Please connect your Android device via USB."
    exit 1
}

if ($deviceOutput -match "Unauthorized") {
    Write-Warning "Device found but Unauthorized. Please unlock your phone and tap 'Allow USB Debugging'."
    exit 1
}

$deviceId = ""
# Simple regex to grab the first device ID (assuming it's the second line of output usually)
# Adjust regex based on specific 'flutter devices' output format if needed.
# Launching specifically on the first available device for now.

Write-Host "2. Networking: Setting up ADB Reverse Tunnel (tcp:3000)..." -ForegroundColor Cyan
adb reverse tcp:3000 tcp:3000

if ($LASTEXITCODE -ne 0) {
    Write-Warning "ADB Reverse failed. Is adb in your PATH?"
    # Proceeding anyway as it might not be strictly fatal for the POC "Hello World" (no backend yet)
}

Write-Host "3. Launch: Building and installing app..." -ForegroundColor Green
flutter run --release
