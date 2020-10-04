//
//  DetailViewController.swift
//  Project7
//
//  Created by Iaroslav Denisenko on 04.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    var webView: WKWebView!
    var petition: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wrapPetitionInHTML()
    }
    
    func wrapPetitionInHTML() {
        guard let petition = petition else { return }
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style> body { font-size: 150%; } </style>
        </head>
        <body>
        \(petition.body)
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
    }

}
