//
//  PXPointsAndDiscounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/08/2019.
//

import Foundation

struct PXPointsAndDiscounts: Decodable {

    let points: Points?
    let discounts: Discounts?
    let crossSelling: [PXCrossSellingItem]?

    init(points: Points?, discounts: Discounts?, crossSelling: [PXCrossSellingItem]?) {
        self.points = points
        self.discounts = discounts
        self.crossSelling = crossSelling
    }

    enum PointsAndDiscountsCodingKeys: String, CodingKey {
        case points = "mpuntos"
        case discounts
        case crossSelling = "cross_selling"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PointsAndDiscountsCodingKeys.self)
        let points: Points? = try container.decodeIfPresent(Points.self, forKey: .points)
        let discounts: Discounts? = try container.decodeIfPresent(Discounts.self, forKey: .discounts)
        let crossSelling: [PXCrossSellingItem]? = try container.decodeIfPresent([PXCrossSellingItem].self, forKey: .crossSelling)
        self.init(points: points, discounts: discounts, crossSelling: crossSelling)
    }

    static func fromJSON(data: Data) throws -> PXPointsAndDiscounts {
        return try JSONDecoder().decode(PXPointsAndDiscounts.self, from: data)
    }
}
