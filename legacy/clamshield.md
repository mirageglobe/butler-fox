# clamshield (legacy)

status: dropped from butler-fox 2026-11-02. code is at tag `legacy-snapshot-20261102`.
restore: `git checkout legacy-snapshot-20261102 -- legacy/clamshield`

## what it was

an electron menubar (system tray) app, described in its package.json as "yet another opensource desktop ui for mac linux and windows based on clamav". version 1.0.1, window title "zenclam". author Jimmy MG Lim; README says Apache 2.0 copyright 2018, package.json says ISC (inconsistent). earlier source: github.com/mirageglobe/jsf. added to this repo 2026-05-10; since then only dependabot touched it (electron, brace-expansion, undici, semver bumps). **it never scanned anything**: no clamav call exists in the code. it is the tray-popup skeleton from the standard electron menubar tutorial, with the app shell and icons done and the function missing.

## files

- `main.js` (10 KB): on `ready`, creates a `Tray` from a base64 png data url (19 px, embedded in the file; a second, commented-out pdf-typed icon sits beside it) and a hidden `BrowserWindow` 300 x 350, frameless, not resizable, loading `index.html`. a tray click toggles the window. `showWindow()` positions it under the tray icon: x centred on the icon; on macOS y is the icon's bottom edge, on other platforms y is the icon's y plus ten icon heights. the window hides on blur unless devtools is open; cmd-click on the tray icon opens detached devtools in dev. an `ipcMain` handler for `show-window`. quits when all windows close, except on macOS. a `const assetsDir = path.join(__dirname, 'assets')` is declared but that folder never existed.
- `index.html`: title `zenclam`, a centred `<h1>zenclam</h1>`, loads the renderer with `require('./index')`.
- `index.js`: on `DOMContentLoaded` shows a `Notification('clamshield', {body: 'clamshield setup complete.'})` whose click sends `show-window` to the main process.
- `package.json`: `main: main.js`, script `start` = `electron .`, `test` is the npm placeholder; devDependencies `electron` (^42.11.16 now, bumped by dependabot; the original was electron of about 2018) and `electron-packager` (^15.4.0, never called by any script; it holds the open dependabot alerts on `extract-zip`, `got` and `minimatch`).
- `yarn.lock`, `.gitignore`, `.node-version` (`v14`, stale), `LICENSE` (Apache 2.0, 11 KB).
- `resources/`: the app icon set: `clamshield.svg` (2 KB) and `clamshieldmenu.png` with `.icns`, `.ico` and `.zip` variants (about 590 KB, mostly the .ico and .icns). the artwork cannot be rebuilt from this note; restore it from the tag if it matters.

## how it was run

per its README: install `n` (github.com/tj/n), `n auto` to pick the node version, then `yarn start`.

## current-electron caveats (read from the code and the engine check, not run)

- electron 42 requires node 22.12 or later: `yarn install` on node 20 fails the engine check, and `.node-version` saying 14 is stale. the electron 41 to 42 bump (butler-fox pr 30) was merged without running the app.
- the renderer uses `require(...)` in `index.html` and `index.js` with no `webPreferences`. modern electron defaults `nodeIntegration` to false and `contextIsolation` to true, so this would need a preload script (or the flags) to work on a current version.
- `window.openDevTools(...)` in `main.js` is an old call; the current form is `window.webContents.openDevTools(...)`.

## to rebuild it

keep the tray and popup shell as is (it is small), add a preload exposing two actions to the renderer, `scan(path)` and `update()`, backed by `child_process` calls to `clamscan` and `freshclam` (the scan flags and the update flow are written up in [clamshield-cli.md](clamshield-cli.md)), and show results in the popup. package with `@electron/packager` (the renamed `electron-packager`, same api). use the icon set from the tag.
