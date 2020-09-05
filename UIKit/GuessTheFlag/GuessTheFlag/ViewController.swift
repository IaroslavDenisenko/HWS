//
//  ViewController.swift
//  GuessTheFlag
//
//  Created by Iaroslav Denisenko on 02.09.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var buttons: [UIButton]!
    
    var countries = [
        "estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"
    ]
    var score = 0
    var correctAnswer = 0
    var questionsCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askQuestion()
    }
    
    private func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        for i in 0..<buttons.count {
            buttons[i].setImage(UIImage(named: countries[i]), for: .normal)
            buttons[i].layer.borderWidth = 1.0
            buttons[i].layer.borderColor = UIColor.lightGray.cgColor
        }
        correctAnswer = Int.random(in: 0...2)
        if questionsCount < 10
        {
            title = "Country: \(countries[correctAnswer].uppercased()) Your score:\(score)/\(questionsCount)"
        } else {
            title = "GAME OVER! Your score:\(score)/\(questionsCount)"
        }
    }
    
    private func checkTheAnswer(buttonTag: Int) -> String {
        
        let alertTitle: String
        
        if buttonTag == correctAnswer {
            alertTitle = "Correct"
            score += 1
        } else {
            alertTitle = "Wrong"
            if score > 0 {
                score -= 1
            }
        }
        
        return alertTitle
    }
    
    private func presentAlert(with title: String, message: String!) {
        
        let actionTitle: String
        let handler: ((UIAlertAction) -> Void)?
        
        switch questionsCount {
        case 0...9:
            handler = askQuestion(action:)
            actionTitle = "Continue"
        default:
            actionTitle = "Finish"
            handler = nil
        }
        
        let ac = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction.init(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        
        switch questionsCount {
        case 0...9:
            let message: String
            let alertTitle = checkTheAnswer(buttonTag: sender.tag)
            if alertTitle == "Wrong" {
                message = "That’s the flag of \(countries[sender.tag].uppercased())"
            } else {
                message = "Your score is \(score)"
            }
            presentAlert(with: alertTitle, message: message)
        default:
            presentAlert(with: "GAME OVER", message: nil)
        }
        questionsCount += 1
    }
}

