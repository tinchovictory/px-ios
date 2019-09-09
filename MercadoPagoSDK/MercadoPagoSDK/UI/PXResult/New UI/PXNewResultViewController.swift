//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit

class PXNewResultViewController: MercadoPagoUIViewController {

    private lazy var elasticHeader = UIView()
    private lazy var NAVIGATION_BAR_DELTA_Y: CGFloat = 29.8
    private lazy var NAVIGATION_BAR_SECONDARY_DELTA_Y: CGFloat = 0
    private lazy var navigationTitleStatusStep: Int = 0

    let tableView = UITableView()
    let viewModel: PXNewResultViewModelInterface
    var headerCell: PXNewResultHeader?

    internal var changePaymentMethodCallback: (() -> Void)?

    init(viewModel: PXNewResultViewModelInterface, callback: @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        super.init(nibName: nil, bundle: nil)
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        addElasticHeader(headerBackgroundColor: viewModel.primaryResultColor())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateTableView()
    }

    private func animateTableView() {
        let animator = UIViewPropertyAnimator(duration: 0.2, dampingRatio: 1) {
            self.tableView.alpha = 1
        }
        animator.addCompletion { (_) in
            self.headerCell?.animate()
        }
        animator.startAnimation()
    }

    private func setupTableView() {
        view.removeAllSubviews()
        view.addSubview(tableView)
        view.backgroundColor = viewModel.primaryResultColor()
        tableView.backgroundColor = .pxWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.alpha = 0
        tableView.bounces = true
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.layoutIfNeeded()
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
        tableView.reloadData()
    }
}

extension PXNewResultViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.getCellAtIndexPath(indexPath)
        if let headerCell = cell as? PXNewResultHeader {
            self.headerCell = headerCell
        }
        return viewModel.getCellAtIndexPath(indexPath)
    }
}

// MARK: Elastic Header
extension PXNewResultViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        elasticHeader.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: -scrollView.contentOffset.y)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y <= 32 {
            UIView.animate(withDuration: 0.25, animations: {
                targetContentOffset.pointee.y = 32
            })
        }
    }

    func addElasticHeader(headerBackgroundColor: UIColor?, navigationDeltaY: CGFloat?=nil, navigationSecondaryDeltaY: CGFloat?=nil) {
        elasticHeader.removeFromSuperview()
        elasticHeader.backgroundColor = headerBackgroundColor
        if let customDeltaY = navigationDeltaY {
            NAVIGATION_BAR_DELTA_Y = customDeltaY
        }
        if let customSecondaryDeltaY = navigationSecondaryDeltaY {
            NAVIGATION_BAR_SECONDARY_DELTA_Y = customSecondaryDeltaY
        }

        view.insertSubview(elasticHeader, aboveSubview: tableView)
    }
}
