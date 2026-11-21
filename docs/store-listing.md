# 36 Pics: store listing drafts

Draft copy and answers for Google Play and the App Store. Everything marked **[DECIDE]** or **[FILL]** needs your input before submission. Character counts are checked against each store's limit.

## Positioning

One roll. 36 shots. No scrolling back through hundreds of near-duplicates, and no peeking: a finished roll has to develop before you can see it. The app trades endless camera roll for the deliberate pace of film.

**Tagline options**
1. Shoot 36. Then wait.
2. One roll. Every shot counts.
3. The disposable camera, rebuilt.

---

## Google Play

| Field | Text | Limit |
|---|---|---|
| App name | `36 Pics: Film Roll Camera` (25) | 30 |
| Short description | `One roll, 36 shots. Shoot like film, then wait for it to develop.` (65) | 80 |
| Category | Photography | |
| Tags | Camera, Photography, Retro | |

**Full description** (under 4000 characters)

```
Shoot like it's film. One roll. 36 shots. Make every one count.

36 Pics is a minimal camera that brings back the discipline of a disposable film camera. Load a roll for your trip, shoot up to 36 exposures, then let it develop before you see a single photo. No retakes on a screen, no endless scrolling, no deleting a hundred near-duplicates. Just the moment.

HOW IT WORKS
• Load film: name your roll and pick a film stock.
• Shoot: a live viewfinder with tap to focus, pinch to zoom, flash, and front or back camera. A frame counter shows how many exposures you have left.
• Develop: when the roll is finished, it has to develop before you can look. You choose the wait, from 15 seconds up to a week. The countdown keeps running while the app is closed.
• Relive: developed rolls open as a grid of polaroid prints.

FILM STOCKS
• Classic: warm, contrasty, true colour.
• Noir: black and white with deep shadows.
• Faded '70s: low contrast, lifted shadows, a warm cast.
The look is baked into each photo as you shoot. Switch stock mid-roll if the light changes, and the roll is labelled Mixed.

MORE
• Abandon film: end a roll early and it develops with whatever you shot.
• Home shows the roll in your camera, anything still developing, and your latest rolls. The Rolls tab is your archive, filterable by status and film stock.
• Save to Photos: export a developed roll to your gallery as a new album or as plain photos, whenever you like.
• Two themes: Vintage, warm cream and brown like a photo album, and Darkroom, near-black with a safelight red.

PRIVATE BY DESIGN
Your photos stay on your device. 36 Pics has no accounts, no ads, no analytics and no internet connection. Photos are private to the app until you choose to save them.

Perfect for holidays, weekend trips, parties and anyone who wants to slow down and shoot with intention.
```

**What's new (v1.0):** `First release. Load a roll, shoot 36, let it develop.`

**Contact details to enter:** email [FILL], website [optional], privacy policy URL [FILL after hosting]

### Play Console declarations

| Section | Answer |
|---|---|
| App access | All functionality available without login or special access |
| Ads | No ads |
| Content rating (IARC) | No violence, sexual content, language, gambling, controlled substances, user-generated content shared with others, or location sharing. Expected rating: Everyone |
| Target audience | 13+ or 18+ **[DECIDE]**. Not directed at children, so avoid selecting under-13 age bands (selecting them triggers the Families policy) |
| News app / Health / Financial | No |
| Data safety: data collected | **None** |
| Data safety: data shared | **None** |
| Data safety: security practices | Data is not collected. Leave "data encrypted in transit" and "deletion request" as not applicable |
| Permissions declared | `CAMERA` (core feature: taking photos). `WRITE_EXTERNAL_STORAGE`, limited to Android 9 and below (saving exported photos to the gallery). No photo/video-read, location or microphone permissions |
| Advertising ID | Not used |

**Developer account note:** a new personal Play account must run a closed test (about 12 testers for 14 days) before production. Confirm the current rule in Play Console.

### Play graphics

| Asset | Spec | Status |
|---|---|---|
| App icon | 512 x 512 PNG, up to 1 MB | Source exists at 1024 px; export 512 |
| Feature graphic | 1024 x 500 PNG or JPG | **To create** |
| Phone screenshots | 2 to 8, 16:9 to 9:16, 320 to 3840 px per side | **Redo at full resolution.** The README screenshots are 480 px wide, too small |
| Tablet screenshots | Optional | Skip |

