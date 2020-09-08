//
//  AdditionalStepCellFactory.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 4/6/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import Foundation
import UIKit

class AdditionalStepCellFactory: NSObject {

    open class func buildCell(object: Cellable, width: Double, height: Double) -> UITableViewCell {
        return UITableViewCell()
    }
}

internal enum ObjectTypes: String {
    case payerCost = "payer_cost"
    case issuer = "issuer"
    case entityType = "entity_type"
    case financialInstitution = "financial_instituions"
    case paymentMethod = "payment_method"
}
