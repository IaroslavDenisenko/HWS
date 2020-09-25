//
//  DetailViewController.swift
//  MilestoneProject1
//
//  Created by Iaroslav Denisenko on 25.09.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    var selectedFlag: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFlag()
    }
    
    private func loadFlag() {
        if let flag = selectedFlag {
            imageView.image = UIImage(named: flag)
            title = flag
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionTapped))
        }
    }

    @objc func actionTapped() {
        guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {return}
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: [])
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
}
