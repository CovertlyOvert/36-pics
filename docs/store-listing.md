# 36 Pics: store listing drafts

Copy and form answers for Google Play and the App Store. Character counts are checked against each store's limit. Items still open are marked **[OPEN]**; the privacy and support URLs are proposed and not live until the site in [Hosting](#hosting-the-policy-and-support-pages) is deployed.

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

**Contact details to enter:** email `support@toormai.com`, website `https://36pics.toormai.com`, privacy policy URL `https://36pics.toormai.com/privacy` (all proposed until the site is live)

### Play Console declarations

| Section | Answer |
|---|---|
| App access | All functionality available without login or special access |
| Ads | No ads |
| Content rating (IARC) | No violence, sexual content, language, gambling, controlled substances, user-generated content shared with others, or location sharing. Expected rating: Everyone |
| Target audience | **13 and over** (decided). Not directed at children, so do not select any under-13 age band (that triggers the Families policy) |
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
| App icon | 512 x 512 PNG, up to 1 MB | Done: [`store-assets/android/play_icon_512.png`](../store-assets/android/play_icon_512.png) |
| Feature graphic | 1024 x 500 PNG or JPG | Done: [`store-assets/android/play_feature_graphic_1024x500.png`](../store-assets/android/play_feature_graphic_1024x500.png) |
| Phone screenshots | 2 to 8; each side 320 to 3840 px, long side no more than 2x the short side (confirm in Play Console, the rule has changed before) | Done: 8 at 1080 x 2160 (exactly 2:1) in [`store-assets/android/`](../store-assets/android/) |
| Tablet screenshots | Optional | Skip for v1 |

---|---|---|
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
| Secondary category | Lifestyle **[OPEN]** | |
| Age rating | 4+ (no objectionable content) | |
| Copyright | `2026 Ankit Anurag` | |
| Support URL | `https://36pics.toormai.com/support` (proposed, required) | |
| Marketing URL | Optional | |
| Privacy Policy URL | `https://36pics.toormai.com/privacy` (proposed) | |

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
| iPhone 6.9" | 1320 x 2868, 1 to 10 images, PNG or JPG, no alpha | Done: 8 in [`store-assets/ios/`](../store-assets/ios/) (iPhone 17 Pro Max simulator) |
| iPad | Not needed: the app is now iPhone-only | n/a |

**Screenshot order (same on both stores):** 01 Home, 02 Rolls archive, 03 Gallery, 04 Developing, 05 Load New Film, 06 to 08 Darkroom theme (Home, Rolls, Gallery). All use generated sample photos; the status bar reads the real time so the develop countdown and "ready at" time agree. If you want captions or device frames for the store pages, that is a design pass on top of these.

---|---|---|
| iPhone 6.9" | 1320 x 2868 (or 1290 x 2796), 1 to 10 images | **Redo.** Simulator `iPhone 17 Pro Max` is available |
| iPad 13" | 2064 x 2752, required **only if the app supports iPad** | See decision below |

---

## Decisions made

| Question | Decision |
|---|---|
| Developer name and public contact | Ankit Anurag. Public addresses are forwarding aliases `privacy@toormai.com` (policy) and `support@toormai.com` (support page and store forms), so the personal inbox is not published |
| iPad | iPhone only. `TARGETED_DEVICE_FAMILY` is now `1` and the iPad orientation list is removed |
| Play target audience | 13 and over |
| Privacy policy hosting | Recommended below (your call) |

## Hosting the policy and support pages

You own `toormai.com` (registered with Cloudflare) and plan a portfolio there. **Recommendation: serve the app pages from a subdomain, `36pics.toormai.com`, on Cloudflare Pages.**

| Option | Verdict |
|---|---|
| **Cloudflare Pages on `36pics.toormai.com`** | **Best.** Free. The domain's DNS is already at Cloudflare, so attaching a custom domain is two clicks and needs no DNS edits. The URL is permanent and survives the portfolio being built later, and it does not point at your GitHub alias. Keeps `toormai.com` itself free for the portfolio |
| A path on the future portfolio (`toormai.com/36pics/privacy`) | Works, but the stores need the URL live before submission, and it ties the app's compliance page to the site you have not built yet |
| GitHub Pages | Free and simple, but the URL is `github.io` unless you also configure DNS, and it publishes from the repo your handle owns |
| Google Sites / Notion | Fine for a stopgap, but the URL is not on your domain and can change |

**The site is built.** `site/` has the landing, `/privacy` and `/support` pages. It is plain static HTML with no build step on Cloudflare. The privacy page is generated from `docs/privacy-policy.md`, so edit the policy there and run `python3 tools/build_site.py` to regenerate. The site makes no third-party requests (fonts and images are self-hosted) and ships strict security headers in `site/_headers`.

**Your setup (about 15 minutes, needs your Cloudflare login). Do the email first: the policy and support page publish addresses that must work.**

1. **Email forwarding.** Cloudflare dashboard, `toormai.com`, Email, Email Routing, Enable (this adds the MX and SPF records for you). Add your Gmail as a destination address and click the verification link Cloudflare sends. Then add two custom addresses, `privacy@toormai.com` and `support@toormai.com`, both forwarding to that Gmail. Send a test mail to each.
2. **Pages project.** Workers & Pages, Create, Pages, Connect to Git, pick `36-pics`. Production branch `main`, build command empty, build output directory `site`.
3. **Custom domain.** In that project, Custom domains, add `36pics.toormai.com`. DNS is created automatically because the zone is on Cloudflare.
4. **Check.** Open `https://36pics.toormai.com/`, `/privacy/` and `/support/`, then paste those URLs and `support@toormai.com` into the store forms.

Note that Pages deploys from `main`, so the site goes live only after this branch is merged. You can also use the project's preview URL on the branch before then.

Replying *from* `support@toormai.com` is not covered by Email Routing (it only receives). Reply from Gmail for now; Gmail's "Send mail as" with a Cloudflare-compatible SMTP service can be set up later if you want replies to come from the alias.

App Store Connect and Play Console also ask for a private account contact. That one can stay your Gmail, since the stores do not publish it.

## Next steps

1. Merge the PR, then do the four setup steps above (email first).
2. Enrol in the Apple Developer Program ($99/year) and the Google Play Console ($25 once).
3. Real-device Android test, then the Play closed test.
4. Secondary App Store category **[OPEN]**, and check that the name "36 Pics: Film Roll Camera" is free on both stores.
