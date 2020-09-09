//
//  PXIssuer+Business.swift
//  MercadoPagoSDKV4
//
//  Created by Eden Torres on 30/07/2018.
//

import Foundation

extension PXIssuer {
    func getIssuerForTracking() -> [String: Any] {
        var issuerDic: [String: Any] = [:]
        issuerDic["id"] = id
        issuerDic["name"] = name
        return issuerDic
    }
}
