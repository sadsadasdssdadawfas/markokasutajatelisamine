function Add-UsersFromCsv {
    <#
    .SYNOPSIS
        Lisab kasutajad semikooloniga eraldatud CSV failist Windows kohalikeks kontodeks.
    #>
    param (
        [string]$CsvPath
    )

    Clear-Host
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   LISA KASUTAJAD CSV FAILIST"         -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""

    # ── CSV faili kontroll ────────────────────────────────────────────────────
    if (-not (Test-Path -Path $CsvPath)) {
        Write-Host "  VIGA: CSV faili ei leitud: $CsvPath" -ForegroundColor Red
        Write-Host "  Käivita esmalt generate_users.ps1, et fail luua." -ForegroundColor Yellow
        return
    }

    # Loeme CSV (semikoolon eraldajana)
    try {
        $users = Import-Csv -Path $CsvPath -Delimiter ';' -Encoding UTF8
    }
    catch {
        Write-Host "  VIGA: CSV faili lugemine ebaõnnestus: $_" -ForegroundColor Red
        return
    }

    if ($users.Count -eq 0) {
        Write-Host "  VIGA: CSV fail on tühi, kasutajaid pole lisada." -ForegroundColor Yellow
        return
    }

    Write-Host "  Leitud $($users.Count) kirjet failist: $CsvPath" -ForegroundColor DarkGray
    Write-Host ""

    # ── Iga kasutaja töötlemine ───────────────────────────────────────────────
    $added   = 0
    $skipped = 0
    $failed  = 0

    foreach ($row in $users) {
        $username = $row.Kasutajanimi.Trim()
        $password = $row.Parool.Trim()
        $fullName = "$($row.Eesnimi.Trim()) $($row.Perenimi.Trim())"

        # Windows piirab kirjelduse 48 tähemärgiga
        $description = $row.Kirjeldus.Trim()
        if ($description.Length -gt 48) {
            $description = $description.Substring(0, 48)
        }

        # Tühi kasutajanimi – jätame vahele
        if ([string]::IsNullOrWhiteSpace($username)) {
            Write-Host "  VAHELE: tühi kasutajanimi, jätan rea vahele." -ForegroundColor DarkGray
            $skipped++
            continue
        }

        # Kasutajanimi liiga pikk (Windows max 20)
        if ($username.Length -gt 20) {
            Write-Host "  VAHELE: '$username' - nimi liiga pikk (max 20 tähemärki)." -ForegroundColor Yellow
            $skipped++
            continue
        }

        # Kas kasutaja juba olemas?
        $exists = $false
        try {
            $null = Get-LocalUser -Name $username -ErrorAction Stop
            $exists = $true
        }
        catch {
            $exists = $false
        }

        if ($exists) {
            Write-Host "  VAHELE: '$username' on juba olemas, jätan vahele." -ForegroundColor Yellow
            $skipped++
            continue
        }

        # ── Loo kasutaja ─────────────────────────────────────────────────────
        try {
            $securePass = ConvertTo-SecureString $password -AsPlainText -Force

            New-LocalUser `
                -Name        $username `
                -Password    $securePass `
                -FullName    $fullName `
                -Description $description `
                -ErrorAction Stop | Out-Null

            # Lisa kasutajate gruppi (tavakasutaja õigused)
            Add-LocalGroupMember -Group 'Users' -Member $username -ErrorAction Stop

            # Nõua parooli vahetamist esimesel sisselogimisel
            $adsi = [ADSI]"WinNT://./$username,user"
            $adsi.PasswordExpired = 1
            $adsi.SetInfo()

            Write-Host "  OK  '$username' ($fullName) loodud." -ForegroundColor Green
            $added++
        }
        catch {
            Write-Host "  VIGA '$username' loomisel: $_" -ForegroundColor Red
            $failed++
        }
    }

    # ── Kokkuvõte ─────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "--------------------------------------" -ForegroundColor DarkGray
    Write-Host "  Valmis!  Loodud: $added  |  Vahele: $skipped  |  Vigu: $failed"
    Write-Host "--------------------------------------" -ForegroundColor DarkGray
}
