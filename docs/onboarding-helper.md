# Onboarding — Gig Upload Platform (for a club helper)

*One-page guide for a non-technical KUD Mladost helper who manages the
audio-upload portal during an event. No command line, no SSH, no
Terraform — just the web admin panel.*

---

## What this platform does

External performing clubs upload their gig audio files (MP3 / WAV) to a
private web page. Each club gets their own **upload link + PIN**, sees
only their own upload form, and can't see anyone else's files.

You — the admin helper — create those links, send them out, and
download the files before the event.

**Web address:** <https://multikulti-2026.kud-mladost.org>
**Login:** the admin account Dejan created for you. Bookmark this page.

---

## Your three recurring tasks

### 1. Create an upload link for a club (~1 minute per club)

1. Log in.
2. Click **"Reverse Share"** (top right) → **"New Reverse Share"**.
3. Fill in:

   | Field | What to put |
   |---|---|
   | Description | `<Club name> — Multikulti <year>` |
   | Max share size | `200 MB` |
   | Max use count | `5` |
   | Expiration | The day after the event |
   | Password | Click "generate" → 6-digit PIN |

4. Click **Create**.
5. **Copy the link** that appears. Write the club name + link + PIN into
   the shared spreadsheet.
6. Email the link + PIN to the club (template below).

### 2. Send the email (copy-paste template)

```
Betreff: Multikulti <YEAR> — Bitte Eure Auftritts-Audiodateien hochladen

Hallo <Vorname>,

vielen Dank, dass Ihr bei Multikulti <YEAR> auftretet!

Bitte ladet die Audiodateien für Euren Gig bis spätestens
<DATUM> über folgenden Link hoch:

🔗 <UPLOAD_URL>
PIN: <PIN>

Hinweise:
• Nur MP3 oder WAV-Dateien
• Max. 30 MB pro Datei, gesamt max. 200 MB
• Bitte in Reihenfolge benennen, z. B.:
  01_intro.mp3
  02_main.mp3
  03_outro.mp3

Bei Fragen einfach auf diese Mail antworten.

Beste Grüße
<Dein Name>
KUD Mladost
```

### 3. Download the files before the event

1. Log in.
2. Left sidebar → **"Shares"**.
3. For each club's uploaded share:
   - Click the share name.
   - Click **"Download all"** (downloads a ZIP).
   - Save into your event folder, named like `01_TanzclubWien.zip`.
4. After the event, you can delete the shares (trash icon) to clean
   up — but only after Dejan confirms.

---

## What to do if something goes wrong

| Problem | What to do |
|---|---|
| A club says "the link doesn't work" | Check the **Expiration** date — most likely expired. Create a new reverse share, send the new link. |
| A club says "it says wrong password" | The PIN is case-sensitive. Read it back to them character by character. If still wrong, regenerate the reverse share. |
| A club says "my file is too big" | Files must be **under 30 MB each** (and 200 MB total per club). Ask them to export the MP3 at a lower bitrate (192 kbps is plenty for stage playback). |
| The website doesn't load at all | Wait 2 minutes and try again. If still down, message Dejan — this is an infrastructure issue, not something you can fix in the UI. |
| You get an email saying "someone uploaded" but you can't find it | Hit **Shares** in the left sidebar and look for the most recent entry — it will be under the matching reverse share. |
| You accidentally deleted a reverse share | Don't panic. Message Dejan — there's a daily backup he can restore from. |

---

## What you should **not** do

- ❌ **Don't disable "Reverse shares" in settings.** That breaks the whole workflow.
- ❌ **Don't change the App URL or domain settings.**
- ❌ **Don't delete the admin user (yourself or Dejan).**
- ❌ **Don't share the admin password with anyone.** Each helper should get their own admin account if needed.
- ❌ **Don't approve uploads of file types other than MP3/WAV** without checking with Dejan first.

If you're unsure whether something is safe to click — it probably is, the system is well-isolated — but you can always ask first.

---

## Quick reference

| Thing | Where |
|---|---|
| Upload portal | <https://multikulti-2026.kud-mladost.org> |
| Admin login | top-right "Sign in" |
| Tracking spreadsheet | *(link to your shared sheet)* |
| Dejan's contact | dejan.diljkan@outlook.com |
| Infrastructure questions | Dejan only — don't try to fix it yourself |

---

*Last updated: <date>. Keep this page bookmarked. Print it if you want a paper copy at the event.*
