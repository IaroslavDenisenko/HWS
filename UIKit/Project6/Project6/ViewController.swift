//
//  ViewController.swift
//  Project6
//
//  Created by Iaroslav Denisenko on 01.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var label1: UILabel!
    var label2: UILabel!
    var label3: UILabel!
    var label4: UILabel!
    var label5: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
    }

    func setupLabels() {
        
        label1 = UILabel()
        label1.backgroundColor = UIColor.red
        label1.translatesAutoresizingMaskIntoConstraints = false
        label1.text = "THESE"
        label1.sizeToFit()
        view.addSubview(label1)
        
        label2 = UILabel()
        label2.backgroundColor = UIColor.cyan
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.text = "ARE"
        label2.sizeToFit()
        view.addSubview(label2)
        
        label3 = UILabel()
        label3.backgroundColor = UIColor.yellow
        label3.translatesAutoresizingMaskIntoConstraints = false
        label3.text = "SOME"
        label3.sizeToFit()
        view.addSubview(label3)
        
        label4 = UILabel()
        label4.backgroundColor = UIColor.green
        label4.translatesAutoresizingMaskIntoConstraints = false
        label4.text = "AWESOME"
        label4.sizeToFit()
        view.addSubview(label4)
        
        label5 = UILabel()
        label5.backgroundColor = UIColor.orange
        label5.translatesAutoresizingMaskIntoConstraints = false
        label5.text = "LABELS"
        label5.sizeToFit()
        view.addSubview(label5)
        
        //Auto Layout with VFL
//        setupVFLConstariants()
        
        //Auto Layout with anchors
        setupAnchorConstraints()
    }
    
    func setupVFLConstariants() {
        
        let labelsDict = [
            "label1":label1,
            "label2":label2,
            "label3":label3,
            "label4":label4,
            "label5":label5
        ]
        
        for label in labelsDict.keys {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[\(label)]|", options: [], metrics: nil, views: labelsDict as [String : Any]))
        }
        
        let metrics = ["labelsHeigt":88]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label1(labelsHeigt@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]->=10-|", options: [], metrics: metrics, views: labelsDict as [String : Any]))
    }
    
    func setupAnchorConstraints() {
        
        var previous: UILabel?
        for label in [label1, label2, label3, label4, label5] {
            label?.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label?.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            label?.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 1/5, constant: -10).isActive = true
            if let previous = previous {
                label?.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 10).isActive = true
            } else {
                label?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            }
            previous = label
        }
    }
}

