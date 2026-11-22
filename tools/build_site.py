#!/usr/bin/env python3
"""Builds the static marketing/compliance site into site/.

    python3 tools/build_site.py

The privacy page is generated from docs/privacy-policy.md so the policy has a
single source of truth. Landing and support pages are defined below. Needs
only Pillow (for resizing screenshots) and the standard library.
"""
import html
import os
import re
import shutil

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SITE = os.path.join(ROOT, 'site')
BASE_URL = 'https://36pics.toormai.com'
PRIVACY_EMAIL = 'privacy@toormai.com'
SUPPORT_EMAIL = 'support@toormai.com'
DEVELOPER = 'Ankit Anurag'


# --- minimal markdown (only what docs/privacy-policy.md uses) ---------------

def inline(text):
    text = html.escape(text, quote=False)
    text = re.sub(r'`([^`]+)`', r'<code>\1</code>', text)
    text = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', text)
    text = re.sub(r'(?<![">\w])([\w.+-]+@[\w-]+\.[\w.-]+)', r'<a href="mailto:\1">\1</a>', text)
    return text


def markdown(md):
    out, para, items, rows = [], [], [], []

    def flush():
        nonlocal para, items, rows
        if para:
            out.append('<p>' + '<br>\n'.join(inline(l) for l in para) + '</p>')
        if items:
            out.append('<ul>' + ''.join(f'<li>{inline(i)}</li>' for i in items) + '</ul>')
        if rows:
            head, body = rows[0], rows[2:]
            out.append('<div class="table"><table><thead><tr>' + ''.join(f'<th>{inline(c)}</th>' for c in head)
                       + '</tr></thead><tbody>' + ''.join('<tr>' + ''.join(f'<td>{inline(c)}</td>' for c in r) + '</tr>' for r in body)
                       + '</tbody></table></div>')
        para, items, rows = [], [], []

    for line in md.splitlines():
        s = line.rstrip()
        if not s:
            flush()
        elif s.startswith('# '):
            flush(); out.append(f'<h1>{inline(s[2:])}</h1>')
        elif s.startswith('## '):
            flush(); out.append(f'<h2>{inline(s[3:])}</h2>')
        elif s.startswith('- '):
            if para or rows:
                flush()
            items.append(s[2:])
        elif s.startswith('|'):
            if para or items:
                flush()
            rows.append([c.strip() for c in s.strip('|').split('|')])
        else:
            if items or rows:
                flush()
            para.append(s)
    flush()
    return '\n'.join(out)


# --- page template ----------------------------------------------------------

def page(path, title, description, body, depth):
    up = '../' * depth
    canonical = BASE_URL + ('/' + path if path else '/')
    return f'''<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(description)}">
<link rel="canonical" href="{canonical}">
<link rel="icon" type="image/png" href="{up}img/icon-192.png">
<link rel="apple-touch-icon" href="{up}img/icon-192.png">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(description)}">
<meta property="og:image" content="{BASE_URL}/img/icon-512.png">
<meta name="theme-color" content="#FAF3E0">
<link rel="stylesheet" href="{up}style.css">
</head>
<body>
<header class="top">
  <a class="brand" href="{up or './'}"><img src="{up}img/icon-192.png" alt="" width="36" height="36"><span>36 Pics</span></a>
  <nav><a href="{up}support/">Support</a><a href="{up}privacy/">Privacy</a></nav>
</header>
<main>
{body}
</main>
<footer>
  <p>&copy; 2026 {DEVELOPER}. 36 Pics collects no data.</p>
  <p><a href="{up}privacy/">Privacy policy</a> &middot; <a href="{up}support/">Support</a></p>
</footer>
</body>
</html>
'''


LANDING = '''
<section class="hero">
  <img class="icon" src="img/icon-512.png" alt="36 Pics app icon" width="160" height="160">
  <h1>One roll. 36 shots.<br>Then you wait.</h1>
  <p class="lede">36 Pics is a camera that brings back the discipline of a disposable film camera.
  Load a roll, shoot up to 36 exposures, and let it develop before you see a single photo.</p>
  <p class="soon">Coming soon to the App Store and Google Play.</p>
</section>

<section class="shots" aria-label="Screenshots">
  <img src="img/home.jpg" alt="Home screen showing the roll in the camera and a roll developing" width="270" height="587" loading="lazy">
  <img src="img/gallery.jpg" alt="A developed roll shown as polaroid prints" width="270" height="587" loading="lazy">
  <img src="img/developing.jpg" alt="Countdown while a roll develops" width="270" height="587" loading="lazy">
  <img src="img/darkroom.jpg" alt="Home screen in the Darkroom theme" width="270" height="587" loading="lazy">
</section>

<section class="cols">
  <div>
    <h2>Load, shoot, develop, relive</h2>
    <p>Name a roll and pick a film stock. Shoot with a live viewfinder, then wait. You choose how long a roll
    takes to develop, from 15 seconds to a week, and the countdown keeps running while the app is closed.</p>
  </div>
  <div>
    <h2>Three film stocks</h2>
    <p><strong>Classic</strong> is warm and contrasty. <strong>Noir</strong> is black and white with deep shadows.
    <strong>Faded &rsquo;70s</strong> is low contrast with a warm cast. The look is baked into each photo as you shoot,
    and you can switch stock mid-roll.</p>
  </div>
  <div>
    <h2>Two themes</h2>
    <p><strong>Vintage</strong> is cream and brown, like a photo album. <strong>Darkroom</strong> is near-black with
    a safelight red.</p>
  </div>
  <div>
    <h2>Private by design</h2>
    <p>No accounts, no ads, no analytics and no internet connection. Your photos stay on your device until you
    choose to save them to your library. <a href="privacy/">Read the privacy policy</a>.</p>
  </div>
</section>
'''

