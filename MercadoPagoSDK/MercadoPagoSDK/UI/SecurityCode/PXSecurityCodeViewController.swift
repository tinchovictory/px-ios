//
//  PXSecurityCodeViewController.swift
//  MercadoPagoSDK
//
//  Created by Esteban Adrian Boffa on 04/08/2020.
//

import Foundation
import MLUI
import MLCardDrawer

final class PXSecurityCodeViewController: MercadoPagoUIViewController {

    let viewModel: PXSecurityCodeViewModel
    let cardContainerView = UIView()
    let titleLabel = UILabel()
    let subtitle = UILabel()
    let textFieldTitle = UILabel()
    let textField = UITextField()
    var loadingButtonComponent: PXAnimatedButton?
    var cardDrawer: MLCardDrawerController?
    var attemptsWithInternetError: Int = 0

    // MARK: Constraints
    var loadingButtonBottomConstraint = NSLayoutConstraint()
    var titleLabelBottomConstraint = NSLayoutConstraint()
    var subtitleBottomConstraint = NSLayoutConstraint()
    var textFieldTitleTopConstraint = NSLayoutConstraint()

    // MARK: Callbacks
    let finishButtonAnimationCallback: () -> Void
    let collectSecurityCodeCallback: (PXCardInformationForm, String?) -> Void

    init(viewModel: PXSecurityCodeViewModel, finishButtonAnimationCallback: @escaping () -> Void, collectSecurityCodeCallback: @escaping (PXCardInformationForm, String?) -> Void) {
        self.viewModel = viewModel
        self.finishButtonAnimationCallback = finishButtonAnimationCallback
        self.collectSecurityCodeCallback = collectSecurityCodeCallback
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        trackScreenView()
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
        setupNavBarStyle(style: .black)
    }
}

// MARK: Privates
private extension PXSecurityCodeViewController {
    func confirmPayment() {
        trackEvent(path: TrackingPaths.Events.SecurityCode.getConfirmPath(), properties: viewModel.getScreenProperties())
        doPayment()
    }

    func doPayment() {
        if viewModel.internetProtocol?.hasInternetConnection() ?? true {
            enableUI(false)
            subscribeLoadingButtonToNotifications()
            loadingButtonComponent?.startLoading(timeOut: 15)
            textField.becomeFirstResponder()
            collectSecurityCodeCallback(viewModel.cardInfo, textField.text)
        } else {
            trackEvent(path: TrackingPaths.Events.getErrorPath(), properties: viewModel.getNoConnectionProperties())
            attemptsWithInternetError += 1
            if attemptsWithInternetError < 4 {
                // TODO: Modificar texto con lo que defina el equipo de Contenidos
                loadingButtonComponent?.showErrorToast(title: "Hubo un error de conexión. Por favor, intenta pagar en otro momento.", actionTitle: nil, type: MLSnackbarType.default(), duration: MLSnackbarDuration.short, action: nil)
            } else {
                progressButtonAnimationTimeOut()
            }
        }
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

// MARK: PXAnimatedButtonDelegate
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
        textField.resignFirstResponder()
        hideNavBar()
    }

    func didFinishAnimation() {
        finishButtonAnimationCallback()
    }

    func progressButtonAnimationTimeOut() {
        loadingButtonComponent?.resetButton()
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        loadingButtonComponent?.showErrorToast(title: "Intenta en otro momento.", actionTitle: "VOLVER", type: MLSnackbarType.error(), duration: MLSnackbarDuration.long) { [weak self] in
            guard let self = self else { return }
            self.trackAbortEvent(properties: self.viewModel.getScreenProperties())
            self.navigationController?.popViewController(animated: false)
        }
        enableUI(true)
    }

    func resetButton() {
        progressButtonAnimationTimeOut()
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
                })
                animator.animate()
            }
        }
    }
}

