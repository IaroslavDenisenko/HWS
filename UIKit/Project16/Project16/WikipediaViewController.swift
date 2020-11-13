//
//  WikipediaViewController.swift
//  Project16
//
//  Created by Iaroslav Denisenko on 13.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import WebKit

class WikipediaViewController: UIViewController {

    var capital: String?
    
    override func loadView() {
        view = WKWebView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        title = capital
    }
    
    func setupWebView() {
        guard let webView = view as? WKWebView else { return }
        let wikiURL = "https://en.wikipedia.org/wiki"
        let url = URL(string: wikiURL)
        if let capital = capital, let url = url {
            let capitalURL =  url.appendingPathComponent(capital)
            let request = URLRequest(url: capitalURL)
            webView.load(request)
        }
    }
}
