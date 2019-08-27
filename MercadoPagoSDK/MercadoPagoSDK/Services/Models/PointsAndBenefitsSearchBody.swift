//
//  PointsAndBenefitsSearchBody.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 26/08/2019.
//

import Foundation

struct PointsAndBenefitsSearchBody: Encodable {

    let receiptId: String?

    init(_ receiptId: String?) {
        self.receiptId = receiptId
    }

    enum PointsAndBenefSearchBodyCodingKeys: String, CodingKey {
        case receiptId = "receipt_id"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PointsAndBenefSearchBodyCodingKeys.self)
        try container.encodeIfPresent(self.receiptId, forKey: .receiptId)
    }

    func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }
}
