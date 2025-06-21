//
//  CheckoutCoordinator.swift
//  DoorDash
//
//  Created by Marvin Zhan on 2018-10-14.
//  Copyright © 2018 Monster. All rights reserved.
//

import UIKit

protocol CheckoutCoordinatorDelegate: class {
    func didDismiss(in coordinator: CheckoutCoordinator)
}

final class CheckoutCoordinator: Coordinator {

    let router: Router
    var coordinators: [Coordinator] = []
    let rootViewController: CheckoutViewController

    weak var delegate: CheckoutCoordinatorDelegate?

    init(rootViewController: CheckoutViewController,
         router: Router) {
        self.router = router
        self.rootViewController = rootViewController
    }

    func start() {
        self.rootViewController.delegate = self
    }

    func toPresentable() -> UIViewController {
        return self.rootViewController
    }
}

extension CheckoutCoordinator: CheckoutViewControllerDelegate {

    func dismiss() {
        self.router.popModule()
        self.delegate?.didDismiss(in: self)
    }

    func showPaymentPage() {
        let coordinator = PaymentMethodsCoordinator(
            rootViewController: PaymentMethodsViewController(style: .nativeNavBar, hideApplePayTitle: true),
            router: self.router
        )
        coordinator.start()
        coordinator.delegate = self
        addCoordinator(coordinator)
        self.router.push(coordinator, animated: true) {
            self.removeCoordinator(coordinator)
        }
    }
}

extension CheckoutCoordinator: PaymentMethodsCoordinatorDelegate {

    func didDismiss(in coordinator: PaymentMethodsCoordinator) {
        self.rootViewController.refreshData()
    }
}
