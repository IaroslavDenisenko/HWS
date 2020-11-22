//
//  TableViewController.swift
//  Extension
//
//  Created by Iaroslav Denisenko on 21.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var dataSource = [String: Any]()
    var host: String?
    var keys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    func loadData() {
        guard let host = host else { return }
        if let dict = UserDefaults.standard.dictionary(forKey: host) {
            dataSource = dict
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        keys = dataSource.map { (key: String, value: Any) -> String in key
        }
        cell.textLabel?.text = keys[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let rootVC = navigationController?.viewControllers[0] as? ActionViewController {
            if let script = dataSource[keys[indexPath.row]] as? String {
                rootVC.run(script: script)
            }
        }
    }
    
}
