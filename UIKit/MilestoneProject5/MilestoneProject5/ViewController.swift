//
//  ViewController.swift
//  MilestoneProject5
//
//  Created by Iaroslav Denisenko on 07.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var countries = [Country]()
    var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicatorView()
        loadCountries()
        title = "Countries"
    }

    func setupActivityIndicatorView() {
        activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.center = tableView.center
        tableView.addSubview(activityIndicatorView)
    }
    
    func loadCountries(_ action: UIAlertAction! = nil) {
        let url = "https://restcountries.eu/rest/v2/all"
        guard let countriesURL = URL(string: url) else { return }
        activityIndicatorView.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            do {
                let jsonData = try Data(contentsOf: countriesURL)
                self?.countries = try JSONDecoder().decode([Country].self, from: jsonData)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.activityIndicatorView.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                    self?.showAlert(title: "Error", message: error.localizedDescription, actionTitle: "Reload", handler: self?.loadCountries)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "DetailViewController") as? DetailViewController {
            vc.countryProperties = countries[indexPath.row].allProperties
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }

}

