# LookMD

A tiny, native macOS app for viewing rendered Markdown.

- **Quick Look**: select a `.md`/`.markdown` file in Finder and hit Space — the rendered page shows up right in the Quick Look panel.
- **Open normally**: double-click a Markdown file and it opens rendered (not as raw text).

No editing, no accounts, no network calls. Markdown is parsed locally with a bundled copy of [marked](https://github.com/markedjs/marked) (MIT licensed) inside a `WKWebView`, styled to match Finder's light/dark appearance.

## Project layout

- `LookMD/` — the SwiftUI app target (document viewer, registers as a handler for the markdown UTI).
- `LookMDQuickLook/` — the `QLPreviewProvider` app extension embedded in the app, powers the Finder Quick Look panel.
- `Shared/` — rendering code and resources (`marked.min.js`, HTML/CSS template) used by both targets.
- `project.yml` — [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec; the source of truth for the `.xcodeproj`.

## Building

```sh
brew install xcodegen   # once
xcodegen generate
xcodebuild -project LookMD.xcodeproj -scheme LookMD -configuration Release build
```

Or just open `LookMD.xcodeproj` in Xcode and run.

## Installing locally

```sh
ditto build/Build/Products/Release/LookMD.app /Applications/LookMD.app
```

Then set it as the default Markdown viewer (optional):

```sh
brew install duti
duti -s com.musikutiv.lookmd net.daringfireball.markdown all
```
