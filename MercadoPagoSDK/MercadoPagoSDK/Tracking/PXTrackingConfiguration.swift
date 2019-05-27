//
//  PXTrackingConfiguration.swift
//  MercadoPagoSDKV4
//
//  Created by Federico Bustos Fierro on 27/05/2019.
//

import UIKit

open class PXTrackingConfiguration {
    let trackListener: PXTrackerListener?
    let flowName: String?
    let flowDetails: [String: Any]?
    let sessionId: String?

    init(trackListener: PXTrackerListener? = nil,
         flowName: String? = nil,
         flowDetails: [String: Any]? = nil,
         sessionId: String?) {
        self.trackListener = trackListener
        self.flowName = flowName
        self.flowDetails = flowDetails
        self.sessionId = sessionId
    }

    func updateTracker() {
        //TODO: replace PXTracker internally with a better solution based on this class
        if let trackListener = trackListener {
            PXTracker.setListener(trackListener,
                                  flowName: flowName,
                                  flowDetails: flowDetails)
        }
        if let sessionId = sessionId {
            PXTracker.setCustomSessionId(customSessionId: sessionId)
        }
    }
}
