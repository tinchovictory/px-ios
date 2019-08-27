//
//  PXNewResultViewController.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 27/08/2019.
//

import UIKit

class PXNewResultViewController: MercadoPagoUIScrollViewController {

    let tableView: UITableView
    let viewModel: PXResultViewModelInterface

    internal var changePaymentMethodCallback: (() -> Void)?

    init(viewModel: PXResultViewModelInterface, callback : @escaping ( _ status: PaymentResult.CongratsState) -> Void) {
        self.viewModel = viewModel
        self.viewModel.setCallback(callback: callback)
        self.tableView = UITableView()
        super.init(nibName: nil, bundle: nil)
        setupTableView()
        self.shouldHideNavigationBar = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTableView() {
        view.addSubview(tableView)
        PXLayout.matchWidth(ofView: tableView).isActive = true
        PXLayout.matchHeight(ofView: tableView).isActive = true
        PXLayout.centerVertically(view: tableView).isActive = true
        PXLayout.centerHorizontally(view: tableView).isActive = true
    }
}

extension PXNewResultViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "Text"
        return cell
    }
}
