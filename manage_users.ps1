#Requires -Version 5.1
<#
.SYNOPSIS
    Kohalike kasutajakontode haldus - peamenüü.
.DESCRIPTION
    Käivita administraatorina skripti kaustast.
    Menüü pakub: kasutajate lisamist CSV failist ja kasutaja kustutamist.
#>

# ── Algseadistus ─────────────────────────────────────────────────────────────
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Liigu alati skripti enda kausta, et suhtelised teed töötaksid
Set-Location -Path $PSScriptRoot

# ── Admin-õiguste kontroll ────────────────────────────────────────────────────
$isAdmin = ([Security.Principal.WindowsPrincipal]
            [Security.Principal.WindowsIdentity]::GetCurrent()
           ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "  VIGA: Skript vajab administraatori oigusi." -ForegroundColor Red
    Write-Host "  Ava PowerShell paremklõpsuga -> 'Käivita administraatorina'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "  Vajuta Enter väljumiseks"
    exit 1
}

# ── Abifailide laadimine ──────────────────────────────────────────────────────
. "$PSScriptRoot\functions\Add-UsersFromCsv.ps1"
. "$PSScriptRoot\functions\Remove-UserAccount.ps1"

# ── Peamenüü ──────────────────────────────────────────────────────────────────
function Show-Menu {
    Clear-Host
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   KOHALIKE KASUTAJATE HALDUS" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1]  Lisa kasutajad CSV failist"
    Write-Host "  [2]  Kustuta kasutaja"
    Write-Host ""
    Write-Host "  [X]  Välju"
    Write-Host ""
    Write-Host "--------------------------------------" -ForegroundColor DarkGray
}

$running = $true
while ($running) {
    Show-Menu
    $choice = (Read-Host "  Vali toiming (1, 2 voi X)").Trim()

    switch ($choice.ToUpper()) {
        '1' {
            Add-UsersFromCsv -CsvPath "$PSScriptRoot\new_users_accounts.csv"
            Write-Host ""
            Read-Host "  Vajuta Enter menüüsse naasmiseks"
        }
        '2' {
            Remove-UserAccount
            Write-Host ""
            Read-Host "  Vajuta Enter menüüsse naasmiseks"
        }
        'X' {
            Write-Host ""
            Write-Host "  Nägemist!" -ForegroundColor Cyan
            Write-Host ""
            $running = $false
        }
        default {
            Write-Host ""
            Write-Host "  Tundmatu valik. Palun sisesta 1, 2 voi X." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
        }
    }
}
