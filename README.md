# AI Portrait Editor

A SwiftUI-first, AI-powered portrait editor inspired by Prisma.  The app
combines on-device person segmentation, Core ML style transfer, Core Image
post-processing, and a polished SwiftUI surface to deliver real-time artistic
edits on iPhone and iPad.

> **Status:** Production-grade boilerplate.  All architecture, services,
> view-models, screens, localization, theming, and DI are wired up.  Style
> transfer falls back to a tasteful demo filter until you drop real
> `.mlmodel` files into the bundle (see *Adding ML models* below).

---

## Tech stack

| Layer            | Technology                                  |
|------------------|---------------------------------------------|
| UI               | SwiftUI (iOS 17+)                           |
| Architecture     | MVVM + Service-oriented                     |
| Dependency Inj.  | [Factory 2](https://github.com/hmlongco/Factory) (`@Injected`) |
| Computer vision  | `Vision` — `VNGeneratePersonSegmentationRequest` |
| AI / ML          | Core ML via `VNCoreMLRequest`               |
| Rendering        | Core Image (`CIFilter`, `CIBlendWithMask`)  |
| Photos           | PhotosUI (`PHPickerViewController`) + `Photos` |
| Animation        | [Lottie](https://github.com/airbnb/lottie-ios) |
| Haptics          | UIKit `UISelectionFeedbackGenerator`, etc.  |
| Localization     | String Catalog (`Localizable.xcstrings`), EN + RU |
| Theming          | Asset catalog semantic colors (Light & Dark)|
| Accessibility    | Dynamic Type, VoiceOver labels, large hit targets |

---

## Folder structure

```
AIPortraitEditor/
├── App/                   App entry point & root tab container
│   ├── AIPortraitEditorApp.swift
│   └── RootView.swift
├── Models/                Pure value types
│   ├── Style.swift
│   ├── SegmentMode.swift
│   ├── EditorState.swift  (incl. Adjustments, EditorPhase)
│   ├── GalleryAsset.swift
│   └── FeedPost.swift
├── Services/              All side-effectful work
│   ├── ImageSegmentationService.swift
│   ├── StyleManager.swift
│   ├── StyleTransferService.swift
│   ├── HapticsService.swift
│   ├── ImageExportService.swift
│   └── PhotoLibraryService.swift
├── ViewModels/            @MainActor ObservableObjects
│   ├── HomeViewModel.swift
│   ├── EditorViewModel.swift
│   ├── FeedViewModel.swift
│   └── SettingsViewModel.swift
├── Views/                 SwiftUI presentation
│   ├── Common/            PhotoPicker, ShareSheet, LottieView, …
│   ├── Home/              HomeView, GalleryGridView
│   ├── Editor/            EditorView + StyleSelector, SegmentToggle,
│   │                      IntensitySlider, AdjustmentsSheet
│   ├── Feed/              FeedView (cards, filters)
│   └── Settings/          SettingsView (appearance, haptics, legal)
├── DI/                    Factory container registrations
│   └── Container+Services.swift
├── Theme/                 Design tokens
│   ├── AppColors.swift
│   ├── AppTypography.swift
│   └── AppSpacing.swift
├── Extensions/            UIImage / CIImage / Color / View helpers
└── Resources/
    ├── Assets.xcassets    Semantic colors, AppIcon, AccentColor
    └── Localizable.xcstrings  EN + RU translations
```

---

## How to build

### Requirements

* **Xcode 15.2** or later (classic `PBXGroup` / explicit file references so the
  project opens in 15.x; String Catalog is supported from Xcode 15 onward)
* **iOS 17** deployment target
* macOS host with Apple Silicon or Intel

When you add new Swift files, add them to the **AIPortraitEditor** target in
Xcode (or extend `project.pbxproj` by hand) — there is no file-system–synced
group auto-including the whole folder.

### First open

1. Open `AIPortraitEditor.xcodeproj` in Xcode.
2. Xcode will resolve two Swift Package dependencies automatically:
   * **Factory** — `https://github.com/hmlongco/Factory.git` (>= 2.4)
   * **Lottie** — `https://github.com/airbnb/lottie-ios.git` (>= 4.4)
3. Select a simulator (iPhone 15+ recommended) or a connected device.
4. ⌘R.

The first launch lands on the **Studio** tab (Home), where you can pick a
photo to enter the **Editor**.  Switch tabs for **Feed** and **Settings**.

### Code signing

The project ships with `DEVELOPMENT_TEAM = ""` and automatic signing.
Either set your team in *Signing & Capabilities* or build to the simulator
where signing is not required.

---

## Architecture overview

```
            ┌──────────────────────┐
            │      SwiftUI Views   │
            │ (Home / Editor / …)  │
            └──────────┬───────────┘
                       │ @StateObject / @ObservedObject
                       ▼
            ┌──────────────────────┐
            │     ViewModels       │  @MainActor ObservableObject
            │ (state + commands)   │  uses @Injected(\.foo)
            └──────────┬───────────┘
                       │ protocols
                       ▼
            ┌──────────────────────┐
            │      Services        │  Stateless, testable
            │  Segmentation        │
            │  StyleManager        │  Loads .mlmodel(c)
            │  StyleTransfer       │  Vision + CIBlendWithMask
            │  Haptics, Export, …  │
            └──────────┬───────────┘
                       │ Factory container
                       ▼
            ┌──────────────────────┐
            │      System APIs     │
            │  Vision / CoreML /   │
            │  CoreImage / Photos  │
            └──────────────────────┘
```

### Service responsibilities

* **`ImageSegmentationService`** — wraps
  `VNGeneratePersonSegmentationRequest` and returns an alpha-mask
  `CIImage` aligned to the input photo's extent.
* **`StyleManager`** — finds bundled `.mlmodel(c)` files by name, compiles
  on first use, caches the `MLModel` instance.
* **`StyleTransferService`** — orchestrates the full pipeline:
  1. Run `VNCoreMLRequest` for style transfer
  2. Composite with mask using `CIBlendWithMask` (Portrait / Background / Both)
  3. Blend with original via alpha mask for intensity
  4. Apply `colorControls`, `temperatureAndTint`, and `vignette` adjustments
* **`HapticsService`** — wraps selection / impact / notification feedback.
* **`ImageExportService`** — renders `CIImage` → `UIImage`, writes to
  Photos library, exposes a share-sheet payload.
* **`PhotoLibraryService`** — `PHCachingImageManager`-backed gallery
  thumbnail and full-resolution loader.

### Dependency injection

All services are registered via Factory in
[`DI/Container+Services.swift`](AIPortraitEditor/DI/Container+Services.swift)
and injected with `@Injected(\.someService)`:

```swift
@MainActor
final class EditorViewModel: ObservableObject {
    @Injected(\.styleManager)       private var styleManager
    @Injected(\.segmentationService) private var segmentation
    @Injected(\.styleTransferService) private var styleTransfer
    @Injected(\.hapticsService)      private var haptics
    @Injected(\.imageExportService)  private var exporter
    // ...
}
```

For unit testing, override services at the start of your test:

```swift
Container.shared.styleManager.register { FakeStyleManager() }
Container.shared.segmentationService.register { FakeSegmenter() }
```

---

## Adding real ML models

The repo ships with a *demo stylisation* (monochrome + edges, tinted by
`Style.accent`) so the full pipeline can be exercised end-to-end without
shipping large binary assets.  To plug in real style-transfer models:

1. Train or download a model with input `image (224×224 BGRA)` and output
   `image (224×224 BGRA)`.  Apple's *Create ML* and
   [`StyleTransfer`](https://developer.apple.com/documentation/createml/mlstyletransfer)
   produce compatible models.
2. Name the `.mlmodel` to match a `Style.modelName` — e.g. `VanGoghStyle.mlmodel`.
3. Drag the file into Xcode and ensure it is a member of the `AIPortraitEditor`
   target.  Xcode compiles it to `VanGoghStyle.mlmodelc` automatically.
4. Run.  `StyleManager.isModelAvailable(_:)` will start returning `true` and
   `StyleTransferService` will pick the real model.

---

## Adding Lottie animations

`LottieView` looks up animations by name from the main bundle.  Two are
referenced today:

| File name             | Usage                                |
|-----------------------|--------------------------------------|
| `analyzing.json`      | While Vision is computing the mask   |
| `applying-style.json` | While Core ML is running             |

Drop the JSON files into
`AIPortraitEditor/Resources/Lottie/` (or anywhere inside the target) and
they'll be picked up automatically.  Until they're present a pure-SwiftUI
fallback pulse animation is shown — so the build *never* breaks just
because animation assets are missing.

---

## Localization

Strings live in
[`AIPortraitEditor/Resources/Localizable.xcstrings`](AIPortraitEditor/Resources/Localizable.xcstrings).
English is the source language; Russian (`ru`) is fully translated.

Add a language by opening the catalog in Xcode → press *+* in the bottom-
left to add a locale → fill the rows.  All `Text("some.key")` references in
SwiftUI use `LocalizedStringKey` automatically.

---

## Theming & accessibility

* All colors used by views come from
  [`Theme/AppColors.swift`](AIPortraitEditor/Theme/AppColors.swift) which
  references named entries in `Assets.xcassets` with both *Any* and
  *Dark* appearances.
* Typography goes through
  [`Theme/AppTypography.swift`](AIPortraitEditor/Theme/AppTypography.swift)
  and uses `.system(.style)` so it respects Dynamic Type up to the
  *accessibility3* size class (cap is set globally in `AIPortraitEditorApp`).
* The Settings screen exposes a **System / Light / Dark** picker that is
  persisted via `@AppStorage`.

---

## Project conventions

* No `@MainActor` annotations on services — they are usable from background
  tasks and surface their results via `async/await` continuations.
* ViewModels are `@MainActor` so all UI state mutations happen on main.
* Tests can replace any service via `Container.shared.X.register { ... }`
  without recompiling anything else.
* Files are organised by *role* (View / ViewModel / Service / Model) first
  and *feature* second.  When a feature gets large enough, promote it to
  its own subfolder under each role.

---

## Roadmap ideas

* On-device super-resolution before export.
* iCloud sync of saved presets.
* In-app camera capture with live style preview using `AVCaptureSession`
  and a `MTKView` for Metal rendering of CIImages.
* Sharing rendered images directly to the in-app Feed.

