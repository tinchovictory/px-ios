//
//  PXCreditsExpectationComponent.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 24/11/17.
//  Copyright © 2019 MercadoPago. All rights reserved.
//

import UIKit

internal class PXCreditsExpectationComponent: NSObject, PXComponentizable {
    var props: PXCreditsExpectationProps

    init(props: PXCreditsExpectationProps) {
       self.props = props
    }

    func render() -> UIView {
        return PXCreditsExpectationComponentRenderer().render(component: self)
    }
}
