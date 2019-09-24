//
//  PXDiscountsBoxData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/09/2019.
//

import UIKit
import MLBusinessComponents

class PXDiscountsBoxData: NSObject, MLBusinessDiscountBoxData {

    let discounts: Discounts

    init(discounts: Discounts) {
        self.discounts = discounts
    }

    func getTitle() -> String? {
        return discounts.title
    }

    func getSubtitle() -> String? {
        return discounts.subtitle
    }

    func getItems() -> [MLBusinessSingleItemProtocol] {
        var itemProtocols = [MLBusinessSingleItemProtocol]()
        for item in discounts.items {
            itemProtocols.append(PXDiscountItemData(item: item))
        }
        return itemProtocols
    }
}
