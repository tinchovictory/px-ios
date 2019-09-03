//
//  PXResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by Demian Tejo on 20/10/17.
//  Copyright © 2017 MercadoPago. All rights reserved.
//

import UIKit

internal class PXResultViewModel: PXResultViewModelInterface {

    var paymentResult: PaymentResult
    var instructionsInfo: PXInstructions?
    var preference: PXPaymentResultConfiguration
    var callback: ((PaymentResult.CongratsState) -> Void)?
    let amountHelper: PXAmountHelper

    let warningStatusDetails = [PXRejectedStatusDetail.INVALID_ESC, PXRejectedStatusDetail.CALL_FOR_AUTH, PXRejectedStatusDetail.BAD_FILLED_CARD_NUMBER, PXRejectedStatusDetail.CARD_DISABLE, PXRejectedStatusDetail.INSUFFICIENT_AMOUNT, PXRejectedStatusDetail.BAD_FILLED_DATE, PXRejectedStatusDetail.BAD_FILLED_SECURITY_CODE, PXRejectedStatusDetail.REJECTED_INVALID_INSTALLMENTS, PXRejectedStatusDetail.BAD_FILLED_OTHER]

    init(amountHelper: PXAmountHelper, paymentResult: PaymentResult, instructionsInfo: PXInstructions? = nil, resultConfiguration: PXPaymentResultConfiguration = PXPaymentResultConfiguration()) {
        self.paymentResult = paymentResult
        self.instructionsInfo = instructionsInfo
        self.preference = resultConfiguration
        self.amountHelper = amountHelper
    }

    func getPaymentData() -> PXPaymentData {
        return self.paymentResult.paymentData!
    }

    func setCallback(callback: @escaping ((PaymentResult.CongratsState) -> Void)) {
        self.callback = callback
    }

    func getPaymentStatus() -> String {
        return self.paymentResult.status
    }

    func getPaymentStatusDetail() -> String {
        return self.paymentResult.statusDetail
    }

    func getPaymentId() -> String? {
        return self.paymentResult.paymentId
    }
    func isCallForAuth() -> Bool {
        return self.paymentResult.isCallForAuth()
    }

    func primaryResultColor() -> UIColor {
        return ResourceManager.shared.getResultColorWith(status: paymentResult.status, statusDetail: paymentResult.statusDetail)
    }
}

// MARK: Tracking
extension PXResultViewModel {
    func getTrackingProperties() -> [String: Any] {
        let currency_id = "currency_id"
        let discount_coupon_amount = "discount_coupon_amount"
        let has_split = "has_split_payment"
        let raw_amount = "preference_amount"

        var properties: [String: Any] = amountHelper.getPaymentData().getPaymentDataForTracking()
        properties["style"] = "generic"
        if let paymentId = paymentResult.paymentId {
            properties["payment_id"] = Int64(paymentId)
        }
        properties["payment_status"] = paymentResult.status
        properties["payment_status_detail"] = paymentResult.statusDetail

        properties[has_split] = amountHelper.isSplitPayment
        properties[currency_id] = SiteManager.shared.getCurrency().id
        properties[discount_coupon_amount] = amountHelper.getDiscountCouponAmountForTracking()

        if let rawAmount = amountHelper.getPaymentData().getRawAmount() {
            properties[raw_amount] = rawAmount.decimalValue
        }

        return properties
    }

    func getTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorPath()
        }
        return screenPath
    }

    func getFooterPrimaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = ""
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorChangePaymentMethodPath()
        }
        return screenPath
    }

    func getFooterSecondaryActionTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessContinuePath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionContinuePath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = ""
        }
        return screenPath
    }

    func getHeaderCloseButtonTrackingPath() -> String {
        let paymentStatus = paymentResult.status
        var screenPath = ""

        if paymentStatus == PXPaymentStatus.APPROVED.rawValue || paymentStatus == PXPaymentStatus.PENDING.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getSuccessAbortPath()
        } else if paymentStatus == PXPaymentStatus.IN_PROCESS.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getFurtherActionAbortPath()
        } else if paymentStatus == PXPaymentStatus.REJECTED.rawValue {
            screenPath = TrackingPaths.Screens.PaymentResult.getErrorAbortPath()
        }
        return screenPath
    }
}

// MARK: URL logic
extension PXResultViewModel {
    func getBackUrl() -> URL? {
        if let status = PXPaymentStatus(rawValue: getPaymentStatus()) {
            switch status {
            case .APPROVED:
                return URL(string: amountHelper.preference.backUrls?.success ?? "")
            case .PENDING:
                return URL(string: amountHelper.preference.backUrls?.pending ?? "")
            case .REJECTED:
                return URL(string: amountHelper.preference.backUrls?.failure ?? "")
            default:
                return nil
            }
        }
        return nil
    }

    func openURL(url: URL, success: @escaping (Bool) -> Void) {
        let completionHandler : (Bool) -> Void = { result in
            sleep(1)
            success(result)
        }

        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: completionHandler)
        } else {
            success(false)
        }
    }
}

// MARK: New Result View Model Interface
extension PXResultViewModel: PXNewResultViewModelInterface {
    func getCells() -> [ResultCellItem] {
        var cells: [ResultCellItem] = []

        //Header Cell
        let headerCell = ResultCellItem(position: .header, relatedCell: getHeaderCell(), relatedComponent: nil, relatedView: nil)
        cells.append(headerCell)

        //Top Disclaimer Cell
        if let receiptComponent = buildReceiptComponent() {
            let receiptCell = ResultCellItem(position: .topDisclosureView, relatedCell: nil, relatedComponent: receiptComponent, relatedView: nil)
            cells.append(receiptCell)
        } else {
            //SUBE
        }

        //Top Custom Cell
        if let topCustomView = buildTopCustomView() {
            let topCustomCell = ResultCellItem(position: .topCustomView, relatedCell: nil, relatedComponent: nil, relatedView: topCustomView)
            cells.append(topCustomCell)
        }

        //Instructions Cell
        if let bodyComponent = buildBodyComponent() as? PXBodyComponent, bodyComponent.hasInstructions() {
            let instructionsCell = ResultCellItem(position: .instructions, relatedCell: nil, relatedComponent: bodyComponent, relatedView: nil)
            cells.append(instructionsCell)
        }

        //Bottom Custom Cell
        if let bottomCustomView = buildBottomCustomView() {
            let bottomCustomCell = ResultCellItem(position: .bottomCustomView, relatedCell: nil, relatedComponent: nil, relatedView: bottomCustomView)
            cells.append(bottomCustomCell)
        }

        //Footer Cell
        let footerCell = ResultCellItem(position: .footer, relatedCell: nil, relatedComponent: buildFooterComponent(), relatedView: nil)
        cells.append(footerCell)

        return cells
    }

    func getCellAtIndexPath(_ indexPath: IndexPath) -> UITableViewCell {
        return getCells()[indexPath.row].getCell()
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return getCells().count
    }

    func getHeaderCell() -> UITableViewCell {
        let cell = PXNewResultHeader()
        let cellData = PXNewResultHeaderData(color: primaryResultColor(), title: titleHeader(forNewResult: true), icon: iconImageHeader(), iconURL: nil, badgeImage: badgeImage(), closeAction: { [weak self] in
            if let callback = self?.callback {
                if let url = self?.getBackUrl() {
                    self?.openURL(url: url, success: { (_) in
                        callback(PaymentResult.CongratsState.cancel_EXIT)
                    })
                } else {
                    callback(PaymentResult.CongratsState.cancel_EXIT)
                }
            }
        })
        cell.setData(data: cellData)
        return cell
    }
}
