import Foundation
import CoreML

/// Resolves `.mlmodel` resources at runtime and caches loaded `MLModel`
/// instances so we don't pay the compilation cost more than once.
///
/// Models are looked up by `Style.modelName` inside the app bundle.  Compiled
/// `.mlmodelc` directories are produced automatically when Xcode adds a
/// `.mlmodel` to the target.
protocol StyleManaging: AnyObject {
    var availableStyles: [Style] { get }
    func model(for style: Style) throws -> MLModel?
    func isModelAvailable(_ style: Style) -> Bool
}

enum StyleManagerError: LocalizedError {
    case modelNotFound(String)
    case loadingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .modelNotFound(let name):
            return "Style model '\(name)' is not bundled with the app."
        case .loadingFailed(let name, let error):
            return "Failed to load style model '\(name)': \(error.localizedDescription)"
        }
    }
}

final class StyleManager: StyleManaging {

    private let bundle: Bundle
    private let cacheQueue = DispatchQueue(label: "ai.portrait.style-manager", attributes: .concurrent)
    private var cache: [String: MLModel] = [:]

    let availableStyles: [Style]

    init(bundle: Bundle = .main, styles: [Style] = Style.builtIn) {
        self.bundle = bundle
        self.availableStyles = styles
    }

    func isModelAvailable(_ style: Style) -> Bool {
        guard let name = style.modelName else { return style.id == Style.none.id }
        return bundle.url(forResource: name, withExtension: "mlmodelc") != nil
            || bundle.url(forResource: name, withExtension: "mlmodel") != nil
    }

    func model(for style: Style) throws -> MLModel? {
        guard let name = style.modelName else { return nil }

        if let cached = cacheQueue.sync(execute: { cache[name] }) {
            return cached
        }

        let url: URL
        if let compiled = bundle.url(forResource: name, withExtension: "mlmodelc") {
            url = compiled
        } else if let source = bundle.url(forResource: name, withExtension: "mlmodel") {
            do {
                url = try MLModel.compileModel(at: source)
            } catch {
                throw StyleManagerError.loadingFailed(name, error)
            }
        } else {
            throw StyleManagerError.modelNotFound(name)
        }

        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let model = try MLModel(contentsOf: url, configuration: config)
            cacheQueue.async(flags: .barrier) { [weak self] in
                self?.cache[name] = model
            }
            return model
        } catch {
            throw StyleManagerError.loadingFailed(name, error)
        }
    }
}
