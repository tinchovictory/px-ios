//
//  PXBiometricProtocol.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 8/8/19.
//

import Foundation

/**
 Use this protocol to implement Biometric validation
 */
@objc public protocol PXBiometricProtocol: NSObjectProtocol {
    func validate(config: PXBiometricConfig, onSuccess: @escaping () -> Void, @escaping onError: (Error) -> Void)
    func isValidationRequired(config: PXBiometricConfig) -> Bool
}
