//
//  ViewController.swift
//  MilestoneProject4
//
//  Created by Iaroslav Denisenko on 27.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))
        load()
        title = "Photos"
    }
    
    func load() {
        if let savedData = UserDefaults.standard.object(forKey: "photos") as? Data {
            let decoder = JSONDecoder()
            if let images = try? decoder.decode([Photo].self, from: savedData) {
                photos = images
            }
        }
    }
    
    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            try? imageData.write(to : imagePath)
        }
        dismiss(animated: true, completion: nil)
        createPhoto(with: imageName)
    }
    
    func createPhoto(with name: String) {
        let ac = UIAlertController(title: "Caption", message: "Write caption", preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "OK", style: .default)
        { [unowned ac, unowned self] _ in
            var caption = "Unknown"
            if let text = ac.textFields?.first?.text {
                caption = text
            }
            let photo = Photo(name: name, caption: caption)
            self.photos.insert(photo, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.save()
        })
        present(ac, animated: true)
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(photos) {
            UserDefaults.standard.set(savedData, forKey: "photos")
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[0]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = photos[indexPath.row].caption
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else { return }
        let imageName = photos[indexPath.row].name
        detailVC.imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        detailVC.imageName = photos[indexPath.row].caption
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

