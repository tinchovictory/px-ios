//
//  PXESCConfig.swift
//  MercadoPagoSDK
//
//  Created by Eric Ertl on 25/09/2019.
//

import Foundation

/**
 Whe use this object to store properties related to ESC module.
 Check PXESCProtocol methods.
 */
@objcMembers
open class PXESCConfig: NSObject {
    public let enabled: Bool
    public let sessionId: String
    public let flow: String

    init(_ enabled: Bool, _ sessionId: String, _ flow: String) {
        self.enabled = enabled
        self.sessionId = sessionId
        self.flow = flow
    }
}

// MARK: Internals (Only PX)
internal extension PXESCConfig {
    static func createConfig(enabled: Bool = false, session: String? = nil, flow: String? = nil) -> PXESCConfig {
        var sessionId = session
        if session == nil {
            sessionId = MPXTracker.sharedInstance.getSessionID()
        }
        var flowText = flow
        if flow == nil {
            flowText = MPXTracker.sharedInstance.getFlowName() ?? "PX"
        }

        return PXESCConfig(enabled, sessionId ?? "", flowText ?? "")
    }
}
