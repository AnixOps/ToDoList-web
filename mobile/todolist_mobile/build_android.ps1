# Windows PowerShell - Android Build Script
# Usage: .\build_android.ps1 [-Type <apk|aab|both>] [-Flavor <production|development>] [-Clean] [-Help]

param(
    [string]$Type = "aab",
    [string]$Flavor = "production",
    [switch]$Clean,
    [switch]$Help
)

if ($Help) {
    Write-Host "Android Build Script" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage: .\build_android.ps1 [options]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -Type <apk|aab|both>   Build type (default: aab)" -ForegroundColor White
    Write-Host "  -Flavor <prod|dev>     Product flavor (default: production)" -ForegroundColor White
    Write-Host "  -Clean                 Clean before build" -ForegroundColor White
    Write-Host "  -Help                  Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\build_android.ps1" -ForegroundColor Gray
    Write-Host "  .\build_android.ps1 -Type apk" -ForegroundColor Gray
    Write-Host "  .\build_android.ps1 -Type both -Clean" -ForegroundColor Gray
    exit 0
}

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Android Build Tool" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter
Write-Host "[1/6] Checking build environment..." -ForegroundColor Yellow
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Flutter not found" -ForegroundColor Red
    exit 1
}
Write-Host "  Flutter SDK found" -ForegroundColor Green

# Check signing
Write-Host ""
Write-Host "[2/6] Checking signing configuration..." -ForegroundColor Yellow
if (-not (Test-Path "android\key.properties")) {
    Write-Host "  WARNING: key.properties not found" -ForegroundColor Yellow
    Write-Host "  Will use debug signing" -ForegroundColor Yellow
} else {
    Write-Host "  Signing configuration found" -ForegroundColor Green
}

# Check .env
Write-Host ""
Write-Host "[3/6] Checking environment configuration..." -ForegroundColor Yellow
if (Test-Path ".env") {
    Write-Host "  Environment configuration found" -ForegroundColor Green
} else {
    Write-Host "  WARNING: .env file not found" -ForegroundColor Yellow
}

# Clean
if ($Clean) {
    Write-Host ""
    Write-Host "[4/6] Cleaning project..." -ForegroundColor Yellow
    flutter clean
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Clean failed" -ForegroundColor Red
        exit 1
    }
    Write-Host "  Clean completed" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "[4/6] Skipping clean..." -ForegroundColor Yellow
}

# Get dependencies
Write-Host ""
Write-Host "[5/6] Getting dependencies..." -ForegroundColor Yellow
flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to get dependencies" -ForegroundColor Red
    exit 1
}
Write-Host "  Dependencies resolved" -ForegroundColor Green

# Build
Write-Host ""
Write-Host "[6/6] Building..." -ForegroundColor Yellow
Write-Host "  Type: $Type" -ForegroundColor Cyan
Write-Host "  Flavor: $Flavor" -ForegroundColor Cyan
Write-Host ""

$buildSuccess = $true

# Build AAB
if ($Type -eq "aab" -or $Type -eq "both") {
    Write-Host "Building App Bundle (AAB)..." -ForegroundColor Cyan
    flutter build appbundle --release --flavor $Flavor
    
    if ($LASTEXITCODE -eq 0) {
        $aabPath = "build\app\outputs\bundle\${Flavor}Release\app-${Flavor}-release.aab"
        if (Test-Path $aabPath) {
            $aabSize = (Get-Item $aabPath).Length / 1MB
            Write-Host "  SUCCESS: AAB built!" -ForegroundColor Green
            Write-Host "  Location: $aabPath" -ForegroundColor Cyan
            Write-Host "  Size: $([math]::Round($aabSize, 2)) MB" -ForegroundColor Cyan
        }
    } else {
        Write-Host "  ERROR: AAB build failed" -ForegroundColor Red
        $buildSuccess = $false
    }
    Write-Host ""
}

# Build APK
if ($Type -eq "apk" -or $Type -eq "both") {
    Write-Host "Building APK..." -ForegroundColor Cyan
    flutter build apk --release --flavor $Flavor --split-per-abi
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  SUCCESS: APK built!" -ForegroundColor Green
        
        $apkDir = "build\app\outputs\flutter-apk"
        if (Test-Path $apkDir) {
            $apkFiles = Get-ChildItem $apkDir -Filter "*.apk" | Where-Object { $_.Name -like "*$Flavor*" }
            
            if ($apkFiles.Count -gt 0) {
                Write-Host "  APK files:" -ForegroundColor Cyan
                foreach ($apk in $apkFiles) {
                    $size = $apk.Length / 1MB
                    Write-Host "    * $($apk.Name) - $([math]::Round($size, 2)) MB" -ForegroundColor White
                }
                Write-Host "  Directory: $apkDir" -ForegroundColor Cyan
            }
        }
    } else {
        Write-Host "  ERROR: APK build failed" -ForegroundColor Red
        $buildSuccess = $false
    }
    Write-Host ""
}

# Summary
Write-Host "===========================================" -ForegroundColor Cyan
if ($buildSuccess) {
    Write-Host "  BUILD SUCCESS!" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "  1. Test the build locally" -ForegroundColor White
    Write-Host "  2. Upload to Google Play Console" -ForegroundColor White
    Write-Host "  3. See GOOGLE_PLAY_RELEASE.md for details" -ForegroundColor White
    exit 0
} else {
    Write-Host "  BUILD FAILED" -ForegroundColor Red
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Run: flutter doctor" -ForegroundColor White
    Write-Host "  2. Check signing configuration" -ForegroundColor White
    Write-Host "  3. See error messages above" -ForegroundColor White
    exit 1
}
