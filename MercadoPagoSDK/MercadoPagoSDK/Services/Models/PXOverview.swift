//
//  PXOverview.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 01/07/2020.
//

import Foundation

public struct PXOverview: Codable, Equatable {

    let description: [PXText]
    let amount: PXText
    let brief: [PXText]?
    let iconUrl: String?

    enum CodingKeys: String, CodingKey {
        case description
        case amount
        case brief
        case iconUrl = "icon_url"
    }

    public static func == (lhs: PXOverview, rhs: PXOverview) -> Bool {
        return lhs.description == rhs.description && lhs.amount == rhs.amount && lhs.brief == rhs.brief && lhs.iconUrl == rhs.iconUrl
    }
}
