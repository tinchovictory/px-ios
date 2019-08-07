//
//  PXConfiguratorManager.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 8/7/19.
//

import Foundation

@objcMembers
open class PXConfiguratorManager: NSObject {
    internal static var biometricProtocol: PXBiometricProtocol = PXBiometricDefault()
    static func with(biometric securityBiometric: PXBiometricProtocol) {
        self.biometricProtocol = securityBiometric
    }
}

@objc public protocol PXBiometricProtocol: NSObjectProtocol {
    func validate(config: PXBiometricConfig, onSuccess: @escaping () -> Void, onError: (Error) -> Void)
    func isValidationRequired(config: PXBiometricConfig) -> Bool
}

class PXBiometricDefault: NSObject, PXBiometricProtocol {
    func validate(config: PXBiometricConfig, onSuccess: @escaping () -> Void, onError: (Error) -> Void) {
        onSuccess()
        // onError(NSError(domain: "", code: 1, userInfo: nil))
    }
    func isValidationRequired(config: PXBiometricConfig) -> Bool {
        return false
    }
}

@objcMembers
open class PXBiometricConfig: NSObject {
    let productId: String
    var params: [String: Any] = [:]

    init(_ productId: String) {
        self.productId = productId
    }

    init(productId: String, amount: NSDecimalNumber) {
        self.productId = productId
        // TODO: Check parameter name.
        self.params["amount"] = amount
    }

    internal static func defaultFactory() -> PXBiometricConfig {
        return PXBiometricConfig("BJEO9TFBF6RG01IIIOU0")
    }
}
