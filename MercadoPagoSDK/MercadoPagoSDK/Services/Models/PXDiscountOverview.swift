//
//  PXDiscountOverview.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 01/07/2020.
//

import Foundation

public struct PXDiscountOverview: Codable {
    let title: PXText
    let subtitle: PXText?
    let amount: PXText
    let description: PXText?
    let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case amount
        case description
        case iconUrl = "icon_url"
    }
}
