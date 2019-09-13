//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

protocol PXNewResultViewModelInterface {
    func getViews() -> [(view: UIView, margin: CGFloat)]

//    func getCells() -> [ResultCellItem]
//    func getCellsClases() -> [(id: String, cell: AnyClass)]
//    func getCellAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell
//    func numberOfRowsInSection(_ section: Int) -> Int
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)
    func primaryResultColor() -> UIColor
    func buildHeaderView() -> UIView
//    func getCellsTypes() -> [NewResultCells]
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