---

## App Store (iOS)

| Field | Text | Limit |
|---|---|---|
| Name | `36 Pics: Film Roll Camera` (25) | 30 |
| Subtitle | `36 shots. Then you wait.` (24) | 30 |
| Promotional text | `One roll. 36 shots. Shoot like film, let it develop, then relive every frame as a polaroid. No accounts, no ads, nothing leaves your phone.` (139) | 170 |
| Keywords | `film,camera,disposable,analog,retro,vintage,polaroid,35mm,roll,throwback,develop,nostalgia` (90) | 100 |
| Primary category | Photo & Video | |
| Secondary category | Lifestyle **[DECIDE]** | |
| Age rating | 4+ (no objectionable content) | |
| Copyright | `2026 [DEVELOPER NAME]` | |
| Support URL | [FILL] (required) | |
| Marketing URL | Optional | |
| Privacy Policy URL | [FILL after hosting] | |

**Description:** reuse the Play full description above. The App Store does not render bullets specially, but plain `•` lines read fine. Check that it is under 4000 characters.

**What's new:** `First release. Load a roll, shoot 36, let it develop.`

### App Privacy ("nutrition label")

Select **Data Not Collected**. The app has no network access, third-party SDKs, accounts or analytics. No tracking, so no App Tracking Transparency prompt is needed.

### Other App Store Connect answers

| Item | Answer |
|---|---|
| Export compliance | Already set: `ITSAppUsesNonExemptEncryption = false` (no encryption beyond the OS) |
| Sign-in required | No, so no demo account is needed |
| Content rights | You own or have rights to all content (all assets are yours or your own generated sample images) |
| Permissions strings (already in the app) | Camera, Photo Library (add only) |

### Notes for App Review (paste into "Review Notes")

```
36 Pics is a camera app that gives the user one roll of 36 photos, then makes the roll "develop" before it can be viewed. No account or login is needed.

To see the full flow quickly:
1. Tap the camera button, name a roll, choose a film stock, and tap Load Roll.
2. Allow camera access and take one or more photos.
3. Go back to Home and tap "Abandon film". The roll is sealed and develops in 5 seconds.
4. When it says "Your roll is ready", tap View Developed Roll to see the polaroid gallery.
5. Optionally tap Save to Photos to export (the app only asks for add-to-library access).

The normal develop wait can be changed under the person icon (You screen), from 15 seconds to 1 week.
The app collects no data and makes no network requests.
A physical device is needed to take photos, because the simulator has no camera.
```

### App Store screenshots

| Asset | Spec | Status |
|---|---|---|
| iPhone 6.9" | 1320 x 2868 (or 1290 x 2796), 1 to 10 images | **Redo.** Simulator `iPhone 17 Pro Max` is available |
| iPad 13" | 2064 x 2752, required **only if the app supports iPad** | See decision below |

---

## Decisions for you

1. **iPad support [DECIDE].** The project currently declares iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`) and allows landscape, but the UI was only designed and tested for iPhone portrait. Declaring iPad forces iPad screenshots and review of the iPad layout. Recommendation: **iPhone only** for v1, which is a one-line change.
2. **Developer name and contact email.** The policy and store pages are public, so use a name and address you are happy to publish. I left placeholders rather than reuse your private account details.
3. **Where to host the privacy policy.** It needs a public URL. Cheapest option is GitHub Pages from this repo (`docs/privacy-policy.md`), but that publishes under the repo's owner and makes the repo's docs folder public. Alternatives: a Notion or Google Sites page, or a personal domain.
4. **Target audience** (13+ or 18+) for the Play form.
5. **Short name** "36 Pics: Film Roll Camera" is a draft. A short, searchable name helps discovery; change it if you prefer plain "36 Pics" (the name must be unique on each store, so check availability before you commit).

## Next steps

1. Fill the placeholders, then host the policy and give me the URL.
2. I retake store screenshots at full resolution (Android emulator at 1080 x 2340, iPhone 6.9" simulator) from seeded sample rolls, and export the 512 px Play icon and a feature graphic.
3. Decide iPad, then enrol in the Apple Developer Program and Play Console.
