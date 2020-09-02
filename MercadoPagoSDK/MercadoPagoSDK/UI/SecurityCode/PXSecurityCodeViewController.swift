//
//  PXSecurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 04/08/2020.
//

import Foundation
import MLUI
import MLCardDrawer

class PXSecurityCodeViewController: MercadoPagoUIViewController {

    let viewModel: PXSecurityCodeViewModel
    let cardContainerView = UIView()
    let titleLabel = UILabel()
    let subtitle = UILabel()
    let textFieldTitle = UILabel()
    let textField = UITextField()
    var loadingButtonComponent: PXAnimatedButton?
    var cardDrawer: MLCardDrawerController?

    // MARK: Constraints
    var loadingButtonBottomConstraint = NSLayoutConstraint()
    var titleLabelBottomConstraint = NSLayoutConstraint()
    var subtitleBottomConstraint = NSLayoutConstraint()
    var textFieldTitleTopConstraint = NSLayoutConstraint()

    // MARK: Callbacks
    var finishButtonAnimation: (() -> Void)

    init(viewModel: PXSecurityCodeViewModel, finishButtonAnimation: @escaping (() -> Void), collectSecurityCodeCallback: @escaping ((PXCardInformationForm, String?) -> Void)) {
        self.viewModel = viewModel
        self.finishButtonAnimation = finishButtonAnimation
        self.viewModel.callback = collectSecurityCodeCallback
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        renderViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardNotifications()
        setCardContainerViewConstraints()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.textField.becomeFirstResponder()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupAnimations()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotifications()
        loadingButtonComponent?.dismissSnackbar()
    }
}

extension PXSecurityCodeViewController {
    private func confirmPayment() {
        enableUI(false)
        doPayment()
    }

    private func doPayment() {
        subscribeLoadingButtonToNotifications()
        loadingButtonComponent?.startLoading(timeOut: 15)
        textField.becomeFirstResponder()
        viewModel.executeCallback(secCode: textField.text)
    }

    func subscribeLoadingButtonToNotifications() {
        guard let loadingButton = loadingButtonComponent else { return }
        PXNotificationManager.SuscribeTo.animateButton(loadingButton, selector: #selector(loadingButton.animateFinish))
    }

    func enableUI(_ enabled: Bool) {
        view.isUserInteractionEnabled = enabled
        navigationController?.navigationBar.isUserInteractionEnabled = enabled
        loadingButtonComponent?.isUserInteractionEnabled = enabled
    }

    func unsubscribeFromNotifications() {
        PXNotificationManager.UnsuscribeTo.animateButton(loadingButtonComponent)
    }
}

extension PXSecurityCodeViewController: PXAnimatedButtonDelegate {
    func shakeDidFinish() {
        displayBackButton()
        enableUI(true)
        unsubscribeFromNotifications()
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        })
    }

    func expandAnimationInProgress() {
    }

    func didFinishAnimation() {
        finishButtonAnimation()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.resetButton()
        loadingButtonComponent?.showErrorSnackBar()
        enableUI(true)
    }
}

// MARK: Keyboard Notifications
private extension PXSecurityCodeViewController {
    func setupKeyboardNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyboardDidChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidChange(notification: Notification) {
        if let userInfo = notification.userInfo, let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

            var animator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                animator.addAnimation(animation: {
                    self.loadingButtonComponent?.alpha = 1
                    self.loadingButtonBottomConstraint.constant = -keyboardViewEndFrame.height - PXLayout.S_MARGIN
                    self.view.layoutIfNeeded()
                }, delay: 0)
                animator.animate()
            }
        }
    }
}

// MARK: UI
private extension PXSecurityCodeViewController {
    func renderViews() {
        setupControllerView()
        setNavBarBackgroundColor(color: .white)
        setupTitle()
        setupSubtitle()
        setupCardContainerView()
        setupCardDrawer()
        setupTextFieldTitle()
        setupTextField()
        setupLoadingButton()
    }

