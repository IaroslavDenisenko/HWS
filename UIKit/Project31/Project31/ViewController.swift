//
//  ViewController.swift
//  Project31
//
//  Created by Iaroslav Denisenko on 20.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    weak var activeWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDefaultTitle()
        setupButtons()
        setupStackView()
    }
    
    // MARK: - Navigation bar config
    
    func setupButtons() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [deleteButton, addButton]
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    // MARK: - StackView config
    
    func setupStackView() {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            stackView.axis = .vertical
        }
    }
    
    // MARK: - WebView interaction methods
    
    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        stackView.addArrangedSubview(webView)
        webView.layer.borderColor = UIColor.blue.cgColor
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tappedWebView))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        selectWebView(webView)
    }
    
    @objc func deleteWebView() {
        guard let webView = activeWebView else { return }
        if var currentIndex = stackView.arrangedSubviews.firstIndex(of: webView) {
            webView.removeFromSuperview()
            let subviewsCount = stackView.arrangedSubviews.count
            if subviewsCount == 0 {
                setDefaultTitle()
            } else {
                if currentIndex == subviewsCount {
                    currentIndex = subviewsCount - 1
                }
                if let newActiveWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                    selectWebView(newActiveWebView)
                }
            }
        }
    }
    
    func selectWebView(_ webView: WKWebView) {
        for webView in stackView.arrangedSubviews {
            webView.layer.borderWidth = 0
        }
        webView.layer.borderWidth = 3
        activeWebView = webView
        updateUI(for: webView)
    }
    
    @objc func tappedWebView(_ recognizer: UITapGestureRecognizer) {
        if let webView = recognizer.view as? WKWebView {
            selectWebView(webView)
        }
    }
    
    func updateUI(for webView: WKWebView) {
           title = webView.title
           addressBar.text = webView.url?.absoluteString ?? ""
       }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, let text = textField.text {
            var address = text
            if !address.hasPrefix("https://") {
                if address.hasPrefix("http://") {
                    let index = address.firstIndex(of: ":")!
                    address.insert("s", at: index)
                } else {
                    address.insert(contentsOf: "https://", at: address.startIndex)
                }
            }
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - SizeClass changes handling
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

