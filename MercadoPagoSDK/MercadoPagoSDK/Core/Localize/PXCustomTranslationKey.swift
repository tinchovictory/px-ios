//
//  PXCustomTranslationKey.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/28/19.
//

import Foundation

// Only for MoneyIn custom verb support.
/// :nodoc
@objc public enum PXCustomTranslationKey: Int {
    case total_to_pay
    case total_to_pay_onetap
    case how_to_pay

    internal var getValue: String {
        switch self {
        case .total_to_pay: return "total_row_title_default"
        case .total_to_pay_onetap: return "onetap_purchase_summary_total"
        case .how_to_pay: return "¿Cómo quieres pagar?"
        }
    }
}
