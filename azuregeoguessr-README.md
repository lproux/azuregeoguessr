# AzureGuessr

A Kahoot-style multiplayer geography guessing game built on Azure + Firebase.

Players join a room, see satellite imagery, and compete to identify locations by continent, country, province/state, and city -- earning points for accuracy and speed.

## Live Demo

**[Play AzureGuessr](https://thankful-mushroom-0e3dcd710.7.azurestaticapps.net)**

## What's new (FY26 culture-team build)

- **Synchronized multiplayer** — the host conducts the game; everyone plays the **same location on the same round at the same time** (authoritative Firestore room state). No more players landing on different places.
- **Player avatars** — each player gets an emoji icon shown in the lobby, scoreboards, podium, and on the map.
- **Growing podium** — a top-3 podium appears after every round; scores accumulate across the whole game and the highest total wins.
- **Accuracy + speed scoring** — a fast *and* close guess scores the most; results show the accuracy and speed-bonus split.
- **Instructions + 3-2-1 countdown** — a pre-game instructions panel with a worked example, followed by a synced countdown before round 1.
- **On-map instructions** — each round shows a short, mode-aware hint banner on the map.
- **Upbeat between-round music** — an upbeat procedural soundtrack (toggle with the speaker button or `M`).
- **Bigger guess map** and **mid-game join** (late joiners start at 0 and drop into the current round).

## Architecture

```
Players --> Azure Static Web App (game UI, globally distributed CDN)
               |
               +--> Firebase Anonymous Auth (zero-friction join)
               +--> Cloud Firestore (real-time multiplayer sync)
               +--> Leaflet + ESRI Satellite Tiles (map imagery)
```

### Infrastructure
| Component | Service | Tier | Region |
|-----------|---------|------|--------|
| Hosting | Azure Static Web App | Free | Global CDN |
| Auth | Firebase Anonymous Auth | Spark (free) | - |
| Database | Cloud Firestore | Spark (free) | eur3 (Europe) |
| Maps | ESRI World Imagery | Free | Global |

## How to Play

### Multiplayer
1. Open the game URL in your browser
2. Enter your display name
3. **Host**: Click "Host Game" to create a room (you'll get a 4-char code like `ABCD`)
4. **Players**: Click "Join Game" and enter the room code
5. Host selects a mode and clicks "Start Game"
6. Everyone sees the same satellite view -- guess the location!

### Solo Practice
Click "Solo Practice" from the welcome screen for single-player mode with localStorage high scores.

## Game Modes

| Mode | Rounds | Timer | Best For |
|------|--------|-------|----------|
| Classic | 5 | 30s | Team meetings, casual play |
| Marathon | 10 | 30s | Geography buffs, longer sessions |
| Speed | 5 | 10s | Quick energy breaks, competitive |

## Scoring System

Each round awards up to **5,000 points** based on progressive identification:

| Level | Base Points | Speed Bonus | Max |
|-------|------------|-------------|-----|
| Continent | 500 | +500 | 1,000 |
| Country | 750 | +750 | 1,500 |
| Province/State | 750 | +500 | 1,250 |
| City | 750 | +500 | 1,250 |
| **Total** | | | **5,000** |

### Multipliers
- **3-round streak** (all 4 levels correct): **2x** multiplier
- **5+ round streak**: **3x** multiplier
- Speed bonus scales linearly: `speedBonus * (timeRemaining / totalTime)`

### Answer Matching
- Case-insensitive
- Common aliases accepted: UK = United Kingdom, USA = United States, UAE = United Arab Emirates
- Fuzzy matching via Levenshtein distance (threshold: 2 edits for short names, 3 for longer)

## Locations

80+ curated locations across all continents:
- **Europe** (25+): Paris, London, Rome, Berlin, Dublin, Stockholm, Prague...
- **Asia** (15+): Tokyo, Seoul, Beijing, Dubai, Mumbai, Singapore...
- **Africa** (10+): Cairo, Cape Town, Nairobi, Lagos, Casablanca...
- **North America** (12+): New York, San Francisco, Toronto, Mexico City...
- **South America** (8+): Rio, Buenos Aires, Santiago, Lima, Bogota...
- **Oceania** (5+): Sydney, Melbourne, Auckland, Wellington...
- **Azure Datacenters** (15): West US, East US, North Europe, West Europe, Japan East...

## Feature Bank (Future Ideas)

Inspired by Kahoot, Quizlet, Anki, Chegg, and Course Hero:

### Gameplay
- Team mode (split players into teams)
- Ghost mode (play against your previous scores)
- Tournament brackets (elimination rounds)
- Daily challenge with global leaderboard

### Learning
- Flashcard study mode (spaced repetition)
- Difficulty-adaptive learning paths
- Location wiki (learn about each place after guessing)
- Step-by-step geography explanations

### Social
- Challenge friends (invite links)
- Custom location packs (upload your own)
- Crowdsourced hints and tips per location
- Achievement badges and XP levels

### Analytics
- Heat map of player accuracy by region
- Per-player accuracy reports
- Question difficulty analysis
- Retention rate and study time stats

## Tech Stack

- **Frontend**: Vanilla HTML/CSS/JS (zero build step, single file)
- **Maps**: Leaflet.js + ESRI World Imagery satellite tiles
- **Auth**: Firebase Anonymous Authentication
- **Real-time DB**: Cloud Firestore with onSnapshot listeners
- **Audio**: Web Audio API (oscillator-based, no external files)
- **Animations**: Pure CSS (confetti, timer ring, point popups)
- **Hosting**: Azure Static Web App (Free tier, global CDN)

## Local Development

No build step required. Just open `index.html` in a browser:

```bash
# Clone
git clone https://github.com/lp-roux/azuregeoguessr.git
cd azuregeoguessr

# Open directly
open index.html

# Or serve locally
python3 -m http.server 8080
```

## Deploy to Azure Static Web App

```bash
# Install SWA CLI
npm install -g @azure/static-web-apps-cli

# Deploy
swa deploy . --deployment-token <YOUR_TOKEN>
```

## Firebase Setup

The game uses a Firebase project called `azureguessr` with:
- Anonymous Authentication enabled
- Cloud Firestore in test mode (eur3 region)
- Web app registered as "AzureGuessr Web"

To use your own Firebase:
1. Create a project at console.firebase.google.com
2. Enable Anonymous Auth
3. Create Firestore database
4. Replace the `firebaseConfig` object in `index.html`

## License

MIT

---

Built with Azure + Firebase for the Microsoft EMEA SMB team.
