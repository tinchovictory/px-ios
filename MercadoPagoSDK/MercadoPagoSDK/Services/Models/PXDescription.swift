//
//  PXDescription.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 08/07/2020.
//

import Foundation

struct PXDescription: Codable {

    let title: PXText
    let subtitle: PXText?
    let badge: PXDiscountInfo?
    let summary: PXText
    let description: PXText
    let legalTerms: PXDiscountInfo

    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case badge
        case summary
        case description
        case legalTerms = "legal_terms"
    }
}
