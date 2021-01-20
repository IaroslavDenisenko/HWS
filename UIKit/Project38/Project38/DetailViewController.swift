//
//  DetailViewController.swift
//  Project38
//
//  Created by Iaroslav Denisenko on 04.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var commit: Commit?
    @IBOutlet var detailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let commit = commit {
            detailLabel.text = commit.message
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
