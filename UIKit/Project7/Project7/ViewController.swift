//
//  ViewController.swift
//  Project7
//
//  Created by Iaroslav Denisenko on 04.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var initialPetitions = [Petition]()
    var isDataLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupBarButtons()
        title = "Whitehouse petitions"
    }
    
    func setupBarButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(creditsButtonTapped))
        let filterSwitchON = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(filterButtonTapped))
        let filterSwitchOFF = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(updatePetitions))
        navigationItem.leftBarButtonItems = [filterSwitchOFF, filterSwitchON]
    }
    
    @objc func creditsButtonTapped() {
        let ac = UIAlertController(title: "Credits", message: "Data comes from the We The People API of the Whitehouse", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func filterButtonTapped() {
        var filteredPetitions = [Petition]()
        let initialPetitions = petitions
        let ac = UIAlertController(title: "Filter petitions", message: "Enter string to filter petitions", preferredStyle: .alert)
        ac.addTextField()
        let action = UIAlertAction(title: "Filter", style: .default) { [weak self, weak ac] _ in
            if let text = ac?.textFields?.first?.text {
                DispatchQueue.global(qos: .userInteractive).async {
                    for petition in initialPetitions {
                        if petition.title.lowercased().contains(text.lowercased()) {
                            filteredPetitions.append(petition)
                        }
                    }
                    self?.petitions = filteredPetitions
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        ac.addAction(action)
        present(ac, animated: true)
    }
    
    @objc func updatePetitions() {
        loadData()
        if !isDataLoaded {
            petitions = initialPetitions
            tableView.reloadData()
        }
    }
    
    func loadData() {
        let stringURL: String
        if navigationController?.tabBarItem.tag == 0 {
            stringURL = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            stringURL = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        DispatchQueue.global(qos: .userInteractive).async {
            if let url = URL(string: stringURL) {
                if let data = try? Data(contentsOf: url) {
                    self.parse(json: data)
                    return
                }
            }
            self.performSelector(onMainThread: #selector(self.showError), with: nil, waitUntilDone: false)
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            initialPetitions = petitions
            isDataLoaded = true
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func showError() {
        isDataLoaded = false
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = petitions[indexPath.row].title
        cell.detailTextLabel?.text = petitions[indexPath.row].body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.petition = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

}

