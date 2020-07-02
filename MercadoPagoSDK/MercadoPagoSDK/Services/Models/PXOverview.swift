//
//  PXOverview.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 01/07/2020.
//

import Foundation

public struct PXOverview: Codable, Equatable {

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

    public static func == (lhs: PXOverview, rhs: PXOverview) -> Bool {
        return lhs.title == rhs.title && lhs.subtitle == rhs.subtitle && lhs.amount == rhs.amount && lhs.description == rhs.description && lhs.iconUrl == rhs.iconUrl
    }
}
