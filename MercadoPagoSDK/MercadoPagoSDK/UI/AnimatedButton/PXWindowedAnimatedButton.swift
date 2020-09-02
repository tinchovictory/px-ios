//
//  PXWindowedAnimatedButton.swift
//  MercadoPagoSDK
//
//  Created by Tomi De Lucca on 24/08/2020.
//

import Foundation

/**
 Just like the PXAnimatedButton, but using the window as it's anchor point.
 Useful for situtations where the explosion should escape the containing view controller.
 */
internal class PXWindowedAnimatedButton: PXAnimatedButton {
    override func anchorView() -> UIView? {
        return UIApplication.shared.keyWindow
    }
}
