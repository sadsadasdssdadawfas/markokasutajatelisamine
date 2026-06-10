function Remove-UserAccount {
    <#
    .SYNOPSIS
        Kustutab ühe kohaliku kasutajakonto koos kinnitusega.
    #>

    # Süsteemikontod, mida ei tohi kustutada
    $protectedAccounts = @(
        'Administrator', 'Guest', 'DefaultAccount', 'WDAGUtilityAccount'
    )
    $currentUser = [Environment]::UserName

    Clear-Host
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "   KUSTUTA KASUTAJA"                   -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""

    # ── Koosta nimekiri kustutamiseks kõlblikest kontodest ───────────────────
    try {
        $allUsers = Get-LocalUser -ErrorAction Stop |
                    Where-Object {
                        $_.Name -notin $protectedAccounts -and
                        $_.Name -ne $currentUser
                    } |
                    Sort-Object Name
    }
    catch {
        Write-Host "  VIGA: Kasutajate nimekirja lugemine ebaõnnestus: $_" -ForegroundColor Red
        return
    }

    if ($allUsers.Count -eq 0) {
        Write-Host "  Kustutamiseks sobivaid kasutajaid ei leitud." -ForegroundColor Yellow
        Write-Host "  (Süsteemikontod ja praegune kasutaja on kaitstud.)"
        return
    }

    # ── Kuva nimekiri ─────────────────────────────────────────────────────────
    Write-Host "  Olemasolevad kasutajad:" -ForegroundColor DarkGray
    Write-Host ""

    $i = 1
    foreach ($u in $allUsers) {
        $status = if ($u.Enabled) { 'aktiivne' } else { 'keelatud' }
        Write-Host ("  [{0,2}]  {1,-22} ({2})" -f $i, $u.Name, $status)
        $i++
    }

    Write-Host ""
    Write-Host "  [X]   Tühista ja mine tagasi"
    Write-Host ""

    # ── Kasutaja valik ────────────────────────────────────────────────────────
    $input = (Read-Host "  Sisesta kustutatava kasutaja nimi").Trim()

    if ($input -eq '' -or $input.ToUpper() -eq 'X') {
        Write-Host ""
        Write-Host "  Tühistatud." -ForegroundColor DarkGray
        return
    }

    # Kontrolli, kas sisestatud nimi on nimekirjas
    $target = $allUsers | Where-Object { $_.Name -eq $input }

    if (-not $target) {
        Write-Host ""
        Write-Host "  VIGA: Kasutajat '$input' ei leitud nimekirjast." -ForegroundColor Red
        Write-Host "  Kontrolli nime kirjaviisi (tõstutundlik ei ole, aga peab täpselt vastama)." -ForegroundColor Yellow
        return
    }

    # ── Kinnitus ──────────────────────────────────────────────────────────────
    Write-Host ""
    Write-Host "  !! Oled kustutamas kasutajat: $($target.Name)" -ForegroundColor Yellow
    Write-Host "  See toiming on püsiv ja seda ei saa tagasi võtta." -ForegroundColor Yellow
    Write-Host ""
    $confirm = (Read-Host "  Kas oled kindel? Sisesta 'jah' kinnitamiseks").Trim()

    if ($confirm.ToLower() -ne 'jah') {
        Write-Host ""
        Write-Host "  Tühistatud - kasutajat ei kustutatud." -ForegroundColor DarkGray
        return
    }

    # ── Kustuta konto ─────────────────────────────────────────────────────────
    try {
        Remove-LocalUser -Name $target.Name -ErrorAction Stop
        Write-Host ""
        Write-Host "  OK  Kasutaja '$($target.Name)' on edukalt kustutatud." -ForegroundColor Green

        # Kui kodukaust on olemas, teavita kasutajat (ei kustuta automaatselt)
        $homeFolder = "C:\Users\$($target.Name)"
        if (Test-Path $homeFolder) {
            Write-Host ""
            Write-Host "  MÄRKUS: Kodukaust jäeti alles: $homeFolder" -ForegroundColor DarkGray
            Write-Host "  Kui soovid selle kustutada, tee seda käsitsi File Exploreris." -ForegroundColor DarkGray
        }
    }
    catch {
        Write-Host ""
        Write-Host "  VIGA kustutamisel: $_" -ForegroundColor Red
        Write-Host "  Kontrolli, et kasutaja pole parasjagu sisse logitud." -ForegroundColor Yellow
    }
}