    func setupControllerView() {
        view.backgroundColor = .white
    }

    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Ingresa el código de seguridad"
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.ml_semiboldSystemFont(ofSize: PXLayout.XL_FONT)
        titleLabel.numberOfLines = 2
        titleLabel.textColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.SM_MARGIN),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.SM_MARGIN)
        ])
        titleLabelBottomConstraint = titleLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIScreen.main.bounds.height)
        titleLabelBottomConstraint.isActive = true
    }

    func setupSubtitle() {
        guard !viewModel.shouldShowCard() else { return }
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Buscalo en el Home Banking o la app de CAIXA."
        subtitle.textAlignment = .left
        subtitle.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XS_FONT)
        subtitle.numberOfLines = 2
        subtitle.textColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(subtitle)

        NSLayoutConstraint.activate([
            subtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.S_MARGIN),
            subtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.S_MARGIN)
        ])
        subtitleBottomConstraint = subtitle.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -UIScreen.main.bounds.height)
        subtitleBottomConstraint.isActive = true
    }

    func setupCardContainerView() {
        guard viewModel.shouldShowCard() else { return }
        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.alpha = 0
        view.addSubview(cardContainerView)
        NSLayoutConstraint.activate([
            cardContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            cardContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            cardContainerView.heightAnchor.constraint(equalTo: cardContainerView.widthAnchor, multiplier: PXCardSliderSizeManager.goldenRatio)
        ])
    }

    func setupTextFieldTitle() {
        textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        textFieldTitle.alpha = 0
        textFieldTitle.text = "Código de seguridad"
        textFieldTitle.textAlignment = .center
        textFieldTitle.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XS_FONT)
        textFieldTitle.textColor = UIColor.black.withAlphaComponent(0.8)
        textFieldTitle.numberOfLines = 2
        view.addSubview(textFieldTitle)
        NSLayoutConstraint.activate([
            textFieldTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.S_MARGIN),
            textFieldTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.S_MARGIN)
        ])

        if viewModel.shouldShowCard() {
            textFieldTitleTopConstraint = textFieldTitle.topAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: PXLayout.M_MARGIN + 2)
        } else {
            textFieldTitleTopConstraint = textFieldTitle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 30)
        }
        textFieldTitleTopConstraint.isActive = true
    }

    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardAppearance = .light
        textField.keyboardType = .numberPad
        textField.backgroundColor = .lightGray
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: textFieldTitle.bottomAnchor, constant: PXLayout.SM_MARGIN),
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.widthAnchor.constraint(equalToConstant: 150)
        ])
        textField.alpha = 0
    }

    func setupCardDrawer() {
        if let cardUI = viewModel.cardUI, let cardData = viewModel.cardData {
            cardDrawer = MLCardDrawerController(cardUI, cardData)
            if let cardDrawer = cardDrawer {
                cardDrawer.view.backgroundColor = .clear
                let cardView = cardDrawer.getCardView()
                cardView.translatesAutoresizingMaskIntoConstraints = false
                cardView.frame = CGRect(origin: .zero, size: cardContainerView.frame.size)
                cardContainerView.addSubview(cardView)
                cardContainerView.layer.cornerRadius = 9
                NSLayoutConstraint.activate([
                    cardView.topAnchor.constraint(equalTo: cardContainerView.topAnchor),
                    cardView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor),
                    cardView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor),
                    cardView.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor)
                ])
                cardContainerView.clipsToBounds = true
            }
        }
    }

    func setupLoadingButton() {
        loadingButtonComponent = PXAnimatedButton(normalText: "Pagar".localized, loadingText: "Procesando tu pago".localized, retryText: "Reintentar".localized)
        loadingButtonComponent?.translatesAutoresizingMaskIntoConstraints = false
        loadingButtonComponent?.animationDelegate = self
        loadingButtonComponent?.layer.cornerRadius = 4
        loadingButtonComponent?.add(for: .touchUpInside, { [weak self] in
            self?.confirmPayment()
        })
        loadingButtonComponent?.setTitle("Pagar".localized, for: .normal)
        loadingButtonComponent?.backgroundColor = ThemeManager.shared.getAccentColor()
        loadingButtonComponent?.accessibilityIdentifier = "pay_button"
        if let loadingButtonComponent = loadingButtonComponent {
            view.addSubview(loadingButtonComponent)
            NSLayoutConstraint.activate([
                loadingButtonComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.M_MARGIN),
                loadingButtonComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.M_MARGIN),
                loadingButtonComponent.heightAnchor.constraint(equalToConstant: 48)
            ])
            loadingButtonBottomConstraint = loadingButtonComponent.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            loadingButtonBottomConstraint.isActive = true
        }
        loadingButtonComponent?.alpha = 0
    }

    func setCardContainerViewConstraints() {
        guard viewModel.shouldShowCard() else { return }
        view.layoutIfNeeded()
        let cardContainerViewBottomConstraint = cardContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(UIScreen.main.bounds.height - self.getStatusAndNavBarHeight() - self.titleLabel.intrinsicContentSize.height - cardContainerView.frame.size.height - 36))
        cardContainerViewBottomConstraint.isActive = true
        cardContainerView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: UIDevice.isExtraLargeDevice() ? -44 : -40).scaledBy(x: 0.6, y: 0.6)
    }

    func setupAnimations() {
        var animator = PXAnimator(duration: 0.8, dampingRatio: 0.8)
        animator.addAnimation(animation: {
            self.titleLabelBottomConstraint.constant = -(UIScreen.main.bounds.height - self.getStatusAndNavBarHeight() - self.titleLabel.intrinsicContentSize.height)
            self.subtitleBottomConstraint.constant = -(UIScreen.main.bounds.height - self.getStatusAndNavBarHeight() - self.titleLabel.intrinsicContentSize.height - (self.subtitle.intrinsicContentSize.height) - PXLayout.S_MARGIN)
            self.view.layoutIfNeeded()
        }, delay: 0)
        animator.animate()

        var animator2 = PXAnimator(duration: 0.8, dampingRatio: 0.8)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            animator2.addAnimation(animation: {
                self.textFieldTitle.alpha = 1
                self.textField.alpha = 1
                if self.viewModel.shouldShowCard() {
                    self.textFieldTitle.transform = CGAffineTransform.identity.translatedBy(x: 0, y: UIDevice.isExtraLargeDevice() ? -82 : -80)
                    self.textField.transform = CGAffineTransform.identity.translatedBy(x: 0, y: UIDevice.isExtraLargeDevice() ? -82 : -80)
                } else {
                    self.textFieldTitleTopConstraint.constant = 8
                }
                self.view.layoutIfNeeded()
            }, delay: 0)

            animator2.animate()
        }
        cardContainerView.alpha = 1
        cardDrawer?.showSecurityCode()
    }
}

// MARK: Publics
extension PXSecurityCodeViewController {
    func getStatusAndNavBarHeight() -> CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.frame.height ?? 0.0)
    }
}
