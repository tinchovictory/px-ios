//
//  PXTermsDto.swift
//  MercadoPagoSDKV4
//
//  Created by Federico Bustos Fierro on 25/06/2019.
//

import UIKit

public struct PXTermsDto: Codable  {
    let text: String
    let linkablePhrases: [PXLinkablePhraseDto]
    enum CodingKeys: String, CodingKey {
        case text
        case linkablePhrases = "linkable_phrases"
    }
}
