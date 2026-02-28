import Foundation

enum CatalogSeedLoader {
    static func loadSeedJson() -> String? {
        guard let fileUrl = Bundle.main.url(forResource: "CatalogSeed", withExtension: "json") else {
            return nil
        }
        return try? String(contentsOf: fileUrl, encoding: .utf8)
    }
}
