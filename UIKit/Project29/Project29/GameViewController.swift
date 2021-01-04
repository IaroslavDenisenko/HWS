//
//  GameViewController.swift
//  Project29
//
//  Created by Iaroslav Denisenko on 01.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    var gameScene: GameScene!
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        angleChanged(angleSlider)
        velocityChanged(velocitySlider)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                gameScene = scene as? GameScene
                gameScene.viewController = self
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    @IBAction func angleChanged(_ sender: UISlider) {
        angleLabel.text = "Angle: \(Int(sender.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: UISlider) {
        velocityLabel.text = "Velocity: \(Int(sender.value))"
    }
    
    @IBAction func launch(_ sender: UIButton) {
        self.angleSlider.isHidden = true
        self.angleLabel.isHidden = true
        self.velocitySlider.isHidden = true
        self.velocityLabel.isHidden = true
        self.launchButton.isHidden = true
        
        self.gameScene.launch(angle: Int(self.angleSlider.value), velocity: Int(self.velocitySlider.value))
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        self.angleSlider.isHidden = false
        self.angleLabel.isHidden = false
        self.velocitySlider.isHidden = false
        self.velocityLabel.isHidden = false
        self.launchButton.isHidden = false
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
