//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

protocol PXNewResultViewModelInterface {
    func getCellAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell
    func numberOfRowsInSection(_ section: Int) -> Int
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)

//    func getPaymentData() -> PXPaymentData
    func primaryResultColor() -> UIColor
//
//    func getPaymentStatus() -> String
//    func getPaymentStatusDetail() -> String
//    func getPaymentId() -> String?
//    func isCallForAuth() -> Bool
//    func buildHeaderComponent() -> PXHeaderComponent
//    func buildFooterComponent() -> PXFooterComponent
//    func buildReceiptComponent() -> PXReceiptComponent?
//    func buildBodyComponent() -> PXComponentizable?
//    func buildTopCustomView() -> UIView?
//    func buildBottomCustomView() -> UIView?
//    func getTrackingProperties() -> [String: Any]
//    func getTrackingPath() -> String
//    func getFooterPrimaryActionTrackingPath() -> String
//    func getFooterSecondaryActionTrackingPath() -> String
//    func getHeaderCloseButtonTrackingPath() -> String
}
