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
        self.prepareForAnimation()
        self.animateContentView { (_) in
            self.headerCell?.animate()
        }
    }

    private func setupTableView() {
        view.removeAllSubviews()
        view.addSubview(tableView)
        view.backgroundColor = .pxWhite
        tableView.backgroundColor = .pxWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

// MARK: Spruce
extension PXNewResultViewController {
    func animateContentView(customAnimations: [StockAnimation]? = nil, completion: CompletionHandler? = nil) {
        if let animationCustom = customAnimations {
            self.tableView.pxSpruce.animate(animationCustom, sortFunction: PXSpruce.PXDefaultAnimation.appearSortFunction, completion: completion)
        } else {
            self.tableView.pxSpruce.animate(PXSpruce.PXDefaultAnimation.slideUpAnimation, sortFunction: PXSpruce.PXDefaultAnimation.appearSortFunction, completion: completion)
        }
    }

    func prepareForAnimation(customAnimations: [StockAnimation]? = nil) {
        if let animationCustom = customAnimations {
            self.tableView.pxSpruce.prepare(with: animationCustom)
        } else {
            self.tableView.pxSpruce.prepare(with: PXSpruce.PXDefaultAnimation.slideUpAnimation)
        }
    }
}
