//
//  DiscountsItem.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct DiscountsItem: Decodable {

    let icon: String
    let title: String
    let subtitle: String
    let action: PointsAndDiscountsAction?
    let campaingId: String?

    enum CodingKeys: String, CodingKey {
        case icon
        case title
        case subtitle
        case action
        case campaingId = "campaing_id"
    }
}
