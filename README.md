# Open Folder In

Adds an **Open Folder In** entry to the macOS right click menu, on a folder and on the
background of any Finder window. Hover it and your apps fly out, each with its own icon.
Click one and the folder opens in it — the same idea as *Open With* on a file, for the
folder you just clicked.

One app is the default. It comes first in the list and is marked, exactly the way the
Finder marks a file's default app.

The apps are yours. Add, rename, reorder or remove them in the app, no rebuild. Remove
every last one and the menu goes back to looking exactly like a stock macOS menu, as
though the app had never been installed.

It arrives with Terminal and Finder, which every mac has. Everything else is yours to
add.

## What it does

- **Add an app** three ways: from a dropdown of the apps this mac can already open a
  folder with — the mac's own answer, so an editor you installed this morning is in it —
  by choosing one out of your Applications folder, or by typing a bundle name yourself.
  The same dropdown is on the screen that edits an app, so an entry can be pointed
  somewhere else without being removed and added again. What you type is checked as you go: no spaces, no slashes or colons,
  and a bundle name has parts, as in `com.apple.Terminal`.
- **Pick a default.** It leads the menu and carries the mark. The same button takes it
  back off again, which leaves none picked, and none picked is a normal state. In
  settings, *Other…* reveals a second dropdown of every app this mac can open a folder
  with, so a default can be picked without going to add the app first — taking one from
  there adds it to your list on the way.

- **Search** your apps by name or by the name the mac knows them under.
- **Drag to reorder** them. The order in the list is the order in the menu.
- **Choose where the menu appears** — everywhere, or only in folders you pick. A folder
  you choose includes every folder inside it.
- **Export and import** your apps as a JSON file. Importing adds to your list, so
  nothing is lost. A file that cannot be read says so and changes nothing.
- **Lives in the menu bar.** Opening the window puts it in the dock; closing the window
  takes it back out and leaves it running. Quit is in the menu bar item.
- **Opens at login**, if you want it to.

An app you removed from `/Applications` still shows in the list, marked *Not installed*,
and says so rather than opening nothing. The menu bar also says when the menu is
switched off by your own settings — no folders chosen, or no apps left — because both
are allowed and both look exactly like the app being broken.

## Install

You need macOS 14 or newer, Xcode, [Homebrew](https://brew.sh), and an Apple developer
account — the free one is enough.

```sh
git clone <this repo> && cd os-right-click-open-folder-in-x
cp sample.env .env          # then put your team id in it, see below
make bootstrap              # installs xcodegen and swiftlint
make run                    # builds, installs, registers, restarts Finder
```

Then switch the extension on: **System Settings → General → Login Items & Extensions →
Extensions → Finder**. The app's menu bar item says so, with a button that takes you
there, until you do.

### Your team id

A Finder extension **must** be sandboxed, and a sandboxed extension can only reach the
app when both are signed by the same team. So the build needs your team id. Put it in
`.env`, which is never committed:

```sh
security find-identity -v -p codesigning
security find-certificate -c "Apple Development: YOUR NAME (XXXXXXXXXX)" -p \
  | openssl x509 -noout -subject      # the OU= field is your team id
```

Nothing else needs changing. The app reads the team back off its own signature at run
time, so no source file names one.

A team id is not a secret — it is in the signature of every app anyone ships. The thing
that must never leave your mac is the private key in your keychain, and nothing here
touches it.

## Commands

```sh
make run         # build, install to /Applications, register, restart Finder, launch
make test        # the test run. seconds, no Xcode needed
make lint        # swiftlint, and the spelling check
make diagnose    # is the extension registered and elected?
make clean
```

`make run` installs to `/Applications` and stops any copy already running first.
An extension run from anywhere else, or an old copy left running, is the usual reason a
change appears to do nothing.

## How it is put together

```
Open Folder In.app                   finder-extension.appex
not sandboxed                        sandboxed, because it must be
menu bar, window, login item         thin. builds the menu, forwards a click
** opens every folder **             reads the list, launches nothing
        |                                      ^
        | writes list, default, scope           | reads
        +---------> shared app group <---------+
```

The extension is not allowed to launch anything, so a click travels to the app as an
address and the app opens the folder. The shared folder is named after whoever signed
both halves, which the app reads off its own signature.

Everything it keeps is plain JSON in that folder, written to be read by a person:
`app-list.json`, `preferences.json`, `scope.json`.

| | |
|---|---|
| `Packages/OpenFolderIn` | Every decision, and all 240 tests. `swift test` needs no Xcode. |
| ┗ `…Shared` | The records. Imports nothing at all, so they read the same inside the sandbox as out. |
| ┗ `…Core` | The store everything subscribes to, which apps can open a folder, planning the menu, opening it. |
| ┗ `…UI` | The screens, each a view beside its view model. A view model imports no drawing framework, which is why its rules are tested. |
| `bundles/` | The app and the extension. They hold no decisions. |
| `project.yml` | The whole Xcode project. The `.xcodeproj` is generated, never committed. |
| `scripts/make-icon.sh` | Draws the app icon. It is code, not a picture. |
| `docs/CODE-RULES.md` | How the code here is written. |
| `docs/USAGE-LAWS.md` | What an assistant working in here may touch. |

No outside dependencies. Which apps can open a folder, what each one is called, its icon
and how to launch it are all `NSWorkspace`, which ships with the OS.

## Licence

GPL v3 — see [LICENSE](LICENSE). Ship a changed version and you publish your source too.
