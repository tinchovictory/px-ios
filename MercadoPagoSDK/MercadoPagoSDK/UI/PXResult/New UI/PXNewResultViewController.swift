//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit
import MLBusinessComponents

class PXNewResultViewController: MercadoPagoUIViewController {

    private weak var ringView: MLBusinessLoyaltyRingView?
    private lazy var elasticHeader = UIView()
    private lazy var NAVIGATION_BAR_DELTA_Y: CGFloat = 29.8
    private lazy var NAVIGATION_BAR_SECONDARY_DELTA_Y: CGFloat = 0
    private lazy var navigationTitleStatusStep: Int = 0

    private let statusBarHeight = PXLayout.getStatusBarHeight()

    let scrollView = UIScrollView()
    let viewModel: PXNewResultViewModelInterface
    let betaViewModel: BetaResultViewModel

    internal var changePaymentMethodCallback: (() -> Void)?

    init(viewModel: PXNewResultViewModelInterface, callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        self.betaViewModel = BetaModel()
        super.init(nibName: nil, bundle: nil)
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupScrollView()
        addElasticHeader(headerBackgroundColor: viewModel.primaryResultColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateScrollView()
        animateRing()
        if !String.isNullOrEmpty(viewModel.getTrackingPath()) {
            trackScreen(path: viewModel.getTrackingPath(), properties: viewModel.getTrackingProperties())
        }
    }

    private func animateScrollView() {
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 1) {
            self.scrollView.alpha = 1
        }
        animator.startAnimation()
    }

    private func setupScrollView() {
        view.removeAllSubviews()
        view.addSubview(scrollView)
        view.backgroundColor = viewModel.primaryResultColor()
        scrollView.backgroundColor = .pxWhite
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        scrollView.alpha = 0
        scrollView.bounces = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.layoutIfNeeded()

        renderContentView()
    }

    func renderContentView() {
        //CONTENT VIEW
        let contentView = UIView()
        contentView.backgroundColor = .pxWhite
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        //Content View Layout
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //FOOTER VIEW
        let footerContentView = UIView()
        footerContentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(footerContentView)

        let dividingView = MLBusinessDividingLineView()
        let footerView = viewModel.buildFooterView()
        footerContentView.addSubview(dividingView)
        footerContentView.addSubview(footerView)

        //Dividing View Layout
        NSLayoutConstraint.activate([
            dividingView.leadingAnchor.constraint(equalTo: footerContentView.leadingAnchor),
            dividingView.trailingAnchor.constraint(equalTo: footerContentView.trailingAnchor),
            dividingView.topAnchor.constraint(equalTo: footerContentView.topAnchor),
            dividingView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //Footer View Layout
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: footerContentView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: footerContentView.trailingAnchor),
            footerView.topAnchor.constraint(equalTo: dividingView.bottomAnchor),
            footerView.bottomAnchor.constraint(equalTo: footerContentView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //Footer Content View Layout
        NSLayoutConstraint.activate([
            footerContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerContentView.topAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerContentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerContentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        //Calculate content view min height
        self.view.layoutIfNeeded()
        let scrollViewMinHeight: CGFloat = PXLayout.getScreenHeight() - footerView.frame.height - PXLayout.getSafeAreaTopInset() - PXLayout.getSafeAreaBottomInset()
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: scrollViewMinHeight)
        ])

        //Load content views
        for data in viewModel.getViews() {
            if let ringView = data.view as? MLBusinessLoyaltyRingView {
                self.ringView = ringView
            }

            contentView.addViewToBottom(data.view, withMargin: data.verticalMargin)

            NSLayoutConstraint.activate([
                data.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: data.horizontalMargin),
                data.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -data.horizontalMargin)
            ])
        }
        PXLayout.pinLastSubviewToBottom(view: contentView, relation: .lessThanOrEqual)
    }
}

// MARK: Elastic header.
extension PXNewResultViewController: UIScrollViewDelegate {
    func addElasticHeader(headerBackgroundColor: UIColor?, navigationDeltaY: CGFloat?=nil, navigationSecondaryDeltaY: CGFloat?=nil) {
        elasticHeader.removeFromSuperview()
        scrollView.delegate = self
        elasticHeader.backgroundColor = headerBackgroundColor
        if let customDeltaY = navigationDeltaY {
            NAVIGATION_BAR_DELTA_Y = customDeltaY
        }
        if let customSecondaryDeltaY = navigationSecondaryDeltaY {
            NAVIGATION_BAR_SECONDARY_DELTA_Y = customSecondaryDeltaY
        }

        view.insertSubview(elasticHeader, aboveSubview: scrollView)
        scrollView.bounces = true
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= 32 {
            UIView.animate(withDuration: 0.25, animations: {
                targetContentOffset.pointee.y = 32
            })
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Elastic header min height
        if -scrollView.contentOffset.y < statusBarHeight {
            elasticHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: statusBarHeight)
        } else {
            elasticHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: -scrollView.contentOffset.y)
        }
    }
}

