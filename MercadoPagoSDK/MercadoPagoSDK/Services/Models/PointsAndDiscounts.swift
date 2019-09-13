//
//  PointsAndDiscounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 22/08/2019.
//

import Foundation

struct PointsAndDiscounts: Decodable {

    let points: Points?
    let discounts: Discounts?

    init(points: Points?, discounts: Discounts?) {
        self.points = points
        self.discounts = discounts
    }

    enum PointsAndDiscountsCodingKeys: String, CodingKey {
        case points = "mpuntos"
        case discounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PointsAndDiscountsCodingKeys.self)
        let points: Points? = try container.decodeIfPresent(Points.self, forKey: .points)
        let discounts: Discounts? = try container.decodeIfPresent(Discounts.self, forKey: .discounts)
        self.init(points: points, discounts: discounts)
    }

    static func fromJSON(data: Data) throws -> PointsAndDiscounts {
        return try JSONDecoder().decode(PointsAndDiscounts.self, from: data)
    }
}
