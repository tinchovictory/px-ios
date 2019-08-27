//
//  PointsAndBenefits.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/08/2019.
//

import Foundation

//@objcMembers
struct PointsAndBenefits: Decodable {

    private let title: String?
    private let subtitle: String?
    private let image: String?
    private let benefits: [String]?

    init(title: String?, subtitle: String?, image: String?, benefits: [String]?) {
        self.title = title
        self.subtitle = subtitle
        self.image = image
        self.benefits = benefits
    }

    enum PointsAndBenefitsCodingKeys: String, CodingKey {
        case title
        case subtitle
        case image
        case benefits
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PointsAndBenefitsCodingKeys.self)
        let title: String? = try container.decodeIfPresent(String.self, forKey: .title)
        let subtitle: String? = try container.decodeIfPresent(String.self, forKey: .subtitle)
        let image: String? = try container.decodeIfPresent(String.self, forKey: .image)
        let benefits: [String]? = try container.decodeIfPresent([String].self, forKey: .benefits)

        self.init(title: title, subtitle: subtitle, image: image, benefits: benefits)
    }

    static func fromJSON(data: Data) throws -> PointsAndBenefits {
        return try JSONDecoder().decode(PointsAndBenefits.self, from: data)
    }
}
