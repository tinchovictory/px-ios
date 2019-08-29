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

    private func setupTableView() {
        view.removeAllSubviews()
        view.addSubview(tableView)
        tableView.frame = view.frame
        tableView.backgroundColor = .white
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
