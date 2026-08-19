# LookMD

A tiny, native macOS app for viewing rendered Markdown.

- **Quick Look**: select a `.md`/`.markdown`/`.Rmd`/`.qmd` file in Finder and hit Space — the rendered page shows up right in the Quick Look panel.
- **Open normally**: double-click a file and it opens rendered (not as raw text).

No editing, no accounts, no network calls. Markdown is parsed locally with a bundled copy of [marked](https://github.com/markedjs/marked) (MIT licensed) inside a `WKWebView`, styled to match Finder's light/dark appearance.

R Markdown (`.Rmd`) and Quarto (`.qmd`) files are previewed as static documents: YAML frontmatter (title/author/date) renders as a header, prose renders normally, and code chunks show as plain syntax-highlighted blocks — nothing is executed, so plots/tables from `knitr`/Quarto rendering won't appear. That's deliberate: Quick Look previews can trigger just from arrow-key-browsing a folder in Finder, so silently running R/Python from arbitrary files would be a real footgun.

## Install

Download the latest `LookMD.dmg` from [Releases](https://github.com/musikutiv/LookMD/releases), open it, and drag **LookMD** into **Applications**.

This build isn't signed with an Apple Developer ID (no paid developer account behind it), so macOS Gatekeeper will block the first launch with an "unidentified developer" warning. One-time fix, pick one:

- Right-click (or Control-click) `LookMD.app` in Applications → **Open** → **Open** again in the dialog. After this first launch it opens normally from then on.
- Or, in Terminal: `xattr -cr /Applications/LookMD.app`

To make it the default app for a given file type, either set it via Finder (right-click a file → Get Info → Open with → LookMD → Change All…), or:

```sh
brew install duti
duti -s com.musikutiv.lookmd net.daringfireball.markdown all      # .md / .markdown
duti -s com.musikutiv.lookmd com.musikutiv.lookmd.rmarkdown all   # .Rmd
duti -s com.musikutiv.lookmd com.musikutiv.lookmd.qmd all         # .qmd
```

## Project layout

- `LookMD/` — the SwiftUI app target (document viewer, registers as a handler for the markdown UTI).
- `LookMDQuickLook/` — the `QLPreviewingController` app extension embedded in the app, powers the Finder Quick Look panel.
- `Shared/` — rendering code and resources (`marked.min.js`, HTML/CSS template) used by both targets.
- `project.yml` — [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec; the source of truth for the `.xcodeproj`.
- `scripts/build-dmg.sh` — builds a Release app and packages it into `build/LookMD.dmg`.

## Building from source

```sh
brew install xcodegen   # once
xcodegen generate
xcodebuild -project LookMD.xcodeproj -scheme LookMD -configuration Release build
```

Or just open `LookMD.xcodeproj` in Xcode and run.

To build the same DMG that ships in Releases:

```sh
./scripts/build-dmg.sh
```

## Installing a local build

```sh
ditto build/Build/Products/Release/LookMD.app /Applications/LookMD.app
```
