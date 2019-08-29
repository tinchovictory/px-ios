//
//  PointsProgress.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 28/08/2019.
//

import Foundation

struct PointsProgress: Decodable {

    let percentage: Double
    let pointsFrom: Int
    let pointsTo: Int

    enum CodingKeys: String, CodingKey {
        case percentage
        case pointsFrom = "points_from"
        case pointsTo = "points_to"
    }
}
