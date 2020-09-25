//
//  ViewController.swift
//  MilestoneProject1
//
//  Created by Iaroslav Denisenko on 25.09.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var flags = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFlags()
    }

    private func loadFlags() {
        let fm = FileManager.default
        let path = Bundle.main.bundlePath
        let content = try! fm.contentsOfDirectory(atPath: path)
        for item in content {
            if item.hasSuffix("png") {
                flags.append(item)
            }
        }
        title = "Countries flags"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        flags.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath)
        let imageName = flags[indexPath.row]
        cell.textLabel?.text = imageName
        cell.imageView?.image = UIImage(named: imageName)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let vc = storyboard?.instantiateViewController(identifier: "DetailVC") as? DetailViewController else {return}
        vc.selectedFlag = flags[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}


