//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit

class PXNewResultViewController: MercadoPagoUIViewController {

    private lazy var elasticHeader = UIView()
    let tableView = UITableView()
    let viewModel: PXNewResultViewModelInterface

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prepareForAnimation()
        self.animateContentView { (_) in
//            self.headerView?.badgeImage?.animate(duration: 0.2)
        }
    }

    private func setupTableView() {
        view.removeAllSubviews()
        view.addSubview(tableView)
        view.backgroundColor = viewModel.primaryResultColor()
        tableView.backgroundColor = viewModel.primaryResultColor()
        tableView.frame = view.frame
        tableView.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.tableHeaderView?.layoutIfNeeded()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.allowsSelection = false
        tableView.separatorColor = .clear
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
        return viewModel.getCellAtIndexPath(indexPath)
    }
}

// MARK: Spruce
extension PXNewResultViewController {
    func animateContentView(customAnimations: [StockAnimation]? = nil, completion: CompletionHandler? = nil) {
        if let animationCustom = customAnimations {
            view.pxSpruce.animate(animationCustom, sortFunction: PXSpruce.PXDefaultAnimation.appearSortFunction, completion: completion)
        } else {
            view.pxSpruce.animate(PXSpruce.PXDefaultAnimation.slideUpAnimation, sortFunction: PXSpruce.PXDefaultAnimation.appearSortFunction, completion: completion)
        }
    }

    func prepareForAnimation(customAnimations: [StockAnimation]? = nil) {
        if let animationCustom = customAnimations {
            view.pxSpruce.prepare(with: animationCustom)
        } else {
            view.pxSpruce.prepare(with: PXSpruce.PXDefaultAnimation.slideUpAnimation)
        }
    }
}
