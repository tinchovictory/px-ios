//
//  PXStatus.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 19/11/2019.
//

import Foundation

open class PXStatus: NSObject, Codable {
    let mainMessage: PXText?
    let secondaryMessage: PXText?
    let enabled: Bool

    enum CodingKeys: String, CodingKey {
        case mainMessage = "main_message"
        case secondaryMessage = "secondary_message"
        case enabled
    }
}
