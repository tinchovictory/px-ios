//
//  PXDiscountItemData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 13/09/2019.
//

import UIKit
import MLBusinessComponents

class PXDiscountItemData: NSObject, MLBusinessSingleItemProtocol {
    let item: DiscountsItem

    init(item: DiscountsItem) {
        self.item = item
    }

    func titleForItem() -> String {
        return item.title
    }

    func subtitleForItem() -> String {
        return item.subtitle
    }

    func iconImageUrlForItem() -> String {
        return item.icon
    }

    func deepLinkForItem() -> String? {
        return item.target
    }

    func trackIdForItem() -> String? {
        return item.campaingId
    }
}

class SingleItemData: NSObject {
    let title: String
    let subTitle: String
    let iconUrl: String
    let deepLink: String?
    let trackId: String?

    init(title: String, subtitle: String, iconImageUrl: String, deepLink: String? = nil, trackId: String? = nil) {
        self.title = title
        self.subTitle = subtitle
        self.iconUrl = iconImageUrl
        self.deepLink = deepLink
        self.trackId = trackId
    }
}

extension SingleItemData: MLBusinessSingleItemProtocol {
    func titleForItem() -> String {
        return title
    }

    func subtitleForItem() -> String {
        return subTitle
    }

    func iconImageUrlForItem() -> String {
        return iconUrl
    }

    func deepLinkForItem() -> String? {
        return deepLink
    }

    func trackIdForItem() -> String? {
        return trackId
    }
}

