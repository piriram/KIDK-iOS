import Foundation
import CoreGraphics

struct KIDKCityLayoutConfig: Decodable {
    struct MapConfig: Decodable {
        let bgScale: Double
        let bgOffsetX: Double
        let bgOffsetY: Double
    }

    struct BuildingConfig: Decodable {
        let xRatio: Double
        let yRatio: Double
        let scale: Double
    }

    struct BuildingsConfig: Decodable {
        let home: BuildingConfig
        let school: BuildingConfig
        let mart: BuildingConfig
        let character: BuildingConfig?
    }

    let map: MapConfig
    let buildings: BuildingsConfig

    static let fallback = KIDKCityLayoutConfig(
        map: .init(bgScale: 1.0, bgOffsetX: 0, bgOffsetY: 0),
        buildings: .init(
            home: .init(xRatio: 0.0060, yRatio: 0.4447, scale: 1.173),
            school: .init(xRatio: 0.3964, yRatio: 0.7712, scale: 1.269),
            mart: .init(xRatio: 0.7781, yRatio: 0.2945, scale: 1.456),
            character: .init(xRatio: 0.20, yRatio: 0.38, scale: 1.0)
        )
    )

    static func loadFromBundle() -> KIDKCityLayoutConfig {
        guard let url = Bundle.main.url(forResource: "kidk_city_layout", withExtension: "json") else {
            return .fallback
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(KIDKCityLayoutConfig.self, from: data)
        } catch {
            #if DEBUG
            print("[KIDKCityLayoutConfig] load failed: \(error.localizedDescription)")
            #endif
            return .fallback
        }
    }
}
