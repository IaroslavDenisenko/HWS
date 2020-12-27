//
//  ViewController.swift
//  MilestoneProject9
//
//  Created by Iaroslav Denisenko on 27.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

enum memText: String {
    case top = "Text for top"
    case bottom = "Text for bottom"
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    var topText: String?
    var bottomText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        title = "Meme generator"
    }
    
    func setupButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPicture))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareMeme))
    }
    
    @objc func selectPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    @objc func shareMeme() {
        guard let image = imageView.image else { return }
        let ac = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        imageView.image = image
        topText = nil
        bottomText = nil
        dismiss(animated: true) { [weak self] in
            self?.addText(title: .top)
        }
    }

    func addText(title: memText) {
        let ac = UIAlertController(title: title.rawValue, message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction((UIAlertAction(title: "OK", style: .default) { [weak ac, unowned self] action in
            if let text = ac?.textFields?.first?.text {
                if title == .top {
                    self.topText = text
                    self.addText(title: .bottom)
                } else {
                    self.bottomText = text
                }
                self.createMeme(from: self.imageView.image!)
            }
        }))
        ac.addAction((UIAlertAction(title: "Cancel", style: .default)))
        present(ac, animated: true)
    }
    
    func createMeme(from image: UIImage) {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let meme = renderer.image { [unowned image, weak self] ctx in
            let rect = CGRect(origin: CGPoint.zero, size: image.size)
            image.draw(in: rect)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 42),
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white,
                .strokeWidth: 10.0
            ]
            
            if let text = self?.topText {
                let topText = NSAttributedString(string: text, attributes: attributes)
                topText.draw(with: rect, options: .usesLineFragmentOrigin, context: nil)
            }

            if let text = self?.bottomText {
                let bottomText = NSAttributedString(string: text, attributes: attributes)
                bottomText.draw(with: rect.inset(by: UIEdgeInsets(top: image.size.height - 100, left: 0, bottom: 0, right: 0)), options: .usesLineFragmentOrigin, context: nil)
            }
        }
        
        imageView.image = meme
    }
    

}

