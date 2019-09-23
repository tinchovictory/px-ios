//
//  DownloadAppData.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/09/2019.
//

import Foundation
import MLBusinessComponents

class DownloadAppData: NSObject, MLBusinessDownloadAppData {

    let discounts: Discounts

    init(discounts: Discounts) {
        self.discounts = discounts
    }

    func getAppSite() -> MLBusinessDownloadAppView.AppSite {
        return MLBusinessDownloadAppView.AppSite.ML
    }

    func getTitle() -> String {
        return discounts.actionDownload.title
    }

    func getButtonTitle() -> String {
        return discounts.actionDownload.action.label
    }

    func getButtonDeepLink() -> String {
        return discounts.actionDownload.action.target
    }
}

class DownloadAppDataMock: NSObject, MLBusinessDownloadAppData {

    func getAppSite() -> MLBusinessDownloadAppView.AppSite {
        return MLBusinessDownloadAppView.AppSite.MP
    }

    func getTitle() -> String {
        return "Exclusivo con la app de Mercado Pago"
    }

    func getButtonTitle() -> String {
        return "Descargar"
    }

    func getButtonDeepLink() -> String {
        return "button deep link"
    }
}
