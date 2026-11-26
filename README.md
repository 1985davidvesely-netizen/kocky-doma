# Kočky doma

Malá aplikace na telefon pro Oskara, Felixe a Heřmana. Zapisuje se v ní krmení, váha, léky a termíny očkování, odčervení a odblešení. Každá kočka může mít svou fotku. Každá kočka má kadící kalendář: kolikrát denně, kdy a jaké to bylo. Záznamy jde dodatečně upravit. U kočky, kterou sledovat nechcete, se kalendář vypne v nabídce Upravit → Sledovat záchod.

Je to statická webová stránka bez serveru a bez účtů. Všechna data i fotky zůstávají jen v prohlížeči telefonu, ve kterém se aplikace používá.

## Připomínky

Aplikace nemá server, takže připomínky posílá kalendář v telefonu. V okně **Léky** je tlačítko *⏰ Připomínat v kalendáři*. U očkování, odčervení a odblešení je tlačítko ⏰. Obojí vytvoří předvyplněnou událost v Google Kalendáři, případně soubor .ics pro jiný kalendář, a nastavit jde i opakování.

## Soubory

| Soubor | K čemu je |
|---|---|
| `index.html` | celá aplikace |
| `manifest.webmanifest`, `icon*.png`, `icon.svg` | instalace na plochu telefonu |
| `sw.js` | aplikace funguje i bez internetu |

## Zprovoznění

Aby šla aplikace přidat na plochu a fungovala i bez internetu, musí běžet přes **https**. Stačí statický hosting z gitu:

- **GitLab Pages**, funguje i pro soukromý repozitář. Do kořene repozitáře přidejte `.gitlab-ci.yml`:
  ```yaml
  pages:
    script: [ "mkdir -p public", "cp -r index.html manifest.webmanifest sw.js icon* public/" ]
    artifacts: { paths: [ public ] }
    only: [ main ]
  ```
- **GitHub Pages**: Settings → Pages → Deploy from branch. U soukromého repozitáře to vyžaduje placený plán.
- **Netlify / Cloudflare Pages**: připojit repozitář, bez build příkazu, publikovat kořen.

Adresa stránky bude veřejná, ale nejsou na ní žádná data. Ta jsou jen v telefonu.

## Na telefonu

1. Otevřete adresu stránky.
2. **iPhone (Safari):** Sdílet → *Přidat na plochu*. **Android (Chrome):** ⋮ → *Přidat na plochu* nebo *Instalovat aplikaci*.
3. Aplikaci pak spouštějte z ikony na ploše. Na iPhonu tak Safari data samo nemaže.

## Záloha

Dole v aplikaci je tlačítko **Stáhnout zálohu**. Vytvoří soubor `.json` se vším včetně fotek. Ten pak jde nahrát tlačítkem **Obnovit ze zálohy**, třeba na novém telefonu. Zálohu je dobré dělat jednou za čas, hlavně před výměnou telefonu.

## Úpravy

Po změně souboru zvyšte `VERSION` v `sw.js`, aby si telefon stáhl novou verzi.
