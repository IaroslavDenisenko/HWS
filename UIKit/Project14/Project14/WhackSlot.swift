//
//  WhackSlot.swift
//  Project14
//
//  Created by Iaroslav Denisenko on 01.11.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
    
    var charNode: SKSpriteNode!
    var isVisible = false
    var isHit = false

    func configure(at position: CGPoint) {
        self.position = position
        let hole = SKSpriteNode(imageNamed: "whackHole")
        addChild(hole)
        
        let crop = SKCropNode()
        crop.position = CGPoint(x: 0, y: 15)
        crop.zPosition = 1
        crop.maskNode = SKSpriteNode(imageNamed: "whackMask")
        addChild(crop)
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        crop.addChild(charNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        charNode.xScale = 1.0
        charNode.yScale = 1.0
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "friendChar"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "enemyChar"
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        var removeSmoke = {}
        if let smoke = SKEmitterNode(fileNamed: "Blood") {
            charNode.addChild(smoke)
            removeSmoke = { [weak smoke] in
                smoke?.removeFromParent() }
        }
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let action = SKAction.run({[unowned self] in
            self.isVisible = false
            removeSmoke()
        })
        charNode.run(SKAction.sequence([delay, hide, action]))
    }
}
