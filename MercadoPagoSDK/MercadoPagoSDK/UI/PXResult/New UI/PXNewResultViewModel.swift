//
//  PXNewResultViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import Foundation

struct ResultViewData {
    let view: UIView
    let verticalMargin: CGFloat
    let horizontalMargin: CGFloat
}

protocol PXNewResultViewModelInterface {
    func getViews() -> [ResultViewData]
    func setCallback(callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void)
    func primaryResultColor() -> UIColor
    func buildHeaderView() -> UIView
    func buildFooterView() -> UIView
    func buildImportantCustomView() -> UIView?
    func buildTopCustomView() -> UIView?
    func buildBottomCustomView() -> UIView?
    func buildPaymentMethodView(paymentData: PXPaymentData) -> UIView?
    func buildPointsViews() -> UIView?
    func buildDiscountsView() -> UIView?
    func buildDiscountsAccessoryView() -> ResultViewData?
    func buildCrossSellingViews() -> [UIView]?
    func buildReceiptView() -> UIView?
    func getTrackingProperties() -> [String: Any]
    func getTrackingPath() -> String
}

protocol BetaResultViewModel {
    //HEADER
    func getHeaderColor() -> UIColor
    func getHeaderTitle() -> String
    func getHeaderIcon() -> UIImage?
    func getHeaderURLIcon() -> String?
    func getHeaderBadgeImage() -> UIImage?
    func getHeaderCloseAction() -> (() -> Void)?

    //RECEIPT
    func mustShowReceipt() -> Bool
    func getReceiptId() -> String?

    //POINTS AND DISCOUNTS
    ////POINTS
    func getPoints() -> PXPoints?
    func getPointsTapAction() -> ((_ deepLink: String) -> Void)?

    ////DISCOUNTS
    func getDiscounts() -> PXDiscounts?
    func getDiscountsTapAction() -> ((_ index: Int, _ deepLink: String?, _ trackId: String?) -> Void)?

    ////CROSS SELLING
    func getCrossSellingItems() -> [PXCrossSellingItem]?
    func getCrossSellingTapAction() -> ((_ deepLink: String) -> Void)?

    //INSTRUCTIONS
    func hasInstructions() -> Bool
    func getInstructions() -> PXInstructions?

    //PAYMENT METHOD
    func getPaymentData() -> PXPaymentData?
    func getAmountHelper() -> PXAmountHelper?

    //SPLIT PAYMENT METHOD
    func getSplitPaymentData() -> PXPaymentData?
    func getSplitAmountHelper() -> PXAmountHelper?

    //FOOTER
    func getFooterMainAction() -> PXAction?
    func getFooterSecondaryAction() -> PXAction?

    //CUSTOM VIEWS
    ////IMPORTANT
    func getImportantView() -> UIView?

    ////TOP CUSTOM
    func getTopCustomView() -> UIView?

    ////BOTTOM CUSTOM
    func getBottomCustomView() -> UIView?
}

class BetaModel: BetaResultViewModel {
    func getHeaderColor() -> UIColor {
        return .red
    }

    func getHeaderTitle() -> String {
        return "Header Title"
    }

    func getHeaderIcon() -> UIImage? {
        return nil
    }

    func getHeaderURLIcon() -> String? {
        return nil
    }

    func getHeaderBadgeImage() -> UIImage? {
        return UIImage()
    }

    func getHeaderCloseAction() -> (() -> Void)? {
        return nil
    }

    func mustShowReceipt() -> Bool {
        return true
    }

    func getReceiptId() -> String? {
        return "1245"
    }

    func getPoints() -> PXPoints? {
        return nil
    }

    func getPointsTapAction() -> ((String) -> Void)? {
        return nil
    }

    func getDiscounts() -> PXDiscounts? {
        return nil
    }

    func getDiscountsTapAction() -> ((Int, String?, String?) -> Void)? {
        return nil
    }

    func getCrossSellingItems() -> [PXCrossSellingItem]? {
        return nil
    }

    func getCrossSellingTapAction() -> ((String) -> Void)? {
        return nil
    }

    func hasInstructions() -> Bool {
        return false
    }

    func getInstructions() -> PXInstructions? {
        return nil
    }

    func getPaymentData() -> PXPaymentData? {
        return nil
    }

    func getAmountHelper() -> PXAmountHelper? {
        return nil
    }

    func getSplitPaymentData() -> PXPaymentData? {
        return nil
    }

    func getSplitAmountHelper() -> PXAmountHelper? {
        return nil
    }

    func getFooterMainAction() -> PXAction? {
        return nil
    }

    func getFooterSecondaryAction() -> PXAction? {
        return nil
    }

    func getImportantView() -> UIView? {
        return nil
    }

    func getTopCustomView() -> UIView? {
        return nil
    }

    func getBottomCustomView() -> UIView? {
        return nil
    }
}
