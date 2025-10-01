# Windows PowerShell - Build Environment Check
# Usage: .\check_build_env.ps1

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Build Environment Check Tool" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

# Check Flutter
Write-Host "[1] Checking Flutter SDK..." -ForegroundColor Yellow
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    $flutterVersion = flutter --version | Select-String 'Flutter' | Select-Object -First 1
    Write-Host "  OK: Flutter installed" -ForegroundColor Green
    Write-Host "  $flutterVersion" -ForegroundColor Gray
} else {
    Write-Host "  ERROR: Flutter not found" -ForegroundColor Red
    $allOk = $false
}
Write-Host ""

# Check Java
Write-Host "[2] Checking Java JDK..." -ForegroundColor Yellow
if (Get-Command java -ErrorAction SilentlyContinue) {
    $javaVersion = java -version 2>&1 | Select-String 'version' | Select-Object -First 1
    Write-Host "  OK: Java installed" -ForegroundColor Green
    Write-Host "  $javaVersion" -ForegroundColor Gray
    
    if (Get-Command keytool -ErrorAction SilentlyContinue) {
        Write-Host "  OK: keytool available" -ForegroundColor Green
    } else {
        Write-Host "  WARNING: keytool not found" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ERROR: Java not found" -ForegroundColor Red
    $allOk = $false
}
Write-Host ""

# Check Android SDK
Write-Host "[3] Checking Android SDK..." -ForegroundColor Yellow
$androidHome = $env:ANDROID_HOME
if (-not $androidHome) {
    $androidHome = $env:ANDROID_SDK_ROOT
}

if ($androidHome) {
    Write-Host "  OK: ANDROID_HOME set" -ForegroundColor Green
    Write-Host "  $androidHome" -ForegroundColor Gray
} else {
    Write-Host "  WARNING: ANDROID_HOME not set" -ForegroundColor Yellow
}
Write-Host ""

# Check project files
Write-Host "[4] Checking project configuration..." -ForegroundColor Yellow

if (Test-Path "pubspec.yaml") {
    Write-Host "  OK: pubspec.yaml exists" -ForegroundColor Green
} else {
    Write-Host "  ERROR: pubspec.yaml not found" -ForegroundColor Red
    $allOk = $false
}

if (Test-Path ".env") {
    Write-Host "  OK: .env file exists" -ForegroundColor Green
} else {
    Write-Host "  WARNING: .env file not found" -ForegroundColor Yellow
    Write-Host "  Run: Copy-Item .env.example .env" -ForegroundColor Gray
}

if (Test-Path "android") {
    Write-Host "  OK: android directory exists" -ForegroundColor Green
} else {
    Write-Host "  ERROR: android directory not found" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""

# Check signing
Write-Host "[5] Checking signing configuration..." -ForegroundColor Yellow

if (Test-Path "android\key.properties") {
    Write-Host "  OK: key.properties configured" -ForegroundColor Green
    
    $keyProps = Get-Content "android\key.properties" | Where-Object { $_ -match '=' }
    $keyPropsDict = @{}
    foreach ($line in $keyProps) {
        if ($line -match '^([^=]+)=(.+)$') {
            $keyPropsDict[$matches[1].Trim()] = $matches[2].Trim()
        }
    }
    
    if ($keyPropsDict.ContainsKey('storeFile')) {
        $keystorePath = "android\" + $keyPropsDict['storeFile']
        if (Test-Path $keystorePath) {
            Write-Host "  OK: Keystore file exists" -ForegroundColor Green
        } else {
            Write-Host "  ERROR: Keystore file not found" -ForegroundColor Red
            $allOk = $false
        }
    }
} else {
    Write-Host "  WARNING: key.properties not found" -ForegroundColor Yellow
    Write-Host "  Run: .\generate_keystore.ps1" -ForegroundColor Gray
}

Write-Host ""

# Check build.gradle
Write-Host "[6] Checking Android build configuration..." -ForegroundColor Yellow

if (Test-Path "android\app\build.gradle.kts") {
    Write-Host "  OK: build.gradle.kts exists" -ForegroundColor Green
    
    $buildGradle = Get-Content "android\app\build.gradle.kts" -Raw
    
    if ($buildGradle -match 'applicationId\s*=\s*"([^"]+)"') {
        $appId = $matches[1]
        Write-Host "  Application ID: $appId" -ForegroundColor Cyan
        
        if ($appId -eq "com.example.todolist_mobile") {
            Write-Host "  WARNING: Using example package name" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  ERROR: build.gradle.kts not found" -ForegroundColor Red
    $allOk = $false
}

Write-Host ""

# Check dependencies
Write-Host "[7] Checking Flutter dependencies..." -ForegroundColor Yellow

if (Test-Path ".dart_tool") {
    Write-Host "  OK: Dependencies fetched" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Dependencies not fetched" -ForegroundColor Yellow
    Write-Host "  Run: flutter pub get" -ForegroundColor Gray
}

Write-Host ""

# Summary
Write-Host "===========================================" -ForegroundColor Cyan

if ($allOk) {
    Write-Host "  Build environment ready!" -ForegroundColor Green
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "You can start building:" -ForegroundColor Green
    Write-Host "  .\build_android.ps1" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "  Some issues found" -ForegroundColor Yellow
    Write-Host "===========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Solutions:" -ForegroundColor Yellow
    Write-Host "  1. Generate signing key:" -ForegroundColor White
    Write-Host "     .\generate_keystore.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  2. Create .env file:" -ForegroundColor White
    Write-Host "     Copy-Item .env.example .env" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  3. Get dependencies:" -ForegroundColor White
    Write-Host "     flutter pub get" -ForegroundColor Cyan
    Write-Host ""
}

Write-Host "Documentation:" -ForegroundColor Cyan
Write-Host "  * BUILD_QUICK_START.md" -ForegroundColor Gray
Write-Host "  * GOOGLE_PLAY_RELEASE.md" -ForegroundColor Gray
Write-Host "  * ENV_CONFIG.md" -ForegroundColor Gray
Write-Host ""
