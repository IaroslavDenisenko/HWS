//
//  DetailViewController.swift
//  StormViewer
//
//  Created by Iaroslav Denisenko on 01.09.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var titleName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeTitle()
        loadImage()
    }
    
    private func loadImage() {
        if let image = selectedImage {
            imageView.image = UIImage(named: image)
        }
    }
    
    private func makeTitle() {
        guard let titleName = titleName else {return}
        title = titleName
        navigationItem.largeTitleDisplayMode = .never
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}

