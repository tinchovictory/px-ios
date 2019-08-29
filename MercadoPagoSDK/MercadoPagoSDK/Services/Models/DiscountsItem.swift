//
//  DiscountsItem.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct DiscountsItem: Decodable {

    private let icon: String
    private let title: String
    private let subtitle: String
    private let boldText: String
    private let target: String

    enum CodingKeys: String, CodingKey {
        case icon
        case title
        case subtitle
        case boldText = "bold_text"
        case target
    }
}
