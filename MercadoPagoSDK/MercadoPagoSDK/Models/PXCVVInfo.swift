//
//  PXCVVInfo.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 08/05/2020.
//

import Foundation

public struct PXCVVInfo: Codable {

    let title: String
    let message: String?
    let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case title
        case message
        case imageUrl = "image_url"
    }
}
