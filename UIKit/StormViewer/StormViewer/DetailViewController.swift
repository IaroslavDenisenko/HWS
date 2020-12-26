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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(buttonTapped))
    }
    
    private func loadImage() {
        assert(selectedImage != nil, "Ooops! selectedImage is nil")
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
    
    func setupSharedImage() -> Data? {
        guard let image = imageView.image else { return nil }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let renderedImage = renderer.image { [unowned image] (ctx) in
            image.draw(at: CGPoint.zero)
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36)
            ]
            
            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            attributedString.draw(at: CGPoint(x: 5, y: 5))
        }
        return renderedImage.jpegData(compressionQuality: 0.8)
    }
    
    @objc func buttonTapped() {
        guard let image = setupSharedImage() else {return}
        let ac = UIActivityViewController(activityItems: [image, selectedImage!], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
}

