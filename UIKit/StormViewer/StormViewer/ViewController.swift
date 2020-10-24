//
//  ViewController.swift
//  StormViewer
//
//  Created by Iaroslav Denisenko on 01.09.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var pictures = [String]()
    var counts = [Int]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Storm Viewer"
        loadCounts()
        navigationController?.navigationBar.prefersLargeTitles = true
        performSelector(inBackground: #selector(loadPictures), with: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "recommend the app", style: .done, target: self, action: #selector(recommendButtonTapped))
        
    }
    func loadCounts() {
        counts = UserDefaults.standard.array(forKey: "counts") as? [Int] ?? Array(repeating: 0, count: 10)
    }
    
    @objc func recommendButtonTapped() {
        let message = "Hello, my dear friend! I recommend you to install this amazing app:)"
        let ac = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        ac.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        present(ac, animated: true)
    }
    
    @objc func loadPictures() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let pictures = try! fm.contentsOfDirectory(atPath: path)
        for picture in pictures {
            if picture.hasPrefix("nssl") {
                self.pictures.append(picture)
            }
        }
        self.pictures.sort()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PictureCell", for: indexPath)
        let pictureName = self.pictures[indexPath.row]
        let count = counts[indexPath.row]
        cell.textLabel?.text = pictureName
        cell.detailTextLabel?.text = "Shown: \(count)"
        cell.imageView?.image = UIImage(imageLiteralResourceName: pictureName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else { return }
        counts[indexPath.row] += 1
        UserDefaults.standard.set(counts, forKey: "counts")
        detailVC.selectedImage = pictures[indexPath.row]
        detailVC.titleName = "Picture \(indexPath.row + 1) of \(pictures.count)"
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}

