//
//  PXResultInfo.swift
//  MercadoPagoSDKV4
//
//  Created by Federico Bustos Fierro on 25/06/2019.
//

import UIKit

struct PXResultInfo {
    let title: String
    let subtitle: String
    let mainAction: PXLinkableAction
    let linkAction: PXLinkableAction
    enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case mainAction = "main_action"
        case linkAction = "link_action"
    }
}