internal extension UIView {
    func addViewToBottom(_ view: UIView, withMargin margin: CGFloat = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        if self.subviews.count == 1 {
            PXLayout.pinTop(view: view, withMargin: margin).isActive = true
        } else {
            PXLayout.put(view: view, onBottomOfLastViewOf: self, withMargin: margin)?.isActive = true
        }
    }
}

// MARK: Ring Animate.
extension PXNewResultViewController {
    @objc func doAnimateRing() {
        ringView?.fillPercentProgressWithAnimation()
    }

    private func animateRing() {
        perform(#selector(self.doAnimateRing), with: self, afterDelay: 0.3)
    }
}

// MARK: BETA View Model
extension PXNewResultViewController {
    //HEADER
    func buildHeaderView() -> UIView {
        let headerData = PXNewResultHeaderData(color: betaViewModel.getHeaderColor(),
                                               title: betaViewModel.getHeaderTitle(),
                                               icon: betaViewModel.getHeaderIcon(),
                                               iconURL: betaViewModel.getHeaderURLIcon(),
                                               badgeImage: betaViewModel.getHeaderBadgeImage(),
                                               closeAction: nil)
        return PXNewResultHeader(data: headerData)
    }

    //RECEIPT
    func buildReceiptView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForReceiptView(paymentId: betaViewModel.getReceiptId()), betaViewModel.mustShowReceipt() else {
            return nil
        }

        return PXNewCustomView(data: data)
    }

    //POINTS AND DISCOUNTS
    ////POINTS
    func buildPointsView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForPointsView(points: betaViewModel.getPoints()) else {
            return nil
        }
        let pointsView = MLBusinessLoyaltyRingView(data, fillPercentProgress: false)

        if let tapAction = betaViewModel.getPointsTapAction() {
            pointsView.addTapAction(tapAction)
        }

        return pointsView
    }
    ////DISCOUNTS
    func buildDiscountsView() -> UIView? {
        guard let data = PXNewResultUtil.getDataForDiscountsView(discounts: betaViewModel.getDiscounts()) else {
            return nil
        }
        let discountsView = MLBusinessDiscountBoxView(data)

        if let tapAction = betaViewModel.getDiscountsTapAction() {
            discountsView.addTapAction(tapAction)
        }

        return discountsView
    }

    ////CROSS SELLING
    func buildCrossSellingViews() -> [UIView]? {
        guard let data = PXNewResultUtil.getDataForCrossSellingView(crossSellingItems: betaViewModel.getCrossSellingItems()) else {
            return nil
        }
        var itemsViews = [UIView]()
        for itemData in data {
            let itemView = MLBusinessCrossSellingBoxView(itemData)
            if let tapAction = betaViewModel.getCrossSellingTapAction() {
                itemView.addTapAction(action: tapAction)
            }

            itemsViews.append(itemView)
        }
        return itemsViews
    }

    //INSTRUCTIONS
    func buildInstructionsView() -> UIView? {
        guard let instructions = betaViewModel.getInstructions() else {
            return nil
        }

        //TODO: Ver esto
        return nil
    }

    //PAYMENT METHOD
    func buildPaymentMethodView() -> UIView? {
        guard let paymentData = betaViewModel.getPaymentData() else {
            return nil
        }
        guard let amountHelper = betaViewModel.getAmountHelper() else {
            return nil
        }
        guard let data = PXNewResultUtil.getDataForPaymentMethodView(paymentData: paymentData, amountHelper: amountHelper) else {
            return nil
        }

        let view = PXNewCustomView(data: data)
        return view
    }

    //FOOTER
    func buildFooterView() -> UIView {
        let footerProps = PXFooterProps(buttonAction: betaViewModel.getMainAction(), linkAction: betaViewModel.getSecondaryAction())
        return PXFooterComponent(props: footerProps).render()
    }

    //CUSTOM
    ////IMPORTANT
    func buildImportantView() -> UIView? {
        return betaViewModel.getImportantView()
    }

    ////TOP CUSTOM
    func buildTopCustomView() -> UIView? {
        return betaViewModel.getTopCustomView()
    }

    ////BOTTOM CUSTOM
    func buildBottomCustomView() -> UIView? {
        return betaViewModel.getBottomCustomView()
    }
}
