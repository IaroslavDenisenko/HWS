//
//  ViewController.swift
//  Project10
//
//  Created by Iaroslav Denisenko on 19.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    var people = [Person]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPeople()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(selectPicture))
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
        if let decodePeople = UserDefaults.standard.object(forKey: "people") as? Data {
            let decoder = JSONDecoder()
            do {
                people = try decoder.decode([Person].self, from: decodePeople)
            } catch {
                print("Failed to load people")
            }
        }
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
        let imagePath = getDocumentsPath().appendingPathComponent(imageName)
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
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(people) {
            UserDefaults.standard.set(savedData, forKey: "people")
        } else {
            print("Failed to save people")
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
        save()
        collectionView.reloadData()
        dismiss(animated: true)
    }
    
    func getDocumentsPath() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
}

