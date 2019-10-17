//
//  PXESCDefault.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 25/09/2019.
//

import Foundation

/**
 Default PX implementation of ESC for public distribution.
 */
final class PXESCDefault: NSObject, PXESCProtocol {
    func getESC(config: PXESCConfig, cardId: String, firstSixDigits: String, lastFourDigits: String) -> String? {
        return nil
    }

    func saveESC(config: PXESCConfig, cardId: String, esc: String) -> Bool {
        return false
    }

    func saveESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String, esc: String) -> Bool {
        return false
    }

    func deleteESC(config: PXESCConfig, cardId: String) {
        // Move along, nothing to see here
    }

    func deleteESC(config: PXESCConfig, firstSixDigits: String, lastFourDigits: String) {
        // Move along, nothing to see here
    }

    func getSavedCardIds(config: PXESCConfig) -> [String] {
        return []
    }
}
