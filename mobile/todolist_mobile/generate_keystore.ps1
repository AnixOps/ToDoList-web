# Windows PowerShell - Generate Android Signing Keystore
# Usage: .\generate_keystore.ps1

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host "  Android Signing Keystore Generator" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

# Check keytool
if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: keytool command not found" -ForegroundColor Red
    Write-Host "Please install Java JDK and add to PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Download Java: https://www.oracle.com/java/technologies/downloads/" -ForegroundColor Cyan
    exit 1
}

Write-Host "Java environment check passed" -ForegroundColor Green
Write-Host ""

# Configuration
$keystoreName = "upload-keystore.jks"
$keystoreAlias = "upload"
$validity = 10000
$keystorePath = "android\$keystoreName"

# Check if exists
if (Test-Path $keystorePath) {
    Write-Host "WARNING: Keystore file already exists: $keystorePath" -ForegroundColor Yellow
    $overwrite = Read-Host "Overwrite? (yes/no)"
    
    if ($overwrite -ne "yes") {
        Write-Host "Operation cancelled" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Will overwrite existing keystore..." -ForegroundColor Yellow
    Write-Host ""
}

# Get keystore password
Write-Host "Step 1: Password Configuration" -ForegroundColor Cyan
Write-Host ""

do {
    $storePassword = Read-Host "Enter keystore password (min 6 chars)" -AsSecureString
    $storePasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
        [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword)
    )
    
    if ($storePasswordText.Length -lt 6) {
        Write-Host "Password too short, please enter at least 6 characters" -ForegroundColor Red
    }
} while ($storePasswordText.Length -lt 6)

$storePasswordConfirm = Read-Host "Confirm keystore password" -AsSecureString
$storePasswordConfirmText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePasswordConfirm)
)

if ($storePasswordText -ne $storePasswordConfirmText) {
    Write-Host "Passwords do not match, please run script again" -ForegroundColor Red
    exit 1
}

Write-Host ""
$useSamePassword = Read-Host "Use same password for key? (yes/no, recommended yes)"

if ($useSamePassword -eq "yes") {
    $keyPasswordText = $storePasswordText
} else {
    do {
        $keyPassword = Read-Host "Enter key password (min 6 chars)" -AsSecureString
        $keyPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
            [Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword)
        )
        
        if ($keyPasswordText.Length -lt 6) {
            Write-Host "Password too short, please enter at least 6 characters" -ForegroundColor Red
        }
    } while ($keyPasswordText.Length -lt 6)
}

# Certificate information
Write-Host ""
Write-Host "Step 2: Certificate Information" -ForegroundColor Cyan
Write-Host ""

$cn = Read-Host "Your name or company name (CN)"
if (-not $cn) { $cn = "Unknown" }

$ou = Read-Host "Organization unit (OU, optional)"
if (-not $ou) { $ou = "Development" }

$o = Read-Host "Organization name (O, optional)"
if (-not $o) { $o = "Personal" }

$l = Read-Host "City (L, optional)"
if (-not $l) { $l = "Beijing" }

$st = Read-Host "State (ST, optional)"
if (-not $st) { $st = "Beijing" }

$c = Read-Host "Country code (C, e.g. CN)"
if (-not $c) { $c = "CN" }

# Confirm
Write-Host ""
Write-Host "Step 3: Confirm Information" -ForegroundColor Cyan
Write-Host ""
Write-Host "Keystore file: $keystorePath" -ForegroundColor White
Write-Host "Key alias: $keystoreAlias" -ForegroundColor White
Write-Host "Validity: $validity days (~$([math]::Round($validity/365, 1)) years)" -ForegroundColor White
Write-Host "Certificate:" -ForegroundColor White
Write-Host "   CN: $cn" -ForegroundColor Gray
Write-Host "   OU: $ou" -ForegroundColor Gray
Write-Host "   O:  $o" -ForegroundColor Gray
Write-Host "   L:  $l" -ForegroundColor Gray
Write-Host "   ST: $st" -ForegroundColor Gray
Write-Host "   C:  $c" -ForegroundColor Gray
Write-Host ""

