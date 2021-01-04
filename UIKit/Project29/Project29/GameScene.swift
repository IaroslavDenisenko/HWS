//
//  GameScene.swift
//  Project29
//
//  Created by Iaroslav Denisenko on 01.01.2021.
//  Copyright © 2021 Iaroslav Denisenko. All rights reserved.
//

import SpriteKit
import GameplayKit

enum CollisionType: UInt32 {
    case banana     = 1
    case building   = 2
    case player     = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var buildings = [BuildingNode]()
    weak var viewController: GameViewController!
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    var currenPlayer = 1
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        physicsWorld.contactDelegate = self
        createbuildings()
        createPlayers()
    }
    
    func createbuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            let building = BuildingNode(color: UIColor.red, size: size)
            building.position = CGPoint(x: currentX - size.width / 2, y: size.height / 2)
            building.setup()
            addChild(building)
            buildings.append(building)
        }
    }
    
    func createPlayer(on building: BuildingNode) -> SKSpriteNode {
        let player = SKSpriteNode(imageNamed: "player")
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.categoryBitMask = CollisionType.player.rawValue
        player.physicsBody?.collisionBitMask = CollisionType.banana.rawValue
        player.physicsBody?.contactTestBitMask = CollisionType.banana.rawValue
        player.physicsBody?.isDynamic = false
        player.position = CGPoint(x: building.position.x, y: building.position.y + (building.size.height + player.size.height) / 2)
        addChild(player)
        return player
    }
    
    func createPlayers() {
        player1 = createPlayer(on: buildings[1])
        player1.name = "player1"
        player2 = createPlayer(on: buildings[buildings.count - 2])
        player2.name = "player2"
    }
       
    func launch(angle: Int, velocity: Int) {
        
        let speed = Double(velocity) / 10
        let radians = deg2rad(degrees: angle)
        createBanana()
        
        if currenPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let riseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([riseArm, pause, lowerArm])
            player1.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let riseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([riseArm, pause, lowerArm])
            player2.run(sequence)
            
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse)
        }
    }
    
    func createBanana() {
        
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionType.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.contactTestBitMask = CollisionType.building.rawValue | CollisionType.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true
        addChild(banana)
        
    }
    
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * Double.pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, at: contact.contactPoint)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            destroy(player: player1)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            destroy(player: player2)
        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController.gameScene = newGame
            self.changePlayer()
            newGame.currenPlayer = self.currenPlayer
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func changePlayer() {
        if currenPlayer == 1 {
            currenPlayer = 2
        } else {
            currenPlayer = 1
        }
        viewController.activatePlayer(number: currenPlayer)
    }
    
    func bananaHit(building: SKNode, at point: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingPoint = convert(point, to:  building)
        building.hit(at: buildingPoint)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = point
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 {
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
}
