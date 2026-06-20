# AzureGuessr

A Kahoot-style multiplayer geography game built on **Azure Static Web Apps** + **Firebase**.

Players join a room, study a **Street View panorama** (or satellite image), and compete to identify
the location — earning points for accuracy *and* speed, with a podium that grows every round.

**▶ Live:** https://thankful-mushroom-0e3dcd710.7.azurestaticapps.net

---

## Features

- **Synchronized multiplayer** — the host conducts; everyone plays the same location on the same round.
- **Game modes** — Classic, Progressive (confined Continent→Country→Region→City cascade), Country
  Streaks, Speed Run (20s), Battle Royale, Explorer, Mixed.
- **Real Street View** *(optional)* — add a Google Maps API key to swap the satellite clue for an
  interactive Street View panorama. Falls back to satellite automatically when no key is set.
- **Accuracy + speed scoring**, growing **podium**, player **avatars**, choosable **round count**.
- **Host controls** — view/reset scores, change mode/region/difficulty/rounds, copy room code / invite link.

---

## Architecture

```
Players ──> Azure Static Web App (game UI, global CDN)
               ├─ Firebase Anonymous Auth        (zero-friction join)
               ├─ Cloud Firestore                (real-time multiplayer sync)
               ├─ Leaflet + ESRI World Imagery   (satellite clue + guess map)
               └─ Google Street View  (optional) (panorama clue, bring-your-own key)
```

| Component | Service | Tier |
|-----------|---------|------|
| Hosting | Azure Static Web App | Free |
| Auth | Firebase Anonymous Auth | Spark (free) |
| Database | Cloud Firestore | Spark (free) |
| Satellite | ESRI World Imagery | Free |
| Street View | Google Maps JavaScript API | Bring-your-own key (Google's $200/mo free tier covers casual play) |

The whole game is a single static file (`index.html`) — no build step, no server.

---

## Reproduce it on your own Azure (azd)

You'll get your **own** Static Web App hosting a copy of the game. Two backing services are shared
SaaS you can keep or replace (see *Optional* below).

### Prerequisites
- [Azure Developer CLI (`azd`)](https://aka.ms/azd) and an Azure subscription
- (Login) `azd auth login`

### Deploy
```bash
git clone https://github.com/lproux/azuregeoguessr.git
cd azuregeoguessr
azd up
```
`azd up` provisions a resource group + Static Web App (see `infra/`) and uploads `index.html`.
When it finishes it prints the site URL (also exported as `AZUREGUESSR_URL`).

To tear everything down:
```bash
azd down
```

### What gets created
- `rg-<env>` resource group
- `swa-<token>` Azure Static Web App (Free SKU by default)

Override defaults via environment variables before `azd up`:
```bash
azd env set AZURE_STATICWEBAPP_LOCATION westeurope   # westus2 | centralus | eastus2 | westeurope | eastasia
azd env set AZURE_STATICWEBAPP_SKU      Free         # or Standard
```

### Optional — your own Firebase (multiplayer backend)
The repo ships with a demo Firebase project baked into `index.html`. For your own deployment:
1. Create a Firebase project, enable **Anonymous Authentication** and **Cloud Firestore**.
2. Replace the `firebaseConfig = {...}` object near the top of the `<script>` in `index.html`.
3. Add your Static Web App domain to Firebase **Authentication → Settings → Authorized domains**.

Solo play works without any Firebase changes.

---

## Enable Street View (optional)

Street View needs a Google Maps API key (client-side, like all Maps JS apps). No key = satellite mode.

1. In **Google Cloud Console → APIs & Services**, enable the **Maps JavaScript API**.
2. Create an **API key** under *Credentials*.
3. (Recommended) Restrict it to your site's domain (HTTP referrer) so it can't be reused elsewhere.
4. In the game, click **“Street View setup”** on the welcome screen, paste the key, and Save.
   The key is stored only in that browser's `localStorage`.

Other ways to supply the key (handy for kiosks/demos):
- URL: `?gmapsKey=YOUR_KEY`
- A global set before the app script: `window.AZG_GMAPS_KEY = "YOUR_KEY"`

If Google rejects the key, the game automatically reverts to satellite for the session.

---

## Deployment (this repo)

Pushes to `main` auto-deploy via GitHub Actions (`.github/workflows/deploy.yml`) using the
`AZURE_STATIC_WEB_APPS_API_TOKEN` secret. The `azd` path above is for spinning up an independent copy.

## License
MIT — see `LICENSE`.
