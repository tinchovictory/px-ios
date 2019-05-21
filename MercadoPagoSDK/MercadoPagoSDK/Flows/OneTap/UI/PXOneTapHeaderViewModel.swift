//
//  PXOneTapHeaderViewModel.swift
//  MercadoPagoSDK
//
//  Created by Juan sebastian Sanzone on 5/11/18.
//

import UIKit

typealias OneTapSummaryRowHandler = () -> Void
typealias OneTapHeaderSummaryData = (title: String, value: String, highlightedColor: UIColor, alpha: CGFloat, isTotal: Bool, image: UIImage?, type: OneTapSummaryRowType?)

enum OneTapSummaryRowType {
    case discount
    case charges
    case generic
}

class PXOneTapHeaderViewModel {
    let icon: UIImage
    let title: String
    let subTitle: String?
    let data: [OneTapHeaderSummaryData]
    let splitConfiguration: PXSplitConfiguration?

    init(icon: UIImage, title: String, subTitle: String?, data: [OneTapHeaderSummaryData], splitConfiguration: PXSplitConfiguration?) {
        self.icon = icon
        self.title = title
        self.subTitle = subTitle
        self.data = data
        self.splitConfiguration = splitConfiguration
    }
}
