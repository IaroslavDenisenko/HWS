//
//  DetailViewController.swift
//  MilestoneProject4
//
//  Created by Iaroslav Denisenko on 27.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var imagePath: URL!
    var imageName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = imageName
        loadImage()
    }
    
    func loadImage() {
        imageView.image = UIImage(contentsOfFile: imagePath.path)
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