// MARK: UI
private extension PXSecurityCodeViewController {
    func renderViews() {
        setupControllerView()
        setupNavBar()
        setupTitle()
        setupSubtitle()
        setupCardContainerView()
        setupCardDrawer()
        // TODO: Remove when Andes texfield is done
        setupTextFieldTitle()
        setupTextField()
        //
        setupLoadingButton()
    }

    func setupControllerView() {
        view.backgroundColor = .white
    }

    func setupNavBar() {
        setNavBarBackgroundColor(color: .white)
        setupNavBarStyle(style: .default)
        setNavBarTextColor(color: .black)
    }

    func setupNavBarStyle(style: UIBarStyle) {
        navigationController?.navigationBar.barStyle = style
    }

    func setupTitle() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        titleLabel.text = viewModel.isVirtualCard() ? viewModel.getVirtualCardTitle() : "Ingresa el código de seguridad"
        titleLabel.textAlignment = .left
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
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        subtitle.text = viewModel.isVirtualCard() ? viewModel.getVirtualCardSubtitle() : "Busca los dígitos en el dorso de tu tarjeta."
        subtitle.textAlignment = .left
        subtitle.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XS_FONT)
        subtitle.numberOfLines = 2
        subtitle.textColor = UIColor.black.withAlphaComponent(0.8)
        view.addSubview(subtitle)

        NSLayoutConstraint.activate([
            subtitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: PXLayout.SM_MARGIN),
            subtitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -PXLayout.SM_MARGIN)
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

    // TODO: Remove when Andes texfield is done
    func setupTextFieldTitle() {
        textFieldTitle.translatesAutoresizingMaskIntoConstraints = false
        textFieldTitle.alpha = 0
        // TODO: Modificar texto con lo que defina el equipo de Contenidos
        textFieldTitle.text = "Código de seguridad"
        textFieldTitle.textAlignment = .center
        textFieldTitle.font = UIFont.ml_regularSystemFont(ofSize: PXLayout.XXS_FONT)
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
            textFieldTitleTopConstraint = textFieldTitle.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: !UIDevice.isSmallDevice() ? 90 : 50)
        }
        textFieldTitleTopConstraint.isActive = true
    }

    func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardAppearance = .light
        textField.keyboardType = .numberPad
        textField.backgroundColor = .lightGray
        textField.delegate = self
        view.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.topAnchor.constraint(equalTo: textFieldTitle.bottomAnchor, constant: PXLayout.XS_MARGIN),
            textField.heightAnchor.constraint(equalToConstant: 40),
            textField.widthAnchor.constraint(equalToConstant: 150)
        ])
        textField.alpha = 0
    }
    //

    func setupCardDrawer() {
        guard viewModel.shouldShowCard() else { return }
        cardDrawer = MLCardDrawerController(viewModel.cardUI, viewModel.cardData)
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
        loadingButtonComponent?.setDisabled()
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
            self.subtitleBottomConstraint.constant = -(UIScreen.main.bounds.height - self.getStatusAndNavBarHeight() - self.titleLabel.intrinsicContentSize.height - (self.subtitle.intrinsicContentSize.height) - 18)
            self.view.layoutIfNeeded()
        })
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
                    self.textFieldTitleTopConstraint.constant = !UIDevice.isSmallDevice() ? 60 : 24
                }
                self.view.layoutIfNeeded()
            })

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

// TODO: Remove when Andes texfield is done
extension PXSecurityCodeViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text?.isEmpty ?? true ? loadingButtonComponent?.setDisabled() : loadingButtonComponent?.setEnabled()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
//        return updatedText.count <= viewModel.cardUI!.securityCodePattern
        return updatedText.count <= viewModel.getSecurityCodeLength()
    }
}

// MARK: Tracking
private extension PXSecurityCodeViewController {
    func trackScreenView() {
        let screenPath = TrackingPaths.Screens.getSecurityCodePath(paymentTypeId: viewModel.paymentMethod.paymentTypeId)
        trackScreen(path: screenPath, properties: viewModel.getScreenProperties(), treatBackAsAbort: true)
    }
}
