//
//  PXCustomTranslationKey.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/28/19.
//

import Foundation

// Only for MoneyIn custom verb support.
/// :nodoc
public enum PXCustomTranslationKey: String {
    case total_to_pay = "total_row_title_default"
    case total_to_pay_onetap = "onetap_purchase_summary_total"
    case how_to_pay = "¿Cómo quieres pagar?"
}

// Objc compatible - Only Loyalty use
/// :nodoc
@objc public enum PXCustomTranslation: Int {
    case total_to_pay
    case total_to_pay_onetap
    case how_to_pay

    internal var getValue: PXCustomTranslationKey {
        switch self {
        case .total_to_pay: return .total_to_pay
        case .total_to_pay_onetap: return .total_to_pay_onetap
        case .how_to_pay: return .how_to_pay
        }
    }
}
