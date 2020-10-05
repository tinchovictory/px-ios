//
//  PXSecurityCodeViewModel.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 02/09/2020.
//

import Foundation
import MLCardDrawer

final class PXSecurityCodeViewModel {

    enum Reason: String {
        case SAVED_CARD = "saved_card"
        case INVALID_ESC = "invalid_esc"
        case INVALID_FINGERPRINT = "invalid_fingerprint"
        case UNEXPECTED_TOKENIZATION_ERROR = "unexpected_tokenization_error"
        case ESC_DISABLED = "esc_disabled"
        case ESC_CAP = "esc_cap"
        case CALL_FOR_AUTH = "call_for_auth"
        case NO_REASON = "no_reason"
    }

    let paymentMethod: PXPaymentMethod
    let cardInfo: PXCardInformationForm
    let reason: Reason
    let cardUI: CardUI
    let cardData: CardData

    // MARK: Protocols
    weak var internetProtocol: InternetConnectionProtocol?

    public init(paymentMethod: PXPaymentMethod, cardInfo: PXCardInformationForm, reason: Reason, cardUI: CardUI, cardData: CardData, internetProtocol: InternetConnectionProtocol) {
        self.paymentMethod = paymentMethod
        self.cardInfo = cardInfo
        self.reason = reason
        self.cardUI = cardUI
        self.cardData = cardData
        self.internetProtocol = internetProtocol
    }
}

// MARK: Publics
extension PXSecurityCodeViewModel {
    func shouldShowCard() -> Bool {
        return !UIDevice.isSmallDevice() && !isVirtualCard()
    }

    func isVirtualCard() -> Bool {
        paymentMethod.creditsDisplayInfo?.cvvInfo != nil
    }

    func getTitle() -> String? {
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        return isVirtualCard() ? paymentMethod.creditsDisplayInfo?.cvvInfo?.title : "Ingresa el código de seguridad".localized
    }

    func getSubtitle() -> String? {
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        return isVirtualCard() ? paymentMethod.creditsDisplayInfo?.cvvInfo?.message : "Busca los dígitos en el dorso de tu tarjeta.".localized
    }

    func getSecurityCodeLength() -> Int {
        return paymentMethod.secCodeLenght(cardInfo.getCardBin())
    }
}

// MARK: Static methods
extension PXSecurityCodeViewModel {
    static func getSecurityCodeReason(invalidESCReason: PXESCDeleteReason?, isCallForAuth: Bool = false) -> PXSecurityCodeViewModel.Reason {
        if isCallForAuth {
            return .CALL_FOR_AUTH
        }

        if !PXConfiguratorManager.escProtocol.hasESCEnable() {
            return .ESC_DISABLED
        }

        guard let invalidESCReason = invalidESCReason else { return .SAVED_CARD }

        switch invalidESCReason {
        case .INVALID_ESC:
            return .INVALID_ESC
        case .INVALID_FINGERPRINT:
            return .INVALID_FINGERPRINT
        case .UNEXPECTED_TOKENIZATION_ERROR:
            return .UNEXPECTED_TOKENIZATION_ERROR
        case .ESC_CAP:
            return .ESC_CAP
        default:
            return .NO_REASON
        }
    }
}

// MARK: Tracking
extension PXSecurityCodeViewModel {
    func getScreenProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        properties["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        if let cardInfo = cardInfo as? PXCardInformation {
            properties["card_id"] =  cardInfo.getCardId()
            properties["issuer_id"] = cardInfo.getIssuer()?.id
        }
        properties["bin"] = cardInfo.getCardBin()
        properties["reason"] = reason.rawValue
        return properties
    }

    func getNoConnectionProperties() -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = "/px_checkout/no_connection"
        properties["style"] = "snackbar"
        properties["id"] = "no_connection"
        return properties
    }

    func getFrictionProperties(path: String, id: String) -> [String: Any] {
        var properties: [String: Any] = [:]
        properties["path"] = path
        properties["style"] = "snackbar"
        properties["id"] = id
        var extraInfo: [String: Any] = [:]
        extraInfo["payment_method_type"] = paymentMethod.getPaymentTypeForTracking()
        extraInfo["payment_method_id"] = paymentMethod.getPaymentIdForTracking()
        if let cardInfo = cardInfo as? PXCardInformation {
            extraInfo["card_id"] = cardInfo.getCardId()
            extraInfo["issuer_id"] = cardInfo.getIssuer()?.id
        }
        properties["extra_info"] = extraInfo
        return properties
    }
}
