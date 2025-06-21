//
//  SignupHomeViewController.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-09-16.
//  Copyright © 2018 Monster. All rights reserved.
//

import UIKit
import SnapKit
import IGListKit

protocol SignupHomeViewControllerDelegate: class {
    func dismiss()
}

final class SignupHomeViewController: BaseViewController {

    lazy var adapter: ListAdapter = {
        return ListAdapter(updater: ListAdapterUpdater(), viewController: self)
    }()
    
    private let customNavigationBar: SignupHomeNavigationBar
    private let collectionView: UICollectionView
    private let viewModel: SignupHomeViewModel
    private let inputSectionController: SignInputFormSectionController
    private let buttonSectionController: SignupButtonSectionController

    weak var delegate: SignupHomeViewControllerDelegate?
    var userCanProceedToNextStep: ((SignupMode) -> ())?
    var mode: SignupMode

    init(mode: SignupMode) {
        self.mode = mode
        inputSectionController = SignInputFormSectionController()
        buttonSectionController = SignupButtonSectionController()
        viewModel = SignupHomeViewModel(
            userAPI: UserAPIService(),
            dataStore: ApplicationEnvironment.current.dataStore
        )
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        customNavigationBar = SignupHomeNavigationBar(mode: mode)
        super.init()
        adapter.dataSource = self
    }

    deinit {
        removeKeyboardNotifications()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindModels()
        addKeyboardNotifications()
    }

    func bindModels() {
        self.inputSectionController.userFinishInputing = signButtonTapped
    }

    override func adjustViewWhenKeyboardShow(notification: NSNotification) {
        guard let keyboard = obtainKeyboardInfo(from: notification) else { return }
        collectionView.contentInset = .init(top: 0, left: 0, bottom: keyboard.keyboardHeight, right: 0)
        if inputSectionController.getInputResponder() == .password && mode == .register {
            let bottomOffset = CGPoint(x: 0, y: collectionView.contentSize.height + keyboard.keyboardHeight - collectionView.frame.height)
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                self.collectionView.setContentOffset(bottomOffset, animated: false)
            })
        }
    }

    override func adjustViewWhenKeyboardDismiss(notification: NSNotification) {
        collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
}

extension SignupHomeViewController {

    private func setupUI() {
        self.view.backgroundColor = theme.colors.backgroundGray
        setupNavigationBar()
        setupCollectionView()
        setupConstraints()
    }

    private func setupNavigationBar() {
        self.view.addSubview(customNavigationBar)
        customNavigationBar.delegate = self
        if mode == .register {
            self.customNavigationBar.skipButton.isHidden = false
        }
        self.customNavigationBar.skipButton.addTarget(self, action: #selector(skipBarButtonTapped), for: .touchUpInside)
    }

    private func setupCollectionView() {
        self.view.addSubview(collectionView)
        adapter.collectionView = collectionView
        collectionView.backgroundColor = theme.colors.backgroundGray
        collectionView.alwaysBounceVertical = true
    }

    private func setupConstraints() {
        customNavigationBar.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(theme.navigationBarHeight)
        }

        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension SignupHomeViewController {

    @objc
    func skipBarButtonTapped() {
        guestLogin()
    }
}

extension SignupHomeViewController: ListAdapterDataSource {

    func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        return viewModel.getDataSource(mode: mode)
    }

    func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        if let text = object as? String, text == SignupHomeViewModel.socailLoginIdentifier {
            return SocialLoginSectionController()
        } else if object is SignupAgreementModel {
            return SignupAgreementSectionController()
        } else if object is SignupButtonModel {
            buttonSectionController.buttonTapped = signButtonTapped
            return buttonSectionController
        }
        return inputSectionController
    }

    func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}

extension SignupHomeViewController {

    func signButtonTapped() {
        if self.mode == .register {
            if let validation = self.viewModel.validateRegisterInputs(results: inputSectionController.inputResults) {
                presentAlertView(title: validation.0, message: validation.1)
                return
            }
            registerUser()
        } else {
            if let validation = self.viewModel.validateLoginInputs(results: inputSectionController.inputResults) {
                presentAlertView(title: validation.0, message: validation.1)
                return
            }
            loginUser()
        }
    }

    func registerUser() {
        self.view.isUserInteractionEnabled = false
        buttonSectionController.startAnimating()
        viewModel.register(inputs: inputSectionController.inputResults) { (errorMsg) in
            self.authHandler(errorMsg: errorMsg)
        }
    }

    func loginUser() {
        guard let email = inputSectionController.inputResults[.email],
            let password = inputSectionController.inputResults[.password] else {
            fatalError()
        }
        self.view.endEditing(true)
        self.view.isUserInteractionEnabled = false
        buttonSectionController.startAnimating()
        viewModel.login(email: email, password: password) { (errorMsg) in
            self.authHandler(errorMsg: errorMsg)
        }
    }

    func guestLogin() {
        self.view.isUserInteractionEnabled = false
        buttonSectionController.startAnimating()
        viewModel.guestRegister() { (errorMsg) in
            self.authHandler(errorMsg: errorMsg)
        }
    }

    private func authHandler(errorMsg: String?) {
        self.buttonSectionController.stopAnimating()
        self.view.isUserInteractionEnabled = true
        if let errorMsg = errorMsg {
            self.presentAlertView(title: "Whoops", message: errorMsg)
            return
        }
        self.view.endEditing(true)
        self.userCanProceedToNextStep?(self.mode)
    }

    func presentAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

extension SignupHomeViewController: SignupHomeNavigationBarDelegate {
    func userSwitched(mode: SignupMode) {
        self.mode = mode
        self.adapter.performUpdates(animated: false)
        if mode == .login {
            self.customNavigationBar.skipButton.isHidden = true
        } else {
            self.customNavigationBar.skipButton.isHidden = false
        }
    }

    func backButtonTapped() {
        delegate?.dismiss()
    }
}
