//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

enum NewResultCells {
    case header
    case paymentMethod
    case instructions
    case topCustomView
    case bottomCustomView
    case paymentDetailTitle
    case topDisclosureView
    case footer
}

struct ResultCellItem {
    let position: NewResultCells
    let relatedCell: UITableViewCell?
    let relatedComponent: PXComponentizable?
    let relatedView: UIView?

    func getCell() -> UITableViewCell {
        if let relatedCell = relatedCell {
            return relatedCell
        } else if let relatedComponent = relatedComponent {
            let cell = NewResultContainterCell()
            cell.setContent(view: relatedComponent.render())
            return cell
        } else if let relatedView = relatedView {
            let cell = NewResultContainterCell()
            cell.setContent(view: relatedView)
            return cell
        } else {
            return UITableViewCell()
        }
    }
}


protocol PXNewResultViewModelInterface {
    func getCells() -> [ResultCellItem]
    func getCellAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell
    func numberOfRowsInSection(_ section: Int) -> Int
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)
    func primaryResultColor() -> UIColor
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
