//
//  Discounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct Discounts: Decodable {

    private let title: String
    private let action: PointsAndDiscountsAction
    private let items: [DiscountsItem]

    enum CodingKeys: String, CodingKey {
        case title
        case action
        case items
    }
}
