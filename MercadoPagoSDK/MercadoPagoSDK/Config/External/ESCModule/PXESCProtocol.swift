//
//  PXESCProtocol.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 25/09/2019.
//

import Foundation

/**
 Use this protocol to implement ESC functionality
 */
@objc public protocol PXESCProtocol: NSObjectProtocol {
    func getESC(config: PXESCConfig, cardId: String, firstSixDigits: String, lastFourDigits: String) -> String?
    @discardableResult func saveESC(config: PXESCConfig, cardId: String, esc: String) -> Bool
    @discardableResult func saveESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool
    func deleteESC(config: PXESCConfig, cardId: String)
    func deleteESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String)
    func getSavedCardIds(config: PXESCConfig) -> [String]
}
