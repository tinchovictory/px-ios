//
//  Discounts.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct Discounts: Decodable {

    let title: String?
    let subtitle: String?
    let action: PointsAndDiscountsAction
    let actionDownload: DownloadAction
    let items: [DiscountsItem]

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case action
        case actionDownload = "action_download"
        case items
    }
}