$confirm = Read-Host "Generate keystore? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Operation cancelled" -ForegroundColor Yellow
    exit 0
}

# Check android directory
if (-not (Test-Path "android")) {
    Write-Host "ERROR: android directory not found" -ForegroundColor Red
    Write-Host "Please run this script from project root" -ForegroundColor Yellow
    exit 1
}

# Generate keystore
Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Cyan
Write-Host ""

$dname = "CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"

try {
    $keytoolArgs = @(
        "-genkeypair",
        "-v",
        "-storetype", "PKCS12",
        "-keystore", $keystorePath,
        "-alias", $keystoreAlias,
        "-keyalg", "RSA",
        "-keysize", "2048",
        "-validity", $validity,
        "-storepass", $storePasswordText,
        "-keypass", $keyPasswordText,
        "-dname", $dname
    )
    
    & keytool $keytoolArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "SUCCESS: Keystore generated!" -ForegroundColor Green
        Write-Host ""
        
        # Show keystore info
        Write-Host "Keystore Information:" -ForegroundColor Cyan
        Write-Host ""
        
        & keytool -list -v -keystore $keystorePath -storepass $storePasswordText -alias $keystoreAlias
        
        Write-Host ""
        Write-Host "Creating key.properties file..." -ForegroundColor Cyan
        
        # Generate key.properties
        $keyPropertiesContent = @"
# Android signing configuration
# WARNING: This file contains sensitive information
# Already added to .gitignore

storeFile=$keystoreName
storePassword=$storePasswordText
keyAlias=$keystoreAlias
keyPassword=$keyPasswordText
"@
        
        $keyPropertiesPath = "android\key.properties"
        $keyPropertiesContent | Out-File -FilePath $keyPropertiesPath -Encoding UTF8 -NoNewline
        
        Write-Host "SUCCESS: key.properties created at $keyPropertiesPath" -ForegroundColor Green
        Write-Host ""
        
        # Backup reminder
        Write-Host "===========================================" -ForegroundColor Red
        Write-Host "  IMPORTANT REMINDERS" -ForegroundColor Red
        Write-Host "===========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "Please backup these files immediately:" -ForegroundColor Yellow
        Write-Host "   1. $keystorePath" -ForegroundColor White
        Write-Host "   2. $keyPropertiesPath" -ForegroundColor White
        Write-Host ""
        Write-Host "Recommended backup locations:" -ForegroundColor Yellow
        Write-Host "   * Encrypted USB drive" -ForegroundColor Gray
        Write-Host "   * Password manager secure notes" -ForegroundColor Gray
        Write-Host "   * Encrypted cloud storage" -ForegroundColor Gray
        Write-Host "   * Secure internal server" -ForegroundColor Gray
        Write-Host ""
        Write-Host "DO NOT:" -ForegroundColor Red
        Write-Host "   * Commit to Git repository" -ForegroundColor Gray
        Write-Host "   * Send via email or chat" -ForegroundColor Gray
        Write-Host "   * Save in unencrypted location" -ForegroundColor Gray
        Write-Host ""
        Write-Host "Passwords:" -ForegroundColor Yellow
        Write-Host "   Keystore password: $storePasswordText" -ForegroundColor White
        Write-Host "   Key password: $keyPasswordText" -ForegroundColor White
        Write-Host "   (Save in password manager)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "===========================================" -ForegroundColor Cyan
        Write-Host "Done! You can now build release version" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "   1. Backup keystore and config files" -ForegroundColor White
        Write-Host "   2. Run: .\build_android.ps1" -ForegroundColor White
        Write-Host "   3. See: GOOGLE_PLAY_RELEASE.md" -ForegroundColor White
        Write-Host ""
        
    } else {
        Write-Host "ERROR: Keystore generation failed" -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
