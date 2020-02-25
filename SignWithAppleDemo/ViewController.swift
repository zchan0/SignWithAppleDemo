//
//  ViewController.swift
//  SignWithAppleDemo
//
//  Created by Cencen Zheng on 2020/2/24.
//  Copyright © 2020 Cencen Zheng. All rights reserved.
//

import UIKit
import AuthenticationServices

class ViewController: UIViewController {

    private var button = ASAuthorizationAppleIDButton()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 32, weight: .medium)
        label.text = "Sign with Apple Demo"
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performExistingAccountSetupFlows()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let screenWidth = UIScreen.main.bounds.size.width
        button.frame.size = CGSize(width: screenWidth - 180, height: 48)
        button.center = self.view.center
        
        let size = titleLabel.sizeThatFits(self.view.bounds.size)
        titleLabel.frame.size = size
        titleLabel.center = CGPoint(x: button.center.x, y: button.frame.minY - 50)
    }
    
    func setupViews() {
        self.view.addSubview(titleLabel)
        
        button.addTarget(self, action: #selector(didTapSignWithAppleButton), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc func didTapSignWithAppleButton() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func performExistingAccountSetupFlows() {
        // Prepare requests for both Apple ID and password providers.
        let requests = [ASAuthorizationAppleIDProvider().createRequest(),
                        ASAuthorizationPasswordProvider().createRequest()]
        
        // Create an authorization controller with the given requests.
        let authorizationController = ASAuthorizationController(authorizationRequests: requests)
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

}

extension ViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            showResult(appleIDCredential)
        default: break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

private extension ViewController {
    
    func showResult(_ credential: ASAuthorizationAppleIDCredential) {
        let userId = credential.user
        print("userId = \(userId)")
        let email = credential.email ?? ""
        var fullName = "Name: "
        if let givenName = credential.fullName?.givenName {
            fullName += " \(givenName)"
        }
        if let familyName = credential.fullName?.familyName {
            fullName += " \(familyName)"
        }
        
        let alert = UIAlertController(title: fullName, message: "userId = \(userId) \n email = \(email)", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(dismissAction)
        self.present(alert, animated: true, completion: nil)
    }
}
