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
    var highScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        askQuestion()
        loadHighScore()
    }
    
    func loadHighScore() {
        highScore = UserDefaults.standard.integer(forKey: "highScore")
    }
    
    private func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        for i in 0..<buttons.count {
            buttons[i].setImage(UIImage(named: countries[i]), for: .normal)
            buttons[i].layer.borderWidth = 1.0
            buttons[i].layer.borderColor = UIColor.lightGray.cgColor
        }
        correctAnswer = Int.random(in: 0...2)
        title = "Country: \(countries[correctAnswer].uppercased()) Your score:\(score)/\(questionsCount)"
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
    
    private func presentAlert(with title: String, message: String!, actionTitle: String, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction.init(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        guard questionsCount < 10 else { return }
        
        questionsCount += 1
        let message: String
        let alertTitle: String
        let actionTitle: String
        let handler: ((UIAlertAction) -> Void)?
        
        alertTitle = checkTheAnswer(buttonTag: sender.tag)
        if alertTitle == "Wrong" {
            message = "That’s the flag of \(countries[sender.tag].uppercased())"
        } else {
            message = "Your score is \(score)"
        }
        switch questionsCount {
        case 1...9:
            handler = askQuestion(action:)
            actionTitle = "Continue"
        default:
            self.title = "GAME OVER! Your score:\(score)/\(questionsCount)"
            actionTitle = "Finish"
            handler = highScoreCheck
        }
        presentAlert(with: alertTitle, message: message, actionTitle: actionTitle, handler: handler)
    }
    
    func restartGame(action: UIAlertAction! = nil) {
        correctAnswer = 0
        questionsCount = 0
        score = 0
        askQuestion()
    }
    
    func highScoreCheck(action: UIAlertAction! = nil) {
        var message: String!
        var title = "GAME OVER"
        if self.score > self.highScore {
            title = "Congratulations!"
            message = "You have broken the previous record: \(self.highScore)"
            self.highScore = self.score
            UserDefaults.standard.set(self.highScore, forKey: "highScore")
        }
        self.presentAlert(with: title, message: message, actionTitle: "Restart", handler: restartGame)
    }
}

