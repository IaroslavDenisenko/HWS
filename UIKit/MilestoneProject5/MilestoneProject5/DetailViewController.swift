//
//  DetailViewController.swift
//  MilestoneProject5
//
//  Created by Iaroslav Denisenko on 07.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import SVGParser

class DetailViewController: UITableViewController {

    
    var countryProperties = [[Any]]()
    var flagImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = countryProperties[0][0] as? String
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(actionButtonTapped))
    }
    
    @objc func actionButtonTapped() {
        if let flag = flagImage, let name = title {
            let activityVC = UIActivityViewController(activityItems: [name, flag], applicationActivities: nil)
            activityVC.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(activityVC, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        countryProperties.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        countryProperties[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        var text: String? = nil
        let property = countryProperties[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                text = "Name: \(property)"
            case 1:
                text = "Capital: \(property)"
            case 2:
                text = "Region: \(property)"
            case 3:
                text = "Subregion: \(property)"
            case 4:
                text = "Native name: \(property)"
            case 5:
                text = "Population: \(property)"
            case 6:
                text = "Area: \(property)"
            default:
                break
            }
        } else if indexPath.section == 2 {
            text = (property as! String)
        } else if indexPath.section == 3 {
            if let language = property as? Language {
                text = language.name
            }
        } else if indexPath.section == 4 {
            if let currency = property as? Currency {
                text = "name = \(currency.name ?? "no data")  symbol = \(currency.symbol ?? "no data") code = \(currency.code ?? "no data")"
            }
        } else if indexPath.section == 1 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FlagCell", for: indexPath) as? FlagCell {
                let url = property as! String
                if let flagURL = URL(string: url) {
                    cell.activityIndicatorView.startAnimating()
                    cell.flagView?.image = UIImage(named: "image")
                    let size = CGSize(width: 200, height: 100)
                    let svgParser = SVGParser(contentsOfURL: flagURL)
                    svgParser.scaledImageWithSize(size) { [weak cell, weak self] image in
                        self?.flagImage = image
                        cell?.flagView?.image = image
                        cell?.activityIndicatorView.stopAnimating()
                        cell?.activityIndicatorView.removeFromSuperview()
                    }
                }
                return cell
            }
        }
        cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
        cell.textLabel?.text = text
        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "General info"
        case 1:
            return "Flag"
        case 2:
            return "Calling codes"
        case 3:
            return "Languages"
        case 4:
            return "Currencies"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 1 ? 100 : 44
    }
}
