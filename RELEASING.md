# Releasing a NexLedger update

No GitHub needed. Three pieces:

1. **The installer file** (Windows `.exe`, Mac `.dmg`) kept somewhere with a download link (e.g. Google Drive: "Anyone with the link").
2. **Firebase Remote Config** (project `nexledger-9762c`) tells the app "a new version exists, here is the link". This is the "sign".
3. **The app** checks the sign when it starts (and in Settings → Check for Updates) and shows the "New Version Available" pop-up.

## Every release (when you fix a bug)

1. Fix the bug, run `flutter test`.
2. Raise the version in `pubspec.yaml`, e.g. `version: 1.0.9+10`
   (the part before `+` is what users see and what the update check compares; always raise the number after `+` too).
3. **Windows** (on a Windows computer):
   - `flutter build windows --release`
   - Copy `build\windows\x64\runner\Release\` into `scripts\Release\`
   - Open `scripts\nex_ledger_installer.iss` in Inno Setup → Build → Compile.
     The version is read from the exe automatically. Output: `scripts\Output\NexLedger_Setup_v1.0.9.x.exe`.
4. **Mac** (on the Mac):
   - `flutter build macos --release`
   - `hdiutil create -volname NexLedger -srcfolder build/macos/Build/Products/Release/nex_ledger.app -ov -format UDZO NexLedger_v1.0.9.dmg`
5. Upload the file(s) and copy each download link.
6. Firebase console → Remote Config → set these keys → **Publish changes**:

   | Key | Example |
   |---|---|
   | `latest_version` | `1.0.9` |
   | `release_notes` | `Fixed the GST total on purchase bills.` |
   | `download_url_windows` | link to the Windows installer |
   | `download_url_macos` | link to the Mac dmg |

7. Open an older copy of the app → Settings → Check for Updates. You should see the pop-up.

Tip for the client: always take a Backup (Settings) before updating.

## First-time warnings (unsigned app, nothing to pay)

- **Windows:** SmartScreen says "Windows protected your PC" → click **More info → Run anyway**.
- **Mac:** first time, **right-click the app → Open → Open**.

Paid code-signing certificates remove these; not needed to work.

## Keeping the client's data safe (important)

- The database lives in the OS app-data folder, not in the install folder, so installing a new version never touches it.
- **Never change** these, or the app will look in a new folder and the data will seem to vanish:
  - `windows/runner/Runner.rc` → `CompanyName` (`com.nexyra`) and `ProductName` (`nex_ledger`)
  - macOS bundle id `com.nexyra.nexLedger`
  - The `AppId` in `scripts/nex_ledger_installer.iss` (lets a new installer upgrade the old install)
- If a release changes a table, raise `AppDatabase.currentSchemaVersion` and add the migration step.
  Test it on a **copy** of a real database first.
- Before the app upgrades an older database it automatically saves a copy in
  `pre_update_backups/` next to the database (the newest 5 are kept). If an update ever goes wrong,
  that file can be restored.

## Maintenance switch

Remote Config `is_under_maintenance = true` (with `maintenance_title` / `maintenance_message`) shows a
"System Under Maintenance" screen on every copy that is online. Set it back to `false` to reopen.

---

# Licenses: one key per client company

Every client company gets its own **license key**. The app asks for it on first start, needs an
internet connection to start, and checks again about every 6 hours while it is open.
You manage everything from the **admin page** (works on your phone).

## One-time setup (about 20 minutes, all free)

1. **Firebase console** (`console.firebase.google.com`, project `nexledger-9762c`)
   → *Build → Firestore Database → Create database*. Choose **production mode** and a nearby
   location (e.g. `asia-south1`). The location cannot be changed later.
2. *Firestore Database → Rules*: open `firestore.rules` from this project, replace
   `YOUR-ADMIN-EMAIL@gmail.com` with the Google account you will sign in with, paste it all in,
   click **Publish**.
3. *Build → Authentication → Get started → Sign-in method → Google → Enable* (pick a support email).
   Under *Settings → Authorized domains* make sure `nexledger-9762c.web.app` is listed.
4. **Put the admin page online** (needs Node.js once: `npm install -g firebase-tools`, then `firebase login`):
   ```
   firebase deploy --only hosting
   ```
   The admin page is then at `https://nexledger-9762c.web.app/admin`.
5. Open that link on your phone, sign in, and bookmark it.

Check the rules once in *Firestore → Rules → Rules Playground*:
a *get* on `/licenses/ANYKEY` unauthenticated should be **allowed**, a *list* on `/licenses`
unauthenticated should be **denied**, and an *update* that changes `status` unauthenticated should be **denied**.

## Everyday use (admin page)

| I want to… | Do this |
|---|---|
| Add a client | **New client** → company name, computers allowed → *Create license key* → copy / send on WhatsApp. Give the client the key. |
| Block a client (not paid) | Open the client → type a message → **Block**. Their app locks completely (also Backup) within minutes. |
| Unblock | Open the client → **Unblock**. They tap *Try again*. |
| Maintenance for one client | Open the client → message → *Turn maintenance ON*. |
| Maintenance for everyone | **Everyone** card → *Turn maintenance ON for all*. |
| See who uses the app | The client list shows computers used, version and *last used*. A red "More computers than allowed" means the key is being shared. |
| Client has a new computer | Open the client → *Computers…* → **Remove** the old one (or raise *Computers allowed*). |
| Allow short offline work | **Everyone** card → hours offline (0 = must be online, the default). |

## How it behaves

- The app needs internet **to start**. Offline (and no grace hours set) it shows "Internet connection needed".
- The first computers to use a key (up to *Computers allowed*) are accepted; later ones are locked with
  "License already in use on another computer" and you can see their computer name on the admin page.
- A blocked client cannot open anything, including Backup, until unblocked. Their data stays safely on their computer.
- Running from the IDE (debug) skips the check. To try the real flow in debug:
  `flutter run -d macos --dart-define=FORCE_LICENSE=true`.

## Limits (be honest with yourself)

- Copies installed **before** this feature (v1.0.8 and older) have no license check. The old
  Remote Config `is_under_maintenance` switch is the only thing that stops them (it stops all of them).
- The check is done by the app itself (free plan, no server code). A very technical person could bypass
  it; it is built to stop normal clients, not experts.
- Restoring a backup on a second computer does not copy the license: the key and computer id live in
  `license.json` next to the database, outside it.