SUPPORT = f'''
<h1>Support</h1>
<p>Questions, bugs or feedback about 36 Pics? Email <a href="mailto:{SUPPORT_EMAIL}">{SUPPORT_EMAIL}</a>.
Please include your phone model and OS version, and what you were doing when something went wrong.</p>

<h2>Common questions</h2>

<h3>Where are my photos?</h3>
<p>Photos you take are stored privately inside the app, on your device only. They do not appear in your Photos or
Gallery until you open a developed roll and tap <strong>Save to Photos</strong>.</p>

<h3>Why can&rsquo;t I see my roll yet?</h3>
<p>A finished roll has to develop first, like film. You choose the wait on the <strong>You</strong> screen
(the person icon on Home and Rolls), from 15 seconds to 1 week. A new setting applies to rolls you finish from then on.
Want to see a roll sooner? Use <strong>Abandon film</strong> on Home to end a roll early; it develops in 5 seconds.</p>

<h3>Can I change the film stock?</h3>
<p>Yes. Pick a starting stock when you load a roll, and switch between Classic, Noir and Faded &rsquo;70s from the camera
at any time. A roll shot on more than one stock is labelled Mixed.</p>

<h3>How do I delete a roll?</h3>
<p>Press and hold the roll in the Rolls tab and confirm. This removes the roll and its photos from the app.
Copies you already saved to Photos or Gallery stay there until you delete them yourself.</p>

<h3>Can I get a deleted roll or photo back?</h3>
<p>No. Everything lives only on your device, so there is no copy for us to restore. If you want to keep a roll, save it
to Photos first.</p>

<h3>Do I need an internet connection or an account?</h3>
<p>No. 36 Pics works fully offline and has no accounts.</p>

<h3>What happens to my rolls if I delete the app?</h3>
<p>They are removed with it. Save anything you want to keep to Photos or Gallery first.</p>

<h2>Contact</h2>
<p>{DEVELOPER}<br><a href="mailto:{SUPPORT_EMAIL}">{SUPPORT_EMAIL}</a></p>
'''


def build():
    for sub in ('privacy', 'support', 'img', 'fonts'):
        os.makedirs(os.path.join(SITE, sub), exist_ok=True)

    # images
    icon = Image.open(os.path.join(ROOT, 'assets/icon/icon.png')).convert('RGB')
    for size in (192, 512):
        icon.resize((size, size), Image.LANCZOS).save(os.path.join(SITE, f'img/icon-{size}.png'), optimize=True)
    shots = {'home': '01_home', 'gallery': '03_gallery', 'developing': '04_developing', 'darkroom': '06_home_darkroom'}
    for name, src in shots.items():
        im = Image.open(os.path.join(ROOT, f'store-assets/ios/{src}.png')).convert('RGB')
        im = im.resize((540, round(im.height * 540 / im.width)), Image.LANCZOS)
        im.save(os.path.join(SITE, f'img/{name}.jpg'), quality=84, optimize=True)

    # fonts (self-hosted: the site makes no third-party requests)
    for f in ('PlayfairDisplay-Regular.ttf', 'CourierPrime-Regular.ttf'):
        shutil.copy(os.path.join(ROOT, 'assets/fonts', f), os.path.join(SITE, 'fonts', f))

    with open(os.path.join(ROOT, 'docs/privacy-policy.md'), encoding='utf-8') as fh:
        privacy = markdown(fh.read())

    pages = [
        ('index.html', '', '36 Pics: one roll, 36 shots', 'A minimal film-style camera. Shoot one roll of 36, let it develop, then relive it. No accounts, no ads, no tracking.', LANDING, 0),
        ('privacy/index.html', 'privacy/', 'Privacy Policy: 36 Pics', '36 Pics does not collect your data. Your photos and rolls stay on your device.', f'<article class="doc">{privacy}</article>', 1),
        ('support/index.html', 'support/', 'Support: 36 Pics', 'Help and contact for 36 Pics.', f'<article class="doc">{SUPPORT}</article>', 1),
    ]
    for rel, path, title, desc, body, depth in pages:
        with open(os.path.join(SITE, rel), 'w', encoding='utf-8') as fh:
            fh.write(page(path, title, desc, body, depth))
        print('wrote', rel)


if __name__ == '__main__':
    build()
