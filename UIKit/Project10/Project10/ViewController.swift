//
//  ViewController.swift
//  Project10
//
//  Created by Iaroslav Denisenko on 19.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var people = [Person]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        forceAuthentication()
    }
    
    func setupButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add picture", style: .plain, target: self, action: #selector(selectPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Authentication", style: .plain, target: self, action: #selector(forceAuthentication))
        title = "Pictures"
    }
    
    @objc func selectPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }
    
    func loadPeople() {
        if let savedData = UserDefaults.standard.object(forKey: "people") as? Data {
            if let decodePeople = try?  NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? [Person] {
                people = decodePeople
            }
        }
    }
    
    @objc func forceAuthentication() {
        let context = LAContext()
        var error: NSError?
        let reason = "Authenticate yourself!"
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self?.loadPeople()
                        self?.collectionView.reloadData()
                    } else {
                        self?.showAlert(title: "Authentication failed", message: "You could not be verified; please try again.", actionTitle: "OK")
                    }
                }
            }
        } else {
            showAlert(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", actionTitle: "OK")
        }
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)? = nil) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        cell.name.text = people[indexPath.item].name
        let imageName = people[indexPath.item].image
        let imagePath = self.getDocumentsPath().appendingPathComponent(imageName)
        cell.imageView.image = UIImage(contentsOfFile: imagePath.path)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.4).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        index = indexPath.item
        let ac = UIAlertController(title: "Action", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Rename", style: .default, handler: renameItem))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteItem(action:)))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.popoverPresentationController?.sourceView = collectionView.cellForItem(at: indexPath)
        present(ac, animated: true)
    }
    
    func renameItem(action: UIAlertAction!) {
        let person = people[index]
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction((UIAlertAction(title: "OK", style: .default, handler: { [unowned ac, unowned self] _ in
            if let text = ac.textFields?[0].text {
                person.name = text
                self.collectionView.reloadData()
                self.save()
            }
        })))
        present(ac, animated: true)
    }
    
    func deleteItem(action: UIAlertAction!) {
        people.remove(at: index)
        collectionView.reloadData()
        save()
    }
    
    func save() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: people, requiringSecureCoding: false) {
            UserDefaults.standard.set(savedData, forKey: "people")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsPath().appendingPathComponent(imageName)
        if let jpeg = image.jpegData(compressionQuality: 0.7) {
            try? jpeg.write(to: imagePath)
        }
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        save()
        dismiss(animated: true)
    }
    
    func getDocumentsPath() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
}

