//
//  ViewController.swift
//  Project28
//
//  Created by Iaroslav Denisenko on 28.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import LocalAuthentication

final class ViewController: UIViewController {

    @IBOutlet var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addObserver()
        setupNavigationItems()
    }
    
    func setupNavigationItems() {
        title = "Nothing to see here"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "SetPass", style: .plain, target: self, action: #selector(setupPassword))
    }
    
    func addObserver() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(adjustKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc func adjustKeyboard(notification: Notification) {
        guard let notificationValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenFrame = notificationValue.cgRectValue
        let keyboardViewFrame = view.convert(keyboardScreenFrame, from: view.window)
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        secret.scrollIndicatorInsets = secret.contentInset
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    @objc func setupPassword() {
        if secret.isHidden == false {
            let ac = UIAlertController(title: "Password setup", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac] (action) in
                if let text = ac?.textFields?.first?.text {
                    KeychainWrapper.standard.set(text, forKey: "Password")
                }
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            present(ac, animated: true)
        } else {
            showAlert(title: "Failed changing password" , message: "Unlock the app for change password", actionTitle: "OK")
        }
    }
    
    @IBAction func AuthenticateTapped(_ sender: UIButton) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, authenticationError) in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.showAlert(title: "Authentication failed", message: "You could not be verified; please try again or use application password.", actionTitle: "Use password", handler: self?.checkPassword(_:))
                    }
                }
            }
        } else {
            showAlert(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", actionTitle: "Use password", handler: checkPassword(_:))
        }
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        if handler != nil {
            ac.addAction((UIAlertAction(title: "Cancel", style: .default, handler: nil)))
        }
        present(ac, animated: true)
    }
    
    func checkPassword(_ action: UIAlertAction) {
        let ac = UIAlertController(title: "Password check", message: "Enter your password", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak ac, weak self] (action) in
            if ac?.textFields?.first?.text == KeychainWrapper.standard.string(forKey: "Password") {
                self?.unlockSecretMessage()
            } else {
                self?.showAlert(title: "Authentication failed", message: "You could not be verified; please try again or use application password.", actionTitle: "Use password", handler: self?.checkPassword(_:))
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

