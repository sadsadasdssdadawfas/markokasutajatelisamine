# UserManager – Kohalike kasutajate haldus

Lihtne PowerShell tööriist, millega saad Windows arvutis luua ja kustutada kohalikke kasutajakontosid.

---

## Mis on kaasas

```
UserManager/
├── manage_users.ps1          ← Peaskript – käivita see
├── new_users_accounts.csv    ← Kasutajaandmed (eesnimi, perenimi, kasutajanimi, parool, kirjeldus)
├── Eesnimed.txt              ← Eesnimede loend (kasutatakse generate_users.ps1 jaoks)
├── Perenimed.txt             ← Perenimede loend
├── Kirjeldused.txt           ← Ametikohtade kirjeldused
└── functions/
    ├── Add-UsersFromCsv.ps1  ← Kasutajate lisamine CSV failist
    └── Remove-UserAccount.ps1 ← Kasutaja kustutamine
```

---

## Nõuded

- Windows 10 või uuem (või Windows Server 2016+)
- Windows PowerShell 5.1 või PowerShell 7+
- **Administraatori õigused** (skript kontrollib seda automaatselt)

---

## Käivitamine samm-sammult

### 1. Ava PowerShell administraatorina

Vajuta **Start**, otsi `PowerShell`, tee **paremklõps** ja vali **"Käivita administraatorina"**.

### 2. Liigu projekti kausta

Asenda tee enda kausta asukohaga:

```powershell
cd C:\Users\SinuNimi\Documents\UserManager
```

### 3. Luba skripti käivitamine (ainult esimesel korral)

Windows blokeerib vaikimisi allalaaditud skripte. Käivita see käsk üks kord:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Kui küsitakse kinnitust, sisesta `J` ja vajuta Enter.

### 4. Käivita peaskript

```powershell
.\manage_users.ps1
```

---

## Menüü valikud

Pärast käivitamist näed väikest menüüd:

```
======================================
   KOHALIKE KASUTAJATE HALDUS
======================================

  [1]  Lisa kasutajad CSV failist
  [2]  Kustuta kasutaja

  [X]  Välju
```

### Valik 1 – Lisa kasutajad CSV failist

Loeb `new_users_accounts.csv` failist kasutajad ja loob need Windowsi kohalike kontodena.

- Kui kasutaja on juba olemas, jäetakse ta vahele (ei kirjutata üle)
- Iga uus konto lisatakse automaatselt **Users** gruppi
- Kasutajale seatakse parool, mida tuleb **esimesel sisselogimisel vahetada**
- Lõpus kuvatakse kokkuvõte: loodud, vahele jäetud, vead

### Valik 2 – Kustuta kasutaja

Kuvab nimekirja kõigist kustutamiseks kõlblikest kasutajatest (süsteemikontosid ei kuvata).

- Sisesta kustutatava kasutaja **nimi täpselt nii nagu nimekirjas**
- Skript küsib **kinnitust** – pead sisestama `jah` enne kustutamist
- Kodukaust (`C:\Users\kasutajanimi`) jäetakse alles – kustuta see käsitsi soovi korral

---

## Kasutajaandmete fail (new_users_accounts.csv)

Fail kasutab **semikoolonit** (`;`) eraldajana ja on UTF-8 kodeeringus.

Veerud:

| Veerg | Kirjeldus |
|-------|-----------|
| `Eesnimi` | Kasutaja eesnimi |
| `Perenimi` | Kasutaja perenimi |
| `Kasutajanimi` | Windowsi kasutajanimi (väiketähed, ilma tühikuteta) |
| `Parool` | Algparool (kasutaja peab seda esimesel sisselogimisel vahetama) |
| `Kirjeldus` | Lühike kirjeldus kasutaja rollist |

Faili saad uuendada käsitsi (Notepad, Excel) või kasutada `generate_users.ps1` skripti uute juhuslike kasutajate genereerimiseks.

---

## Levinumad probleemid

**"Skripti käivitamine on keelatud"**
→ Käivita `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` (vt samm 3)

**"Skript vajab administraatori õigusi"**
→ Sulge PowerShell ja ava uuesti paremklõpsuga → "Käivita administraatorina"

**"CSV faili ei leitud"**
→ Kontrolli, et `new_users_accounts.csv` on samas kaustas kui `manage_users.ps1`

**Kasutaja jääb vahele (juba olemas)**
→ See on normaalne – olemasolevaid kasutajaid ei kirjutata üle

---

## Autor

Casper Daniel Treier
