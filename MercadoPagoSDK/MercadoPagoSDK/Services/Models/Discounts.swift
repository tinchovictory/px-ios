//
//  Discounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct Discounts: Decodable {

    let title: String
    let action: PointsAndDiscountsAction
    let items: [DiscountsItem]

    enum CodingKeys: String, CodingKey {
        case title
        case action
        case items
    }
}
