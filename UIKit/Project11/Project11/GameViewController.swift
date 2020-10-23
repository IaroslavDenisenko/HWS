//
//  GameViewController.swift
//  Project11
//
//  Created by Iaroslav Denisenko on 20.10.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") as? GameScene {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                self.scene = scene
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scene.numberOfBalls < 0 {
            let ac = UIAlertController(title: "GAME OVER", message: "You used up all the balls", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            ac.addAction(UIAlertAction(title: "Restart", style: .default, handler: { [unowned self] _ in
                self.scene.numberOfBalls = 5
            }))
            present(ac, animated: true)
        }
    }
}
